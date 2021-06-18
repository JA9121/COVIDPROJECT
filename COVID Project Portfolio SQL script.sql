
SELECT *
FROM PortfolioProjectJA91..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- SELECT the Data

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjectJA91..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in USA

SELECT Location, date, total_cases, total_deaths, round((total_deaths/total_cases)* 100,2) AS DeathPercentage
FROM PortfolioProjectJA91..CovidDeaths
WHERE location Like '%states%'
ORDER BY 1,2


--Looking at Total Cases vs Population


SELECT Location, date, total_cases, population, round((total_cases/population)* 100,2) AS PercecntPopulationInfected
FROM PortfolioProjectJA91..CovidDeaths
WHERE location Like '%states%'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX( total_cases) AS HighestInfectionCount, round(MAX((total_cases/population)* 100),2) AS PercentPopulationInfected
FROM PortfolioProjectJA91..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--SHOWING Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjectJA91..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjectJA91..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
--FROM PortfolioProjectJA91..CovidDeaths
--WHERE continent IS NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT  date, SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS INT)) AS total_new_deaths,
ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100,2) AS DeathPercentage
FROM PortfolioProjectJA91..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY DATE
ORDER BY 1,2

-- TOTAL WORLD NUMBERS

SELECT  SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS INT)) AS total_new_deaths, 
ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100,2) AS DeathPercentage
FROM PortfolioProjectJA91..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER(Partition BY dea.location ORDER BY dea.location,
dea.date) AS RollingVaccinated,
ROUND((RollingPeopleVaccinated/population) * 100, 2)
FROM PortfolioProjectJA91..CovidDeaths dea
JOIN PortfolioProjectJA91..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- CTE 

WITH PopvsVac (continent, location, date, population,new_vaccinations, RollingVaccinated)

AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER(Partition BY dea.location ORDER BY dea.location,
dea.date) AS RollingVaccinated
FROM PortfolioProjectJA91..CovidDeaths dea
JOIN PortfolioProjectJA91..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, ROUND((RollingVaccinated/population)*100,2)
FROM PopvsVac

--TEMP TABLE

--DROP TABLE IF EXISTS #PercentPopVax

CREATE TABLE #PercentPopVax
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingvaccinated numeric
)

INSERT INTO #PercentPopVax

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER(Partition BY dea.location ORDER BY dea.location,
dea.date) AS RollingVaccinated
FROM PortfolioProjectJA91..CovidDeaths dea
JOIN PortfolioProjectJA91..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, ROUND((RollingVaccinated/population)*100,2)
FROM #PercentPopVax

--Creating View to store data for vizualizations

Create VIEW PercentPopVax AS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER(Partition BY dea.location ORDER BY dea.location,
dea.date) AS RollingVaccinated
FROM PortfolioProjectJA91..CovidDeaths dea
JOIN PortfolioProjectJA91..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
