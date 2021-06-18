-- First Vizualization

SELECT SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS INT)) AS total_new_deaths, 
ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100,2) AS DeathPercentage
FROM PortfolioProjectJA91..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Second Vizualization

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProjectJA91..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- Third Vizualization

Select Location, Population, MAX(total_cases) as HighestInfectionCount,
ROUND(Max((total_cases/population))*100,2) as PercentPopulationInfected
From PortfolioProjectJA91..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Fourth Vizualization

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount, 
ROUND(Max((total_cases/population))*100,2) as PercentPopulationInfected
From PortfolioProjectJA91..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc