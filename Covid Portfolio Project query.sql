select * from
dbo.CovidDeaths
where continent is not null
order by 3,4

-- Select data that would be used
select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
where continent is not null
order by 1,2


--Total cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where location like '%canada%'
and continent is not null
order by 1,2

-- Total cases vs Population
--show what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from dbo.CovidDeaths
--where location like '%canada%'
order by 1,2


--Countries with highest Infection Rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from dbo.CovidDeaths
--where location like '%canada%'
Group by location, population
order by PercentagePopulationInfected Desc


-- Contries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
--where location like '%canada%'
where continent is not null
Group by location
order by TotalDeathCount Desc


-- Let's break things down by Continent


-- Continent with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
--where location like '%canada%'
where continent is not null
Group by continent
order by TotalDeathCount Desc


--Global numbers
select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, 
(Sum(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
--Group by date
order by 1,2



-- Total population vs Vaccinations

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
  Sum(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated

from dbo.CovidDeaths cd 
Join dbo.CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3

 

 -- Use CTE

 With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (
	 select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	  Sum(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated

	from dbo.CovidDeaths cd 
	Join dbo.CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null
)
Select * , (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
from PopvsVac


--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
 select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
  Sum(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated

from dbo.CovidDeaths cd 
Join dbo.CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date

Select * , (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
from #PercentPopulationVaccinated


-- Creating view to store data for later Visualization
Create View PercentPopulationVaccinated as 
 select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
  Sum(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated

from dbo.CovidDeaths cd 
Join dbo.CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null


Select *
From PercentPopulationVaccinated