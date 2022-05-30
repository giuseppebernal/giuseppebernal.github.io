--Data imported correctly
SELECT *
FROM [Covid-19 Project]..CovidDeaths$
WHERE continent IS NOT Null
ORDER BY 3, 4;

SELECT *
FROM [Covid-19 Project]..CovidVaccinations$
WHERE continent IS NOT Null
ORDER BY 3, 4;

--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Covid-19 Project]..CovidDeaths$
WHERE continent IS NOT Null
ORDER BY 1,2;

--Percentage of deaths in total

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS  death_percentage
FROM [Covid-19 Project]..CovidDeaths$
WHERE continent IS NOT Null
ORDER BY 1,2;

--Percentage of deaths in the United States
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS  death_percentage
FROM [Covid-19 Project]..CovidDeaths$
WHERE continent IS NOT Null AND location LIKE '%states%'
ORDER BY 1,2; 

--Percentage of contraction in the United States

SELECT location, date, total_cases, population, ROUND((total_cases/population)*100,2) AS  contraction_percentage
FROM [Covid-19 Project]..CovidDeaths$
WHERE continent IS NOT Null AND location LIKE '%states%'
ORDER BY 1,2;

--Countries with the highest contraction rate per population

SELECT location, population, MAX(total_cases) AS MaxContractionCount, ROUND(MAX((total_cases/population)*100),2) AS max_contraction_percent
FROM [Covid-19 Project]..CovidDeaths$
WHERE continent IS NOT Null
GROUP BY location, population
ORDER BY max_contraction_percent DESC;

--Countries with the highest deaths

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeaths
FROM [Covid-19 Project]..CovidDeaths$
WHERE continent IS NOT Null
GROUP BY location, population
ORDER BY TotalDeaths DESC;

--Total deaths by continent

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeaths
FROM [Covid-19 Project]..CovidDeaths$
WHERE continent IS Null
GROUP BY location, population
ORDER BY TotalDeaths DESC;

--Global Numbers

SELECT date, SUM(new_cases) AS NewCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100,2) AS DeathPercent
FROM [Covid-19 Project]..CovidDeaths$
WHERE continent IS NOT Null
GROUP BY date
ORDER BY 1,2;

--Confirming data joined correctly

SELECT *
FROM [Covid-19 Project]..CovidDeaths$ AS d
LEFT JOIN [Covid-19 Project]..CovidVaccinations$ AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE  d.continent IS NOT Null
ORDER BY 2,3;

--Total Population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM [Covid-19 Project]..CovidDeaths$ AS d
LEFT JOIN [Covid-19 Project]..CovidVaccinations$ AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT Null
ORDER BY 2,3;

--Rollout of new vaccinations per country 

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS INT)) OVER(Partition BY d.location Order BY d.location, d.date) AS TotalVaccinated
FROM [Covid-19 Project]..CovidDeaths$ AS d
LEFT JOIN [Covid-19 Project]..CovidVaccinations$ AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT Null
ORDER BY 2,3;

--Percentage of people vaccinated per country

With PercVacc (Continent, Location, Date, Population, New_Vaccinations, Total_Vaccinations)
AS (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS INT)) OVER(Partition BY d.location Order BY d.location, d.date) AS TotalVaccinated
FROM [Covid-19 Project]..CovidDeaths$ AS d
LEFT JOIN [Covid-19 Project]..CovidVaccinations$ AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT Null
)
SELECT *, ROUND(((Total_Vaccinations/Population)*100),2) AS Percent_Vaccinated
FROM PercVacc

--View for Data Viz

CREATE VIEW TotalVaccinatedPerCountry
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS INT)) OVER(Partition BY d.location Order BY d.location, d.date) AS TotalVaccinated
FROM [Covid-19 Project]..CovidDeaths$ AS d
LEFT JOIN [Covid-19 Project]..CovidVaccinations$ AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT Null
);

--Confirming View was created

SELECT *
FROM TotalVaccinatedPerCountry;