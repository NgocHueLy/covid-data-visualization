-- IMPORT DATA FROM CSV

-- LOAD DATA LOCAL INFILE 'D:/project/sql data exploration/CovidDeaths.csv'
-- INTO TABLE covid2.coviddeaths
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\r\n'
-- IGNORE 1 ROWS;

-- LOAD DATA LOCAL INFILE 'D:/project/sql data exploration/CovidVacinations.csv'
-- INTO TABLE covid2.covid_vaccinations
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\r\n'
-- IGNORE 1 ROWS;

-- SELECT COUNT(*) FROM covid2.coviddeaths;

-- change data type of column date from TEXT to DATE

-- SET SQL_SAFE_UPDATES = 0;
-- UPDATE covid2.covid_deaths 
-- SET 
--     date = STR_TO_DATE(date, '%m/%d/%Y');
-- SET SQL_SAFE_UPDATES = 1;

-- SET SQL_SAFE_UPDATES = 0;
-- UPDATE covid2.covid_vaccinations 
-- SET 
--     date = STR_TO_DATE(date, '%m/%d/%Y');
-- SET SQL_SAFE_UPDATES = 1;

-- SELECT 
--     date
-- FROM
--     covid2.covid_vaccinations;




-- EXPLORE DATA

-- Total Deaths vs Total Cases
-- Likelyhood if you contract covid in Taiwan
SELECT location, date, population, total_cases, total_deaths, total_deaths/total_cases*100 as death_per
FROM covid2.covid_deaths
where continent <> '' and location like '%taiwan%';

-- Total Cases vs Population
-- show what percentage of population got Covid
SELECT location, date, population, total_cases, total_cases/population*100 as infection_per
FROM covid2.covid_deaths
where continent <> ''
order by 1,2;

-- countries with highest infection rate compare to population
SELECT location, population, MAX(total_cases), MAX(total_cases)/population*100.0 as infection_per
FROM covid2.covid_deaths
where continent <> ''
group by location, population
order by infection_per desc;

-- Countries with Highest Death Count per Population
SELECT location, population, MAX(total_deaths*1) as death_count -- , MAX(total_deaths)/population*100.0 as death_per
FROM covid2.covid_deaths
where continent <> ''
group by location, population
order by death_count desc;

-- BY CONTINENT

-- Showing the continents with the Total Death Count
SELECT location as continent, MAX(total_deaths*1) as death_count 
FROM covid2.covid_deaths
where continent = ''
group by 1
order by 2 desc;


-- Showing the continents with the Highest Death Count 
SELECT continent, MAX(total_deaths*1) as death_count 
FROM covid2.covid_deaths
where continent <> ''
group by 1
order by 2 desc;

-- GLOBAL NUMBERS

-- death_percentage global
SELECT sum(new_deaths), sum(new_cases),  sum(new_deaths)/sum(new_cases)*100 as death_per
FROM covid2.covid_deaths
where continent <> '';

-- death_percentage global by date
SELECT date, sum(new_deaths), sum(new_cases),  sum(new_deaths)/sum(new_cases)*100 as death_per
FROM covid2.covid_deaths
where continent <> ''
group by date
order by date;

-- total population vs total vaccinations by location
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as rolling_vaccinations_count
-- , (rolling_vaccinations_count/population)*100
from covid2.covid_deaths dea 
join covid2.covid_vaccinations vac
on dea.iso_code = vac.iso_code 
and dea.date = vac.date
where dea.continent <> ''
order by 2,3;

-- USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as rolling_vaccinations_count
-- , (rolling_vaccinations_count/population)*100
from covid2.covid_deaths dea 
join covid2.covid_vaccinations vac
on dea.iso_code = vac.iso_code 
and dea.date = vac.date
where dea.continent <> ''
)
SELECT *, (rolling_vaccinations_count/population)*100 as vaccination_perc
FROM PopvsVac;


-- TEMP TABLE
use covid2;

Drop Table if exists PercentPopulationVaccinated;

CREATE TABLE PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date date,
population numeric,
new_vaccinations numeric,
rolling_vaccinations_count numeric
);

Insert into PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations * 1 , 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as rolling_vaccinations_count
-- , (rolling_vaccinations_count/population)*100
from covid2.covid_deaths dea 
join covid2.covid_vaccinations vac
on dea.iso_code = vac.iso_code 
and dea.date = vac.date
where dea.continent <> '';

SELECT *, (rolling_vaccinations_count/population)*100 as vaccination_perc
FROM PercentPopulationVaccinated;


-- Creating View to store data for later visualizations


-- population vaccinated percentage view
create view V_PercentPopulationVaccinated AS 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations * 1 , 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as rolling_vaccinations_count
from covid2.covid_deaths dea 
join covid2.covid_vaccinations vac
on dea.iso_code = vac.iso_code 
and dea.date = vac.date
where dea.continent <> '';

