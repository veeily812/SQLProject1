SELECT location, population, total_cases, total_deaths,
CASE 
        WHEN total_cases > 0 THEN (CAST(total_deaths AS FLOAT) / total_cases) * 100
        ELSE 0 
END AS DeathPercentage
FROM CovidDeaths
where location like'%states%'
ORDER BY  1, 2;

--Total cases vs population

SELECT location, date, total_cases, population, 
CASE 
        WHEN total_cases > 0 THEN (CAST(total_cases AS FLOAT) / population) * 100
        ELSE 0 
END AS DeathPercentage
FROM CovidDeaths
Where location like '%Viet%'
order by 1,2

-- Highest rate infection rate
SELECT SUM(CAST(total_cases as float)) as totalcases from CovidDeaths
SELECT
    location,
    population,
    MAX(HighestInfectedCount) as HighestInfectedCount,
    CASE
        WHEN MAX(HighestInfectedCount) > 0 THEN (CAST(MAX(HighestInfectedCount) AS FLOAT) / population) * 100
        ELSE 0
    END AS PercentPopulationInfected
FROM
    (
        SELECT
            location,
            population,
            MAX(total_cases) as HighestInfectedCount
        FROM
            CovidDeaths
        GROUP BY
            location, population
    ) AS Subquery
GROUP BY
    location, population
ORDER BY
    location, population;

--Showing country with highest death count per population

SELECT location, MAX(total_deaths)AS TotalDeathsCount
FROM CovidDeaths
WhERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathsCount Desc

-- Break down continent

SELECT continent, MAX(total_deaths) AS TotalDeathsCount
FROM CovidDeaths
WhERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathsCount Desc

--GLOBAL NUMBER

SELECT
    SUM(CAST(new_cases AS float)) AS total_new_cases,
    SUM(CAST(new_deaths AS float)) AS total_new_deaths,
    CASE
        WHEN SUM(CAST(total_cases AS FLOAT)) > 0 AND SUM(CAST(total_deaths AS float)) > 0 THEN
            (SUM(CAST(total_deaths AS FLOAT)) / SUM(CAST(total_cases AS FLOAT))) * 100
        ELSE 0
    END AS DeathPercentage
FROM
    CovidDeaths
WHERE
    continent IS NOT NULL
--GROUP BY
--    date;
ORDER BY 1,2

--Looking for total population vs Vaccination

with PopvsVac (continent, location,date ,population, new_vaccinations, Rollingpeople)
as
(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING )
as Rollingpeople
FROM CovidDeaths dea
JOIN CovidVaccination vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
-- ORDER BY 2,3
)
select *, (Rollingpeople/population)*100 as percentageofrollingpeoplevaccinated
from PopvsVac

-- TEMP TABLE
DROP TABLE if exists #percentVaccinated
Create Table #PercentVaccinated
( continent nvarchar(225),
location nvarchar(225),
date datetime,
population float,
new_vaccinations float,
rollingpeople float)
Insert into #PercentVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING )
as Rollingpeople
FROM CovidDeaths dea
JOIN CovidVaccination vac
ON dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not NULL
Select *, (Rollingpeople/population)*100 
from #PercentVaccinated

--CREATE VIEW TO STORE DATA FOR VISUALIZATION
CREATE VIEW PercentVaccinate as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING )
as Rollingpeople
FROM CovidDeaths dea
JOIN CovidVaccination vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3

