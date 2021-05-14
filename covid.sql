SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM covid.coviddeaths
where continent <> ''
order by 1, 2;


-- Total Cases vs Total Deaths
-- Likelyhood if you contract covid in Vietnam
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid.coviddeaths
where location like '%viet%'
order by 1, 2;


-- Total Cases vs Population
-- show what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS population_infected_perc
FROM covid.coviddeaths
where location like '%taiwan%'
order by 1, 2;


-- country with Highest Infection Rate compared to Popultaion
SELECT location, population, MAX(total_cases) as total_infection_count, MAX((total_cases/population))*100 AS population_infected_perc
FROM covid.coviddeaths
where continent <> ''
group by location, population
order by population_infected_perc desc;

-- Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) as total_death_count
FROM covid.coviddeaths
where continent <> ''
group by location
order by total_death_count desc;




-- BY CONTINENT

-- Showing the continents with the Highest Death Count per population
SELECT continent, MAX(total_deaths) as total_death_count
FROM covid.coviddeaths
where continent <> ''
group by continent
order by total_death_count desc;


-- GLOBAL NUMBERS


-- total death_percentage global
SELECT sum(new_cases), sum(new_deaths),  (sum(new_deaths)/sum(new_cases))*100 as death_percentage
FROM covid.coviddeaths
where continent <> ''
-- group by date
order by 1, 2;

-- New cases, New deaths by date
SELECT date, sum(new_cases), sum(new_deaths),  (sum(new_deaths)/sum(new_cases))*100 as death_percentage
FROM covid.coviddeaths
where continent <> ''
group by date
order by 1, 2;


-- total population vs total vaccinations by location

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as rolling_vaccinations_count
-- , (rolling_vaccinations_count/population)*100
from covid.coviddeaths dea 
join covid.covidvaccinations vac
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
from covid.coviddeaths dea 
join covid.covidvaccinations vac
on dea.iso_code = vac.iso_code 
and dea.date = vac.date
where dea.continent <> '' 
)
SELECT *, (rolling_vaccinations_count/population)*100 as vaccination_perc
FROM PopvsVac
where location like '%viet%';


-- TEMP TABLE
use covid;

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

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as rolling_vaccinations_count
-- , (rolling_vaccinations_count/population)*100
from covid.coviddeaths dea 
join covid.covidvaccinations vac
on dea.iso_code = vac.iso_code 
and dea.date = vac.date
where dea.continent <> '' ;

SELECT *, (rolling_vaccinations_count/population)*100 as vaccination_perc
FROM PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

Create view V_PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as rolling_vaccinations_count
-- , (rolling_vaccinations_count/population)*100
from covid.coviddeaths dea 
join covid.covidvaccinations vac
on dea.iso_code = vac.iso_code 
and dea.date = vac.date
where dea.continent <> '' ;


