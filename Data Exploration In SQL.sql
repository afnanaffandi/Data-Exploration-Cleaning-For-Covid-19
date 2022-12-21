select *
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 3,4
--select *
--from [Portfolio Project]..CovidVaccinations$
--order by 3,4


--select the data need using

select location,date,total_cases,new_cases,total_deaths,population
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 1,2

--look for the total cases & total cases with the percentage
select sum(new_cases) as total_cases, sum (cast(new_deaths as int)) as total_deaths,  
sum (cast(new_deaths as int))/sum(new_cases)  *100 as death_percentage
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 1,2

--look for the total cases vs total deaths at Malaysia
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from [Portfolio Project]..CovidDeaths$
where location like '%malaysia%'
and continent is not null
order by 1,2

--Total cases vs population
--shows what percentage of population get covid
select location,population,max(total_cases) as Highest_Infection_Count, max((total_cases/population))*100 as Percentage_Infected
from [Portfolio Project]..CovidDeaths$
--where location like '%malaysia%'
group by location,population
order by Percentage_Infected desc
--percentage population witth date
select location,population,date, max(total_cases) as Highest_Infection_Count, max((total_cases/population))*100 as Percentage_Infected
from [Portfolio Project]..CovidDeaths$
--where location like '%malaysia%'
group by location,population,date 
order by Percentage_Infected desc

--which country has highest infection rate compare to the population
select location,population,max(total_cases) as highest_infection_per_country,max ((total_cases/population))*100 as Infected_Percentage
from [Portfolio Project]..CovidDeaths$
where continent is not null
Group by location,population
order by Infected_Percentage desc

--which country has highest deaths
select location,max(cast(total_deaths as int)) as Total_death_Count
from [Portfolio Project]..CovidDeaths$
where continent is not null
Group by location
order by Total_death_Count desc

--continent that has highest deaths
select location, max(cast(total_deaths as int)) as Total_death_Count
from [Portfolio Project]..CovidDeaths$
where continent is null  
and location not in ('World', 'European Union', 'International')
Group by location
order by Total_death_Count desc

--total vaccination per population
--partition by is for added day by day number of vaccines over location
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)as day_by_day_vaccine
from [Portfolio Project]..CovidDeaths$ as dea
join [Portfolio Project]..CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--using CTE in order to calculate the percentage of day_by_day_vaccine, using CTE(temporary table for calculations only) because day_by_day_vaccine is not in the original data 

with PopvsVac(Continent,Location,Date,Population,New_Vaccinations,Day_By_Day_Vaccine)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)as day_by_day_vaccine
from [Portfolio Project]..CovidDeaths$ as dea
join [Portfolio Project]..CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
Select *,(day_by_day_vaccine/Population)*100 as Percentage_Day_By_Day_Vaccine
From PopvsVac

--Create Temp Table(Make tempdb Database)
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Day_By_Day_Vaccine numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)as Day_By_Day_Vaccine
from [Portfolio Project]..CovidDeaths$ as dea
join [Portfolio Project]..CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

Select *,(Day_By_Day_Vaccine/Population)*100 as Percentage_Day_By_Day_Vaccine
From #PercentPopulationVaccinated

