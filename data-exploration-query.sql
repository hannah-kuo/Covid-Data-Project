SELECT *
From CovidProject..CovidDeaths
Where continent is not null
order by 3,4

--SELECT *
--From CovidProject..CovidVaccinations$
--order by 3,4


-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your contry

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject.dbo.CovidDeaths
Where location like '%canada' and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population get COVID

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From CovidProject.dbo.CovidDeaths
Where location like '%canada'
order by 1,2


-- Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, 
	MAX((total_cases/population)*100) as PercentPopulationInfected
From CovidProject.dbo.CovidDeaths
Group by Location, population
Order by PercentPopulationInfected desc


-- Showing countries with highest death count per population
-- Need to cast nvarchar(255) data type as integer

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject.dbo.CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT


-- Showing continnents with the highest death count per population (correct solution)

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject.dbo.CovidDeaths
Where continent is null
Group by Location
Order by TotalDeathCount desc


-- Tutorial's way of doing it (missing information)

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject.dbo.CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From CovidProject.dbo.CovidDeaths
Where continent is not null
Group by date
order by 1,2


-- Joining the two tables
-- Looking at Total Populations vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject.dbo.CovidDeaths dea
Join CovidProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject.dbo.CovidDeaths dea
Join CovidProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- and dea.location like 'canada'
)
Select *, (RollingPeopleVaccinated/Population) * 100 as PercentPopulationVaccinated
From PopvsVac


-- TEMP TABLE

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

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject.dbo.CovidDeaths dea
Join CovidProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) * 100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

From CovidProject.dbo.CovidDeaths dea
Join CovidProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

DROP View PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 