--test the data

select *
from CovidDeaths$

select *
from CovidVaccine$

--get the needed data
Select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
Where continent is not null 
order by 1,2

--Total Cases vs Total Deaths

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
Where continent is not null 
order by 1,2

--Total cases vs population

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths$
Where continent is not null 
order by 1,2

--country that has highest death compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected,
MAX(Cast(total_deaths as int)) as HighestDeathCount, MAX(cast(total_deaths as int)/population)*100 as PercentPopulationDeath
from CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc

--total population vs vaccine
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


alter table CovidDeaths$
alter column location nvarchar(150)

select 
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location , dea.date ) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccine$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using CTE(temporary table) to perform calculations

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select 
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location , dea.date ) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccine$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--using temp table to perform calculation (other method)

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select 
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location , dea.date ) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccine$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Querry for tableau

--1.(finding total cases,total deaths and the percentage)
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
where continent is not null 
--Group By date
order by 1,2

--2.(finding total death count based on continent)
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is null 
and location not in ('World', 'European Union', 'International','High income','Upper middle income', 'Lower middle income','Low income')
Group by location
order by TotalDeathCount desc

--3.(finding country that has the highest infection)
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
Where location not in 
('World', 'European Union', 'International','High income','Upper middle income', 
'Lower middle income','Low income','Asia','Europe','North America', 'South America','Africa','Ocenia')
Group by Location, Population
order by PercentPopulationInfected desc

--4.(finding the trend infection rate by date
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
Group by Location, Population, date
order by PercentPopulationInfected desc