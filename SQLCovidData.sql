  SELECT *
  FROM [PortfolioProject].[dbo].[CovidDeaths$]
  WHERE continent IS NOT NULL
  ORDER BY 3,4

  SELECT *
  FROM [PortfolioProject].[dbo].[CovidVaccinations$]
  ORDER BY 3,4

  --Data Selection

  SELECT Location, date, total_cases, new_cases, total_deaths, population
  FROM [PortfolioProject].[dbo].[CovidDeaths$]
  ORDER BY 1,2

  --Looking at total cases vs total deaths
  -- Likelihood of dying if you contract covid19
    SELECT Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths$]
  WHERE location like '%states%'
  ORDER BY 1,2

  -- Looking at Total Cases vs Population

  Select Location, date, Population, total_cases, (total_cases/population)*100 AS DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths$]
  --WHERE location like '%states%'
  ORDER BY 1,2

  -- Looking at Countries  with Highest Infection Rate compared to Population

  Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
  FROM [PortfolioProject].[dbo].[CovidDeaths$]
  --WHERE location like '%states%'
  GROUP BY Location, Population
  ORDER BY PercentPopulationInfected DESC

  -- LET' BREAK THINGS DOWN BY CONTINET

  -- Showing countries with highest death count per Population
  Select continent, MAX(Cast(total_deaths AS INT)) AS TotatlDeathCount
  FROM [PortfolioProject].[dbo].[CovidDeaths$]
  WHERE continent IS NOT NULL
  GROUP BY continent
  ORDER BY TotatlDeathCount DESC


  --SHOWING THE CONTINENTS WITH HIGHEST DEATH COUNTS
  Select continent, MAX(Cast(total_deaths AS INT)) AS TotatlDeathCount
  FROM [PortfolioProject].[dbo].[CovidDeaths$]
  WHERE continent IS NOT NULL
  GROUP BY continent
  ORDER BY TotatlDeathCount DESC


  -- GLOBAL NUMBERS 
  SELECT  SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage--,  total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths$] WITH (NOLOCK)
  --WHERE location like '%states%'
  WHERE continent IS NOT NULL
  --GROUP BY date
  ORDER BY 1,2


  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order  by dea.location, dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths$] [dea]
  JOIN  [PortfolioProject].[dbo].[CovidVaccinations$] [vac]
	ON dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	ORDER BY 2,3

	--CTE
	With PopvsVac (Continent, Location, Date, Population, New_Vaccinated, RollingPeopleVaccinated)
	as
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order  by dea.location, dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths$] [dea]
  JOIN  [PortfolioProject].[dbo].[CovidVaccinations$] [vac]
	ON dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	--ORDER BY 2,3
	)
	Select *, (RollingPeopleVaccinated/Population)*100
	From popvsVac

	-- Temp Table
	Drop Table if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

	Insert Into #PercentPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order  by dea.location, dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPercentage
	FROM [PortfolioProject].[dbo].[CovidDeaths$] [dea]
	JOIN  [PortfolioProject].[dbo].[CovidVaccinations$] [vac]
	ON dea.location = vac.location
	and dea.date = vac.date
	--Where dea.continent is not null
	--ORDER BY 2,3

	Select *, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated

	--Creating View to store data for later visulizations
	
	Create View PercentPopulationVaccinated as 
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order  by dea.location, dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths$] [dea]
  JOIN  [PortfolioProject].[dbo].[CovidVaccinations$] [vac]
	ON dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	--ORDER BY 2,3
