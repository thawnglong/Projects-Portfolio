SELECT *
FROM Project..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM Project..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Project..CovidDeaths
ORDER BY 1,2

-- Total cases vs Total deaths
-- Death percentage if you got COVID-19 in Vietnam

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Project..CovidDeaths
Where location LIKE '%Vietnam%' 
AND continent IS NOT NULL 
ORDER BY 1,2	

-- Total Cases vs Population
-- percentage of population got COVID-19

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS InfectionRate
FROM Project..CovidDeaths
--Where location LIKE '%Vietnam%'
ORDER BY 1,2	

-- Countries with highest infection rate compare to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS HighestInfectionRate
FROM Project..CovidDeaths
--Where location LIKE '%Vietnam%'
GROUP BY Location, population
ORDER BY HighestInfectionRate DESC	

-- Countries with the Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Project..CovidDeaths
--Where location LIKE '%Vietnam%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC	

-- Breakdown by Continents
-- Continent with the highest death count per populationn

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Project..CovidDeaths
--Where location LIKE '%Vietnam%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC	

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Project..CovidDeaths
--Where location LIKE '%Vietnam%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC	


-- Global numbers per day

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM Project..CovidDeaths
--Where location LIKE '%Vietnam%' 
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2	

-- Total Population vs Vacinations 

WITH PopvsVac 
AS
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM Project..CovidDeaths AS d
JOIN Project..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL 
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population*100)
FROM PopvsVac

--Temp table

DROP TABLE IF EXISTS  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)  

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM Project..CovidDeaths AS d
JOIN Project..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population*100)
FROM #PercentPopulationVaccinated

-- Creating view to store date for visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM Project..CovidDeaths AS d
JOIN Project..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL 
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated