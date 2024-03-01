select *
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to use

select Location, date, total_cases, new_cases, total_deaths, Population
from PortfolioProject..CovidDeaths
order by 1,2


--looking attotal cases vs total deaths
--likelihood to die

select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


--looking at total cases vs population
--shows percentage contracted covid

select Location, date, total_cases, Population,(total_deaths/total_cases)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
Where location like '%kenya%'
order by 1,2

--countries with highest infection rate compared to population

select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%kenya%'
group by location, population
order by PercentagePopulationInfected desc


--Showing countries with highest death count by population

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%kenya%'
where continent is not NULL
group by location
order by TotalDeathCount desc


--BREAK THINGS DOWN BY CONTINENT

select CONTINENT, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%kenya%'
where continent is NOT NULL
group by CONTINENT
order by TotalDeathCount desc

--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULAION

select CONTINENT, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%kenya%'
where continent is NOT NULL
group by CONTINENT
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%kenya%'
where continent is NOT NULL
group by DATE
order by 1,2

--total cases

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%kenya%'
where continent is NOT NULL
--group by DATE
order by 1,2

--JOIN TO TABLES 
--Looking at Total Population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location =vac.location
 and dea.date = vac.date
 where dea.continent is NOT NULL
 order by 2,3
 

 --using  CTE

 with popvsvac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location =vac.location
 and dea.date = vac.date
 where dea.continent is NOT NULL
 --order by 2,3
 )
 select* ,(RollingPeopleVaccinated/population)*100
 From popvsvac

 --using TEMP TABLES
 DROP table if exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location =vac.location
 and dea.date = vac.date
 where dea.continent is NOT NULL
 --order by 2,3

 select*,(RollingPeopleVaccinated/population)*100
 From #PercentPopulationVaccinated


 --CREATING VIEW TO STORE DATE FOR FUTURE VISUALIZATION

 CREATE VIEW PercentPopulationVaccinated AS
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location =vac.location
 and dea.date = vac.date
 where dea.continent is NOT NULL
 --order by 2,3
  


  CREATE VIEW PopvsVac AS
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location =vac.location
 and dea.date = vac.date
 where dea.continent is NOT NULL
 --order by 2,3


 CREATE VIEW totalCases AS
 select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%kenya%'
where continent is NOT NULL
--group by DATE
--order by 1,2


CREATE VIEW GlobalNumbers AS
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%kenya%'
where continent is NOT NULL
group by DATE


--order by 1,2

CREATE VIEW DeathPercentStates AS
select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'

CREATE VIEW PercentagePopulationInfected AS
select Location, date, total_cases, Population,(total_deaths/total_cases)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
Where location like '%kenya%'
--order by 1,2

CREATE VIEW HighestInfectionCount AS
select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%kenya%'
group by location, population
--order by PercentagePopulationInfected desc


CREATE VIEW TotalDeathCount AS
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%kenya%'
where continent is not NULL
group by location
--order by TotalDeathCount desc


CREATE VIEW DeathsPerContinent AS
select CONTINENT, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%kenya%'
where continent is NOT NULL
group by CONTINENT
--order by TotalDeathCount desc

CREATE VIEW ContinentHighestDeathCount AS
select CONTINENT, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%kenya%'
where continent is NOT NULL
group by CONTINENT
--order by TotalDeathCount desc

















