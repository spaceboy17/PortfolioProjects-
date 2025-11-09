

select location, population, total_cases, total_deaths, (total_deaths /total_cases)*100 as DeathPercent
from PortfolioProject..coviddeaths
where total_cases <> 0 

SELECT 
    location, 
    population, 
    total_cases, 
    total_deaths,
    CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE (total_deaths * 100.0 / total_cases) 
    END AS DeathPercent
FROM PortfolioProject..coviddeaths
Where location like '%india%';

 looking at the countries highest infection rate compared to population
select location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..coviddeaths
group by location, population

-- showing the countries with highest death count per population

select location, population, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population))*100 as PercentDeath
from PortfolioProject..coviddeaths
group by location, population

-- showing the continents with Total deaths
select location, MAX(total_deaths) as TotaldeathCount
from PortfolioProject..CovidDeaths
where continent is null and location not like '%countries'
group by location 

 Showing the new cases, total cases, total death and death precentage
select date, new_cases, SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths,
CASE 
        WHEN SUM(CAST(new_cases AS INT)) = 0 THEN 0
        ELSE SUM(CAST(new_deaths AS INT)) * 100.0 / SUM(CAST(new_cases AS INT))
    END AS DeathPercentage
from 
	PortfolioProject..CovidDeaths
where 
	continent is not null
group by date, new_cases

----

select * from  portfolioproject..coviddeaths

select location, population, max(total_cases), max(total_deaths), 
(cast(total_cases as float)/population)*100 as InfectedPopulation, (cast(total_deaths as float)/population)*100 as PeoplDied
FROM (
    SELECT 
        location,
        population,
        MAX(total_cases) AS max_total_cases,
        MAX(total_deaths) AS max_total_deaths
from portfolioproject..coviddeaths 
group by location, population
) AS summary


-- shows the Location, Total Max cases, Total deaths, infected population and People died 
SELECT 
    location, population, max_total_cases, max_total_deaths,
    (CAST(max_total_cases AS FLOAT) / population) * 100 AS InfectedPopulation,
    (CAST(max_total_deaths AS FLOAT) / population) * 100 AS PeopleDied
FROM (
    SELECT location, population,
        MAX(total_cases) AS max_total_cases,
        MAX(total_deaths) AS max_total_deaths
    FROM portfolioproject..coviddeaths 
    GROUP BY location, population
) AS summary
order by location ASC

-- Outer SELECT: This is the final result you'll see
SELECT 
    location,                          -- Name of the country or region
    population,                        -- Total population for that location
    max_total_cases,                   -- Maximum total COVID cases recorded (from subquery)
    max_total_deaths,                  -- Maximum total COVID deaths recorded (from subquery)

    -- Calculate the % of population infected by COVID
    (CAST(max_total_cases AS FLOAT) / population) * 100 AS InfectedPopulation,

    -- Calculate the % of population who died from COVID
    (CAST(max_total_deaths AS FLOAT) / population) * 100 AS PeopleDied

-- FROM a derived table (subquery) that groups and aggregates the raw data
FROM (
    SELECT 
        location,                      -- Group by location
        population,                    -- Group by population (assumed constant per location)

        -- Aggregate functions to get max values for each location
        MAX(total_cases) AS max_total_cases,
        MAX(total_deaths) AS max_total_deaths

    -- Use the main COVID deaths table
    FROM portfolioproject..coviddeaths 

    -- Exclude rows where location is NULL (invalid data)
    WHERE location IS NOT NULL

    -- Group by location and population to aggregate properly
    GROUP BY location, population

) AS summary                           -- Give the subquery a name so the outer query can refer to its columns

-- Sort the final output alphabetically by location name
ORDER BY location ASC;




