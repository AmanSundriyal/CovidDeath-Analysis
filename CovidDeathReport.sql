--select *
--from PortfolioProject..CovidDeaths
--order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths

select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'india'
order by 1,2

-- looking at the total cases vs population

select location, date, total_cases, population, ((total_cases/population)*100) as CasePercentage
from PortfolioProject..CovidDeaths
where location like 'india'
order by 1,2

-- looking at countries with highest infection rate compared to the population

select location, population, MAX(total_cases) as HighestInfection, MAX(total_cases/population)*100 as HighestInfectionPercentage
from PortfolioProject..CovidDeaths
group by location, population
order by HighestInfectionPercentage desc

-- showing countries with highest death counts per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where location not in (continent)
group by location
order by TotalDeathCount desc

-- showing continents with the highest death count

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- global 

select date, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(new_cases) as TotalCases, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--joining deaths table with the vaccination table

select cd.date, cd.location, population, cd.continent, cv.new_vaccinations
from PortfolioProject..CovidDeaths as cd
	join PortfolioProject..CovidVaccinations as cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 1,2

-- rolling count of people with new vaccinations

select cd.date, cd.location, population, cd.continent, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as running_sum
from PortfolioProject..CovidDeaths as cd
	join PortfolioProject..CovidVaccinations as cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by new_vaccinations

-- total vaccinations vs population
with cte_tvp (date, location, population, continent, new_vaccinations, running_sum) as
(
select cd.date, cd.location, population, cd.continent, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as running_sum
from PortfolioProject..CovidDeaths as cd
	join PortfolioProject..CovidVaccinations as cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)
select *, (running_sum/population)*100 as VaccinationsPerPopulation
from cte_tvp
