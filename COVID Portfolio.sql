SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.. CovidDeaths
WHERE continent is not null
order by 1,2

--Looking at total cases vs total deaths
--Shows the likelihood of dying if you contract COVID in your country

SELECT Location, Date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
FROM PortfolioProject.. CovidDeaths
WHERE location like '%states%'
order by 1,2

--Looking at the total cases vs population
--Shows what percentage of population that got COVID

SELECT Location, Date, total_cases, population, (total_cases/ population)*100 as PercentPopulationInfected
FROM PortfolioProject.. CovidDeaths
--WHERE location like '%states%'
order by 1,2


-- looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population))*100 as PercentPopulationInfected
FROM PortfolioProject.. CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
order by PercentPopulationInfected desc

-- This is showing countries with highest death count per population

SELECT Location, MAX(cast (total_deaths as int)) TotalDeathCount
FROM PortfolioProject.. CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT
-- showing the continents with the highest death counts


SELECT continent, MAX(cast (total_deaths as int)) TotalDeathCount
FROM PortfolioProject.. CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc


-- Breaking global numbers
SELECT Date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.. CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.. CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
order by 1,2


--looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM( cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population)*100
FROM PortfolioProject.. CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3
;

--use cte


With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM( cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population)*100
FROM PortfolioProject.. CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- temp table

DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM( cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population)*100
FROM PortfolioProject.. CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- create view to store data for later viz.

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM( cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population)*100
FROM PortfolioProject.. CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

CREATE VIEW ContinentWithHighestDeathCount as
SELECT continent, MAX(cast (total_deaths as int)) TotalDeathCount
FROM PortfolioProject.. CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc