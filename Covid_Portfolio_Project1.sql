-- confirms the correct tables are imported ordered by location and date

select *
from PortfolioProject..CovidDeaths
where continent is not null --this removes locations that are continents, if you look at data, we will see that
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

-- next, select data we are going to use
select Location, Date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths (from covid of course)
-- calculating deathrate of covid for the United States everyday since the beginning of covid
-- shows the likelihood of dying of covid in the US from glancing at the data

select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercent
from PortfolioProject..CovidDeaths
where location = 'United States' 
order by 1,2

-- looking at the total cases vs population
-- shows what percentage of people got covid 19

select location, date,  population, total_cases, (total_cases/population)*100 as CasesPercent
from PortfolioProject..CovidDeaths
where location = 'United States' 
order by 1,2

create view CovidPercentinUS as
select location, date,  population, total_cases, (total_cases/population)*100 as CasesPercent
from PortfolioProject..CovidDeaths
where location = 'United States' 

-- what countries have the highest infection rates compared to population?
select Location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CasesPercent
from PortfolioProject..CovidDeaths
group by location, population
order by CasesPercent desc

create view infectionrate as
select Location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CasesPercent
from PortfolioProject..CovidDeaths
group by location, population
-- order by CasesPercent desc


-- what about the country with highest death count per population
select Location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc

create  view deathcount as
select Location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location


-- what about the continent with the highest death count per population
select continent, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc

create View Continent_with_Highest_Death_Count as
select continent, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
-- order by HighestDeathCount desc



-- Global numbers per date
select Date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by Date
order by 1,2

create view globalnumbersperdate as
select Date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by Date

-- total cases globally
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

create view totalcasesglobally as
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null

-- Lets work with vaccinations data
Select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- lets figure out the total vaccinations by location
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as total_rolling_vacc
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- now lets create a temp table to figure out the percentage of the population that is vaccinated

create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_rolling_vacc numeric
)

insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as total_rolling_vacc
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (total_rolling_vacc/population)* 100 as vaccpercent
from #percentpopulationvaccinated
where location = 'United States' 


-- creating view to store for data visualization
create View percentpopulationvaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as total_rolling_vacc
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