with PopvsVac (continent, location, population, date, people_vaccinated, new_vaccinations, Rollingpeoplevaccinated)
as(
select  dea.continent, dea.location, dea.population, dea.date, vac.people_vaccinated, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as Rollingpeoplevaccinated --(vac.people_vaccinated/dea.population)*100 as PeopleVaccinatedP3rcent
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccines as vac
	on dea.location = vac.location
where dea.continent is not NULL
)
select *, (Rollingpeoplevaccinated/population)*100 as RP_Percent
from PopvsVac


select location, population, max(total_cases) as PeopleInfected, (max(total_cases)/population)*100
from PortfolioProject..CovidDeaths
where location <> 'null'
group by location , population 
order by 1,2

-- shows infected population
select location, population, max(total_cases) as highestInfection, Max((total_cases/population))*100 as precentPopulationInfected
from PortfolioProject..CovidDeaths
 WHERE location IS NOT NULL
group by location, population
order by precentPopulationInfected desc

-- total death count of continent  
 select continent, max(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by continent 
 order by 2 desc


 --shows total cases, total death and death percentage in world
 select sum(new_cases) as total_Cases, sum(Cast(new_deaths as int)) as total_deaths, -- (sum(Cast(new_deaths as int))/sum(new_cases))*100 as deathPercenatge
 -- Calculates the death percentage: (total deaths / total cases) * 100
-- Uses NULLIF to avoid division by zero when total cases is 0
  (SUM(CAST(new_deaths AS INT)) * 100.0) / NULLIF(SUM(new_cases), 0) as deathPercenatge
 from PortfolioProject..CovidDeaths
 where continent is not null


 select location, date, sum(new_cases) as total_Cases, sum(Cast(new_deaths as int)) as total_deaths, -- (sum(Cast(new_deaths as int))/sum(new_cases))*100 as deathPercenatge
 -- Calculates the death percentage: (total deaths / total cases) * 100
-- Uses NULLIF to avoid division by zero when total cases is 0
  (SUM(CAST(new_deaths AS INT)) * 100.0) / NULLIF(SUM(new_cases), 0) as deathPercenatge
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by location, date
 order by 3 desc
	
--select top (100)*
--from portfolioproject..covidvaccines


---- Total vaccination running

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations ,
--sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.Date),

-- Running total of new vaccinations for each location, ordered by date
    SUM(CONVERT(INT, cv.new_vaccinations)) 
        OVER (
            PARTITION BY cd.location  -- Grouping by country/region
            ORDER BY cd.location, cd.date  -- Ordered by location and date (chronological order)
        ) AS total_vaccinations_running

from PortfolioProject..CovidDeaths as cd
join portfolioproject..covidvaccines as cv
	on cd.location = cv.location	
where cd.location like 'canada'
order by 2,3


-- Create a Common Table Expression (CTE) named PopVac
-- It combines vaccination data with population data and computes running totals
WITH PopVac (continent, location, date, population, new_vaccinations, total_vaccinations_running) AS          -- CTE
(
    SELECT 
        cd.continent,                 -- Continent name (e.g., Asia)
        cd.location,                 -- Country name (e.g., India)
        cd.date,                     -- Date of the data
        cd.population,               -- Population of the location

        -- Convert new_vaccinations from string to INT safely (NULL if non-numeric)
        TRY_CAST(dv.new_vaccinations AS INT) AS new_vaccinations,  

        -- Running total of vaccinations for each location, ordered by date
        SUM(TRY_CAST(dv.new_vaccinations AS INT)) OVER (
            PARTITION BY cd.location       -- Restart running total for each location
            ORDER BY cd.date               -- Order by date for cumulative sum
        ) AS total_vaccinations_running

    FROM 
        PortfolioProject..CovidDeaths AS cd       -- Main COVID-19 data source (deaths, population, etc.)
    JOIN  
        PortfolioProject..CovidVaccines AS dv     -- Vaccination data source
        ON cd.location = dv.location              -- Match by country
        AND cd.date = dv.date                     -- Match by date to ensure data is aligned

    WHERE 
        cd.location LIKE 'india%'                 -- Filter only for locations starting with "india" (e.g., "India")
)

