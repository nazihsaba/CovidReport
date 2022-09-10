SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER by 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccination
--ORDER by 3,4



-- Select data that we are going to use.

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2




-- looking at the total cases vs total deaths
-- shows likelihood of dying if you contact covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2
 


 -- looking at total cases vs population
 -- shows what percentage of the population got covid 
 SELECT Location, date, population,total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Leb%'
ORDER BY 1,2



-- Looking at coutries with highest infection rate compared to population

 SELECT Location, population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Leb%'
WHERE continent IS NOT NULL 
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc


-- showing countries with the highest death count per population


SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Leb%'
WHERE continent IS NOT NULL 
GROUP BY Location
ORDER BY TotalDeathCount desc

-- let's break things to into continent 

-- Showing the continent with the highest death count


SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Leb%'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global numbers

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS Total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at the total population vs vaccination 


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	On dea.location = vac.location 
	And dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Use CTE

WITH PopVsVac(conitnent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	On dea.location = vac.location 
	And dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac





-- Temp Table
DROP TABLE #PercentPopulationVaccinated
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO	#PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccination vac
	On dea.location = vac.location 
	And dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
 
 SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccination vac
	On dea.location = vac.location 
	And dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated

