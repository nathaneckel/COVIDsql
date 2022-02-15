Select *
FROM CovidDeaths
WHERE continent IS NOT NULL
Order BY 3,4

SELECT *
FROM CovidVaccinations
ORDER BY 3,4

--Select Data that We Will Be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Show the likelihood of dying if you contract COVID by country
Select Location, date, total_cases, total_deaths, (Total_deaths / total_cases)*100 As DeathPercentage
FROM CovidDeaths
Where location like '%state%'
AND continent IS NOT NULL
Order by 1,2

--Look at Total Cases vs Population
--shows what percentage of population contracted COVID

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location like '%state%'
Order by 1,2

--Looking at Countries with highest infection rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%state%'
Group By Location, population
Order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population


SELECT Location, MAX(cast (total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%state%'
WHERE continent IS NOT NULL
Group By Location
Order by TotalDeathCount desc

--LET BREAK IT DOWN BY CONTINENT

SELECT continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%state%'
WHERE continent IS NOT NULL
Group By continent
Order by TotalDeathCount desc

-- SHOW THE CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%state%'
WHERE continent IS NOT NULL
Group By continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM CovidDeaths
--Where location like '%state%'
WHERE continent IS NOT NULL
--GROUP BY DATE
Order by 1,2

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint,v.new_vaccinations)) 
OVER (Partition by d.location ORDER BY d.location, d.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/d.population)*100 As PercentVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3

--USE CTE / "With" statement
-- Using CTE to perform Calculation on Partition By in previous query


With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations 
, SUM(CAST(v.new_vaccinations AS bigint)) 
OVER (Partition by d.location ORDER BY d.location, d.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/d.population)*100 As PercentVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac


--TEMP TABLE
-- Using Temp Table to perform Calculation on Partition By in previous query


DROP TABLE IF EXISTS #PercentPopulationVaccinated

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
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations AS bigint)) 
OVER (Partition by d.location ORDER BY d.location, d.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/d.population)*100 As PercentVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
--WHERE d.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations  
, SUM(CAST(v.new_vaccinations AS bigint)) 
OVER (Partition by d.location ORDER BY d.location, d.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/d.population)*100 As PercentVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3