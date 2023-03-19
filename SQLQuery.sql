--select data that we will use
--select location,date,total_cases,total_deaths,population
--from CovidDeaths
--order by 1,2

--looking at total cases vs total deaths

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from CovidDeaths
--likelyhood of dying in pak
where location like 'pakistan'
order by 1,2
--total cases vs population
select location,date,total_cases,population, (total_cases/population)*100 as deathPercentage
from CovidDeaths
where location like 'pakistan'
order by 1,2
--countries with highest infection rate compared to population
select location,population,MAX(total_cases) as HighestInfRate, MAX(total_cases/population)*100 as percenragePopulationInfected
from CovidDeaths
group by location,population
order by percenragePopulationInfected desc
--countries with highest death count per population
select location,population,MAX(cast(total_deaths as int)) as HighestDeaths, MAX(total_deaths/population)*100 as percenrageDeathes
from CovidDeaths
where continent is not null
group by location,population
order by HighestDeaths desc

--Deaths by continents 
select continent , MAX(cast(total_deaths as int)) as totalDeathCount
from CovidDeaths
where continent is not null
group by continent

-- looking at total population vs vaccination
select  dea.continent, dea.location, dea.population, dea.date , vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date)
as RollingPeopleVaccinated
from covidDeaths dea
join covidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using CTE
With popvsvac (continent , location , population,date,new_vaccinations , RollingPeopleVaccinated)
as
(
select  dea.continent, dea.location, dea.population, dea.date , vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date)
as RollingPeopleVaccinated
from covidDeaths dea
join covidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100
from popvsvac

--Temp Table
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select  dea.continent, dea.location, dea.population, dea.date , vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date)
as RollingPeopleVaccinated
from covidDeaths dea
join covidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


 
 select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for late visualizations

create view PerecentPoepleVaccinated as
select  dea.continent, dea.location, dea.population, dea.date , vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date)
as RollingPeopleVaccinated
from covidDeaths dea
join covidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
