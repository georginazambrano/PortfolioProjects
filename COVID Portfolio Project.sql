Select *
FROM PortfolioProject5..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--FROM PortfolioProject5..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject5..CovidDeaths
order by 1,2


Select Location, date, total_cases, total_deaths,
(cast(total_deaths as decimal))/(cast(total_cases as decimal))*100 as DeathPercentage
FROM PortfolioProject5..CovidDeaths
Where location like '%Peru%'
order by 1,2

Select Location, date, total_cases, total_deaths,
(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
FROM PortfolioProject5..CovidDeaths
Where location like '%Afghanistan%'
order by 1,2

set sql_mode= '';alter table PortfolioProject5.coviddeaths change column total_cases total_deaths int;

----Shows likelihood of dying if you contract covid in USA
Select Location, date, total_cases,total_deaths, 
(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
From PortfolioProject5..CovidDeaths
Where location like '%states%'
order by 1,2

-- looking at total cases vs population
--shows what percetnage of population got covid
Select Location, date, total_cases,population,
(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as DeathPercentage
From PortfolioProject5..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject5..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


--showing countries with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject5..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT

Select continent, SUM(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject5..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, MAX(new_deaths) as total_deaths, 
SUM(new_deaths)/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject5..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

--Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject5..CovidDeaths dea
Join PortfolioProject5..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject5..CovidDeaths dea
Join PortfolioProject5..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject5..CovidDeaths dea
Join PortfolioProject5..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to Store Data for Later Visualizations
CREATE View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject5..CovidDeaths dea
Join PortfolioProject5..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated