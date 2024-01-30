--SELECT * FROM CovidProject..CovidDeaths
--ORDER BY 3, 4

--SELECT * FROM CovidProject..CovidVaccination
--ORDER BY 3, 4

--SELECT a data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject.dbo.CovidDeaths 
ORDER BY 1, 2


--looking at Total cases VS total deaths
--shows likelihood of dying if you contract COVID in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM CovidProject.dbo.CovidDeaths
WHERE location LIKE 'rus%'
ORDER BY 1, 2

--lokking at Total cases VS population


--what percentage of population got COVID

SELECT Location, date, population, total_cases, (total_cases/population) * 100 AS CovidPercentage
FROM CovidProject.dbo.CovidDeaths
WHERE location LIKE 'rus%'
ORDER BY 1, 2



--looking at countries with highest infecction rate compared to population

SELECT Location, population, MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM CovidProject.dbo.CovidDeaths
--WHERE location LIKE 'rus%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

--showing at countries with highest death count rate compared to population

SELECT Location, MAX(CAST(total_deaths AS INT)) AS totalDeathCount
FROM CovidProject.dbo.CovidDeaths
--WHERE location LIKE 'rus%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY totalDeathCount DESC


--let break things down by continent

SELECT continent, MAX(CAST(total_deaths AS INT)) AS totalDeathCount
FROM CovidProject.dbo.CovidDeaths
--WHERE location LIKE 'rus%'
WHERE continent IS  NULL
GROUP BY continent
ORDER BY totalDeathCount DESC

SELECT location, MAX(CAST(total_deaths AS INT)) AS totalDeathCount
FROM CovidProject.dbo.CovidDeaths
--WHERE location LIKE 'rus%'
WHERE continent IS NULL
GROUP BY location
ORDER BY totalDeathCount DESC


--

SELECT location, MAX(CAST(total_deaths AS INT)) AS totalDeathCount
FROM CovidProject.dbo.CovidDeaths
--WHERE location LIKE 'rus%'
WHERE continent IS NULL
GROUP BY location
ORDER BY totalDeathCount DESC 

--showing the continents with highest daeath count

SELECT continent, MAX(CAST(total_deaths AS INT)) AS totalDeathCount
FROM CovidProject.dbo.CovidDeaths
--WHERE location LIKE 'rus%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount DESC 

-- clobal numbers
SELECT date, SUM(new_cases) AS totalCases, SUM(CAST(new_deaths AS INT)) AS totalDeaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage -- total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM CovidProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) AS totalCases, SUM(CAST(new_deaths AS INT)) AS totalDeaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage -- total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM CovidProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

--looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM CovidProject..CovidDeaths AS dea
JOIN CovidProject..CovidVaccination As vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


--use CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM CovidProject..CovidDeaths AS dea
JOIN CovidProject..CovidVaccination As vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopVsVac

--temp table

CREATE TABLE #PercentPopulationVacccinated
(continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME, 
population NUMERIC, 
new_vaccinations NUMERIC, 
RollingPeopleVaccinated NUMERIC
)


INSERT INTO #PercentPopulationVacccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM CovidProject..CovidDeaths AS dea
JOIN CovidProject..CovidVaccination As vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVacccinated

--creating view to store data for later visualization

CREATE VIEW PercentPopulationVacccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM CovidProject..CovidDeaths AS dea
JOIN CovidProject..CovidVaccination As vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVacccinated