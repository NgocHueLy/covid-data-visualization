-- 1. Global Numbers

select sum(new_cases) as total_cases, sum(new_deaths * 1) as total_deaths, 
sum(new_deaths * 1)/sum(new_cases)*100 as death_percentage
from covid2.covid_deaths
where continent <> ''
order by 1, 2;

-- check the number
-- select sum(new_cases) as total_cases, sum(new_deaths * 1) as total_deaths, 
-- sum(new_deaths * 1)/sum(new_cases)*100 as death_percentage
-- from covid2.covid_deaths
-- where location = 'world'
-- order by 1, 2;

-- CASES

-- 2. Total Deaths, Cases, Death_Percent by continent

select location, sum(new_deaths * 1) as total_deaths_count, sum(new_cases * 1) as total_cases_count, sum(new_deaths * 1)/sum(new_cases * 1)*100 as percent_death
from covid2.covid_deaths
where continent = ''
and location not in ('world', 'European Union', 'international')
group by location
order by total_deaths_count desc;

-- 3. Population Infection Percent Per Country

select location, population, max(total_cases) as highest_infection_count, max(total_cases)/population*100 as population_infected_percent
from covid2.covid_deaths
where continent <> ''
group by location, population
order by population_infected_percent desc;

-- 4. Population Infection Percent by time, country

select location, population, date, max(total_cases) as highest_infection_count, max(total_cases)/population*100 as population_infected_percent
from covid2.covid_deaths
where continent <> ''
group by location, population, date
order by population_infected_percent desc;


-- 5. Death Percent by time, country
create temporary table total_deaths(
location text,
date date,
total_cases int,
total_deaths int);

insert into total_deaths
SELECT location, date, sum(new_cases) over (partition by location order by location, date) as total_cases,
sum(new_deaths) over (partition by location order by location, date) as total_deaths 
-- sum(new_deaths)/sum(new_cases)*100 as death_per
FROM covid2.covid_deaths
where continent <> ''
group by location, date
order by location, date;

select * from total_deaths;

select location, max(total_cases) as total_cases ,max(total_deaths) as total_deaths, max(total_deaths)/max(total_cases)*100 as percent_death
from total_deaths
group by location;

-- 6. reproduction rate range by location

select location, min(reproduction_rate*1), max(reproduction_rate*1)
from covid2.covid_deaths
where continent <> '' and reproduction_rate*1<>0
group by location;

-- 7. % icu_patients per total_cases

select location, max(total_cases) as total_cases, max(icu_patients*1) as icu_patient_count, max(icu_patients*1)/max(total_cases)*100 as percent_icu_patient
from covid2.covid_deaths 
where continent <> ''
group by location
order by icu_patient_count desc;

-- 8. relationship between percent icu patient and economy

select dea.location, max(total_cases)/population*100 as infection_rate, max(icu_patients*1)/max(total_cases)*100 as percent_icu_patient,
gdp_per_capita
from covid2.covid_deaths dea
join covid2.covid_vaccinations vac
on dea.iso_code = vac.iso_code
and dea.date = vac.date
where dea.continent <> ''
group by location
order by percent_icu_patient desc;

-- 9. realationship between percent population infected and  population density (calulate correlation?)

select dea.location, max(total_cases)/population*100 as percent_population_infected, population_density
from covid2.covid_deaths dea
join covid2.covid_vaccinations vac
on dea.iso_code = vac.iso_code
and dea.date = vac.date
where dea.continent <> ''
group by location;

-- things to look at: stringency_index map, stringency_index and infection rate, infection rate vs population density, percent death vs hospital_beds, stringency vs hospital_bed, stringency vs gdp

-- TESTS & VACCINATIONS

-- 10. Global Numbers: total tests, total vaccinations

-- total tests
Select sum(new_tests * 1) as total_tests
from covid2.covid_vaccinations
where continent <> '';

-- total vaccinations
select max(total_vaccinations*1)
from covid2.covid_vaccinations
where location = 'world';

-- gloabal population
select sum(population)
from (
select location, max(population) as population
from covid2.covid_deaths
where continent <> ''
group by location) country_pop;

-- Total vaccinations by continent
select location, max(total_vaccinations * 1)
from covid2.covid_vaccinations
where continent = '' and location NOT IN ('European Union', 'International','World')
group by location;


-- 11. stringency index by location 
select location, date, stringency_index
from covid2.covid_vaccinations
where continent <>'';

-- 12. share of tests that are positive, most recent value by location

select location, max(date), positive_rate
from  covid2.covid_vaccinations 
where positive_rate <>''
group by location;

-- 13. total vaccinations per population, by location

-- create temp table
drop table if exists table_max_vaccination;

create temporary table table_max_vaccination 
( location text,
max_vaccination int);

insert into table_max_vaccination
select location, max(total_vaccinations * 1) as max_vaccinations
from covid2.covid_vaccinations vac
group by location;

select * from table_max_vaccination;
-- end of temp table

select dea.location, population, max_vaccination, max_vaccination/population * 100 as percant_vaccination
from covid2.covid_deaths dea
join table_max_vaccination vac
on dea.location = vac.location
where dea.continent <>''
group by dea.location;

-- 14. share of people who recieve at leat one vaccine dose per population, by location & date
select dea.location, dea.date, population, (people_vaccinated * 1), (people_vaccinated * 1)/population * 100 as percent_dose
from covid2.covid_deaths dea
join covid2.covid_vaccinations vac
on dea.iso_code = vac.iso_code
and dea.date = vac.date
where dea.continent <>'';





