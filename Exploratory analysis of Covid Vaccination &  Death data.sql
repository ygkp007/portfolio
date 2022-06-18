create database portfolioproject;
 

--select *
--from covid_death
--order by 3, 4;

--select *
--from covid_vaccination
--order by 3, 4;

--Let select data that we are goiing to use.

select location, date, total_cases, new_cases, total_deaths, population
from covid_death
order by 1, 2;


-- Total cases vs Total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_death
order by 1, 2;

-- lets look at chances of dying from covid if person is in India
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_death
where location = 'India'
order by 1, 2;

-- looking at total cases vs population.
-- shows percentage of population got covid.
select location, date, total_cases, population, (total_cases/population)*100 as percentage_population_infected
from covid_death
where location = 'India'
order by 1, 2;

--Countries with highest infection rate compared to population.
select location, population, max(total_cases) as highest_infection_count, (max(total_cases/population))*100 as percentage_population_infected
from covid_death
--where location = 'India'
group by location, population
order by percentage_population_infected desc;

-- Countries with highest death count.
select location, max(cast(total_deaths as int)) as total_death_count
from covid_death
where continent is not null
group by location
order by total_death_count desc ;

select*
from covid_death
where continent is not null
order by 3, 4;

--Now let's see the above result in Continent 


select location, max(cast(total_deaths as int)) as total_death_count
from covid_death
where continent iS null
group by location
order by total_death_count desc ;

--showing continents with highest death count
select continent, max(cast(total_deaths as int)) as total_death_count
from covid_death
where continent is not null
group by continent
order by total_death_count desc ;

-- Global Numbers.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_death
where continent is not null
order by 1, 2;

-- Now let's look at cases and deaths around the world on a single date.

select sum(new_cases) as cases, sum(cast (new_deaths as int))as deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from covid_death
where continent is not null
--group by date
order by 1, 2;


select *
from covid_vaccination
  
-- Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from covid_death as dea
join covid_vaccination as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- use cte
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from covid_death as dea
join covid_vaccination as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (rollingpeoplevaccinated/population)*100 
from popvsvac


-- Temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from covid_death as dea
join covid_vaccination as vac
	on dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *, (rollingpeoplevaccinated/population)*100 
from #percentpopulationvaccinated




-- Creating view to store data for later visualization.

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from covid_death as dea
join covid_vaccination as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select * 
from percentpopulationvaccinated;
