
SELECT * FROM projectportfolio..coviddeaths
WHERE continent is not NULL 
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM projectportfolio..coviddeaths
WHERE continent is not NULL 
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM projectportfolio..coviddeaths
WHERE location like '%Turkey%'
AND continent is not NULL 
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM projectportfolio..coviddeaths
--WHERE location like '%Turkey%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM projectportfolio..coviddeaths
--WHERE location like '%Turkey%'
Group BY Location, Population
ORDER BY PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM projectportfolio..coviddeaths
WHERE continent is not NULL 
Group BY Location
ORDER BY TotalDeathCount desc

-- Analysis on data BY continent.
-- Showing contintents with the highest death count per population.

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM projectportfolio..coviddeaths
WHERE continent is not NULL 
Group BY continent
ORDER BY TotalDeathCount desc

-- Addtional detail.

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM projectportfolio..coviddeaths
--WHERE location like '%Turkey%'
WHERE continent is NULL AND location not in ('upper middle income', 'high income', 
'lower middle income','Low income')
Group BY Location
ORDER BY TotalDeathCount desc

-- Continents with highest death count per popultion.

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM projectportfolio..coviddeaths
--WHERE location like '%Turkey%'
WHERE continent is not NULL 
Group BY continent
ORDER BY TotalDeathCount desc


--Overall data of numbers of cases and deaths and Death percentage.

SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM projectportfolio..coviddeaths
WHERE continent is not NULL 
ORDER BY 1,2

--Vaccination data and Total deaths.
--Cummulative data of vaccinations.

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as cummulative_vaccinations
FROM projectportfolio..coviddeaths dea
Join projectportfolio..covidvaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--AND dea.location like '%Turkey%'
ORDER BY 2,3

--Using CTE to further work on Cummulative_frequencies.

With PV (Continent, Location, Date, Population, New_Vaccinations, Cummulative_frequencies)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as Cummulative_frequencies

FROM projectportfolio..coviddeaths dea
Join projectportfolio..covidvaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL 

)
SELECT *, (Cummulative_frequencies/Population)*100 FROM PV

-- Creating View to store data for visualizations

CREATE VIEW Vaccinated_people_percentage AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date)
AS Cummulative_frequencies
FROM projectportfolio..coviddeaths dea
Join projectportfolio..covidvaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL 

SELECT * FROM Vaccinated_people_percentage
