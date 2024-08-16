
SELECT * 
FROM PortfolioProjects..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROm PortfolioProjects..Covid_Vacination
ORDER BY 3,4

-- Select Data That we are going to be using

SELECT location, date, total_cases ,new_cases, total_deaths, population
FROM PortfolioProjects..Covid_Deaths
ORDER BY 1,2

-- Lokking at Total Cases vs Total Deaths

-- NULLIF use for 0 divide value
--Shows liklihood of dying if you contract in your country
SELECT location, date, total_cases ,total_deaths, (total_deaths/NULLIF(total_cases,0))* 100 AS Death_Percentage
FROM PortfolioProjects..Covid_Deaths
WHERE location like '%ndia%'
ORDER BY 1,2

-- Looking at the Total Cases VS Population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases , (total_cases/population)* 100 AS Infected_Percentage
FROM PortfolioProjects..Covid_Deaths
WHERE location like '%ndia%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS 'Highest Infection Count', MAX((total_cases/population))* 100 AS 'Percentage Population Infected'
FROM PortfolioProjects..Covid_Deaths
--WHERE location like '%ndia%'
GROUP BY location, population
ORDER BY 'Percentage Population Infected' DESC

-- Showing Countries with Highest Death Count Per Population

SELECT location, MAX(total_deaths) AS 'Total Death Counts'
FROM PortfolioProjects..Covid_Deaths
--WHERE location like '%ndia%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 'Total Death Counts' DESC

-- LET'S  BREAK THINGS BY CONTINENT

SELECT continent, MAX(total_deaths) AS 'Total Death Counts'
FROM PortfolioProjects..Covid_Deaths
--WHERE location like '%ndia%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 'Total Death Counts' DESC

-- Showing The continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS 'Total Death Counts'
FROM PortfolioProjects..Covid_Deaths
--WHERE location like '%ndia%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 'Total Death Counts' DESC


-- GLOBAL NUMBERS
SELECT SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(NULLIF(new_cases, 0)) *100 AS 'Death Percentage'
FROM PortfolioProjects..Covid_Deaths
WHERE continent IS NOT NULL
--GROUP BY Date 
ORDER BY 1,2

-- Looking at Total Populatin Vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
as 'Rolling People Vaccinated',
'Rolling People Vaccinated'
FROM PortfolioProjects..Covid_Deaths dea
JOIN PortfolioProjects..Covid_Vacination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3


-- USE with

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinaions, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM PortfolioProjects..Covid_Deaths dea
JOIN PortfolioProjects..Covid_Vacination vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *,(RollingPeopleVaccinated/population) * 100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccination NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM PortfolioProjects..Covid_Deaths dea
JOIN PortfolioProjects..Covid_Vacination vac
	ON dea.location = vac.location 
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *,(RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM PortfolioProjects..Covid_Deaths dea
JOIN PortfolioProjects..Covid_Vacination vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated