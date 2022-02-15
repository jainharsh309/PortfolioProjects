select *
from coviddeaths
where continent is not null
order by 3,4

--select *
--from coviddeaths
--order by 3,4 

--select the data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
--Shows likelood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location='India'
and continent is not null
order by 1,2

--Looking at total cases vs population
-- shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as Infectiousrate
from coviddeaths
where location='India'
and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, population,MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as Infectiousrate
from coviddeaths
--where location='India'
where continent is not null
group by location , population
order by 4 DESC

--Showing countries with highest death count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from coviddeaths
--where location='India'
where continent is not null
group by location
order by 2 DESC

--LET'S BREAK THING DOWN BY CONTINENT

--Showing continents with highest Death Count per Population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from coviddeaths
--where location='India'
where continent is null
group by continent
order by 2 DESC

--Global Numbers

select SUM(new_cases) as Total_cases , SUM(cast(new_deaths as int)) as TotalDeaths ,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from coviddeaths
--where location='India'
where continent is not null
--group by date
 
--Looking at Total Population vs Vaccinations

--USE CTE
With PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) 
        over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from coviddeaths as dea
 join covidvaccinations as vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select *, (RollingPeopleVaccinated/Population)*100
 from PopvsVac





 --TEMP TABLE

 drop table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric, 
 RollingPeopleVaccinated numeric
 )
 insert into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) 
        over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from coviddeaths as dea
 join covidvaccinations as vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3

 select *, (RollingPeopleVaccinated/Population)*100
 from #PercentPopulationVaccinated


 --Creating View to store data for later visualizations

 create view PercentPopulationVaccinated as 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) 
        over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from coviddeaths as dea
 join covidvaccinations as vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3






