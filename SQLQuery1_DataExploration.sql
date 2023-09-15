SELECT *
FROM Covid19.dbo.CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM Covid19.dbo.CovidVaccinations
--ORDER BY 3,4

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM Covid19.dbo.CovidDeaths
ORDER BY 1,2

--Total cases and total deaths
--Shows likelyhood of dying if you contract covid in your country

SELECT Location,date,total_cases,total_deaths,population, (total_deaths/total_cases)*100 as DeathPercentage
FROM Covid19.dbo.CovidDeaths
WHERE Location ='India'
ORDER BY 1,2

--Shows what percentage of population got covid

SELECT Location,date,total_cases,total_deaths,population, (total_cases/population)*100 as AffectedPopulationPercentage
FROM Covid19.dbo.CovidDeaths
WHERE Location ='India'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT Location,population, MAX(total_cases) as HighestInfectionRate, Max((total_cases/population))*100 as PercentagePopulationInfected
FROM Covid19.dbo.CovidDeaths
GROUP BY Location,population
ORDER BY PercentagePopulationInfected DESC

--Showing Countries with Highest Deat Rtaes per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Covid19.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


--Shwoing Continent with highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Covid19.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global numbers

SELECT SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM Covid19.dbo.CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2




--Looking at Total Population vs Vaccination 
--Joining both tables

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
FROM Covid19.dbo.CovidDeaths dea
JOIN Covid19.dbo.CovidVaccinations vac
on dea.location = vac.location and
dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3



--CTE

With PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
FROM Covid19.dbo.CovidDeaths dea
JOIN Covid19.dbo.CovidVaccinations vac
on dea.location = vac.location and
dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TempTable

DROP TABLE if exists #PercentPopulationVaccinated

Create TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
FROM Covid19.dbo.CovidDeaths dea
JOIN Covid19.dbo.CovidVaccinations vac
on dea.location = vac.location and
dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualization

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
FROM Covid19.dbo.CovidDeaths dea
JOIN Covid19.dbo.CovidVaccinations vac
on dea.location = vac.location and
dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3