-- Final output: include all CTE columns plus calculated vaccination percentage
SELECT 
    *, 
    -- Calculate % of population vaccinated using the running total
    (CAST(total_vaccinations_running AS FLOAT) / population) * 100 AS percent_population_vaccinated
FROM 
    PopVac;

--Using temp table 
---- Testing: Temporary table for vaccination percentage calculation ----

-- Drop the temp table if it already exists
DROP TABLE IF EXISTS #precentpopVacc;



-- Create a temporary table to store vaccination data with running totals
drop table if exists #precentpopVacc
CREATE TABLE #precentpopVacc
(
    continent NVARCHAR(300),                  -- Continent name (e.g., Asia)
    location NVARCHAR(300),                   -- Country name (e.g., India)
    date DATETIME,                            -- Date of the record
    population NUMERIC,                       -- Total population of the country
    new_vaccinations NUMERIC,                 -- Daily new vaccinations (converted to numeric)
    total_vaccinations_running NUMERIC        -- Running total of vaccinations
);

-- Insert aggregated vaccination data into the temporary table
INSERT INTO #precentpopVacc
SELECT 
    cd.continent, 
    cd.location,
    cd.date, 
    cd.population, 

    -- Safely cast daily new vaccinations to numeric (INT) to avoid errors
    TRY_CAST(dv.new_vaccinations AS INT) AS new_vaccinations,

    -- Running total of vaccinations for each location by date
    SUM(TRY_CAST(dv.new_vaccinations AS INT)) OVER (
        PARTITION BY cd.location        -- Separate running total for each country
        ORDER BY cd.date                -- Accumulate over time
    ) AS total_vaccinations_running

FROM 
    PortfolioProject..CovidDeaths AS cd         -- Deaths & population data
JOIN  
    PortfolioProject..CovidVaccines AS dv       -- Vaccination data
    ON cd.location = dv.location                -- Match by country
    AND cd.date = dv.date                       -- Match by date for accuracy

WHERE 
    cd.location LIKE 'india%'                   -- Filter to include only 'India' (or similar strings)

-- Final result: show all data with % of population vaccinated
SELECT 
    *, 
    (CAST(total_vaccinations_running AS FLOAT) / population) * 100 AS percent_population_vaccinated
FROM 
    #precentpopVacc;


drop table if exists #precentpopVacc
create table #precentpopVacc
(
continent nvarchar(300),
location nvarchar(300),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations_running numeric
)

insert into #precentpopVacc

SELECT 
    cd.continent, cd.location,cd.date, cd.population, dv.new_vaccinations AS new_vaccinations,
    
    -- Running total of vaccinations per location over time
     SUM(TRY_CAST(dv.new_vaccinations AS INT)) OVER (
        PARTITION BY cd.location 
        ORDER BY cd.date
    ) AS total_vaccinations_running

FROM 
    PortfolioProject..CovidDeaths AS cd
JOIN  PortfolioProject..CovidVaccines AS dv
    ON cd.location = dv.location AND cd.date = dv.date

WHERE 
    cd.location LIKE 'india%'

--ORDER BY 
--    cd.location, cd.date;


select *, (cast(total_vaccinations_running as float )/population)*100 percent_population_vaccinated
from #precentpopVacc

**create view percent_population_vaccinated as**
SELECT
cd.continent, cd.location,cd.date, cd.population, dv.new_vaccinations AS new_vaccinations,

```
-- Running total of vaccinations per location over time
 SUM(TRY_CAST(dv.new_vaccinations AS INT)) OVER (
    PARTITION BY cd.location
    ORDER BY cd.date
) AS total_vaccinations_running

```

FROM
PortfolioProject..CovidDeaths AS cd
JOIN  PortfolioProject..CovidVaccines AS dv
ON cd.location = dv.location AND cd.date = dv.date

WHERE
cd.location LIKE 'india%'
creating views 

