Select *
From PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--ORDER BY 3,4

Select location, date, total_cases, new_cases, total_cases, population
From PortfolioProject..CovidDeaths
Order By 1, 2


--Looking at Total Cases vs Total Deaths
--Shows likelyhood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths,
(CONVERT(float, total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
Order By 1, 2

--Looking at Total Cases vs Population
--Shows what percentage got covid

Select location, date, total_cases, population,
(CONVERT(float, total_cases)/NULLIF(CONVERT(float,Population),0))*100 AS PercentPopulationInfection
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
Order By 1, 2

--Looking at Countries with HIghest Infection Rate compared to Population


Select location, population, MAX(total_cases) as HighestInfectionCount,
(CONVERT(float, Max(total_cases))/NULLIF(CONVERT(float,Population),0))*100 AS PercentPopulationInfection
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Group By location, population
Order By PercentPopulationInfection desc


--Showing Countries with the highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeatCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By location
Order By TotalDeatCount desc

--Breaking down by Continent


--Showing continents with the highest death count


Select continent, SUM(cast(total_deaths as int)) as TotalDeatCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By continent
Order By TotalDeatCount desc


--GLOBAL NUMBERS

Select SUM(cast(new_cases as int)) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/NULLIF(SUM(CAST(new_cases AS INT)),0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--Group By date
Order By 1,2

--Looking at Total Population vs Vaccination


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by CAST(dea.date as DATE)) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order BY dea.continent, dea.location, CAST(dea.date as DATE) desc; 


--USing CT

--With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
--as
--(
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--SUM(
--CASE
--	WHEN ISNUMERIC(vac.new_vaccinations) = 1 THEN CAST(vac.new_vaccination AS bigint)
--	ELSE 0
--END
--) OVER (Partition by dea.location Order by CAST(dea.date as DATE)) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--FROM PortfolioProject..CovidDeaths dea
--JOIN PortfolioProject..CovidVaccinations vac
--	ON dea.location = vac.location
--	and dea.date = vac.date
--Where dea.continent is not null
----Order BY dea.continent, dea.location, CAST(dea.date as DATE) desc; 
--)
--Select Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated,
--CASE
--	WHEN Population = 0 THEN NULL
--	ELSE RollingPeopleVaccinated * 100/Population
--END AS PercentPopulationVaccinated
--FROM PopvsVac;

----TEMP TABLE

--DROP TABLE if exists #PercentPopulationVaccinated
--CREATE TABLE #PercentPopulationVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date datetime,
--Population numeric,
--New_vaccinations numeric,
--RollingPeopleVaccinated numeric
--)

--INSERT into #PercentPopulationVaccinated
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by CAST(dea.date as DATE)) as RollingPeopleVaccinated
--FROM PortfolioProject..CovidDeaths dea
--JOIN PortfolioProject..CovidVaccinations vac
--	ON dea.location = vac.location
--	and dea.date = vac.date
----Where dea.continent is not null
----Order BY dea.continent, dea.location, CAST(dea.date as DATE) desc; 

--SELECT *, (RollingPeopleVaccinated/Population)*100
--FROM #PercentPopulationVaccinated



--Creating View to store for later visualizations

Create View PercentPopulationVaccinated as
Select continent, SUM(cast(total_deaths as int)) as TotalDeatCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By continent
--Order By TotalDeatCount desc
