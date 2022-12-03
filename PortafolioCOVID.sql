Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3, 4 

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

-- Select the data that we are going to be using

Select	Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2

--Looking at the Total Cases vs Total Deaths

Select	Location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where Location like '%Mexico%'
order by 1, 2

--Looking at the Total Cases vs Population
--Show what percentage of the population got COVID

Select	Location, date, population, total_cases, (total_cases/Population)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where Location like '%Mexico%'
order by 1, 2

--Looking at countries with highest infection rate compared to Population
Select	Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
--Where Location like '%Mexico%'
Group by Location, Population
order by PercentPopulationInfected desc 

--Let's BREAK THINGS DOWN BY CONTINENT 

--Showing the continents wiht Highest Death Counts

Select	Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--Where Location like '%Mexico%'
Where continent is not null
Group by continent
order by TotalDeathCount desc 

--GLOBAL NUMBERS

Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%Mexico%'
Where continent is not null
order by 1, 2



--Loking at Total Puplation vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
    On dea.location = vac.location 
    and dea.date = vac.date
Where dea.continent is not null 
order by 2, 3



--USE CTE

With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
    On dea.location = vac.location 
    and dea.date = vac.date
Where dea.continent is not null 
--order by 2, 3
)
Select * ,(RollingPeopleVaccinated/Population)*100
From PopVsVac


--TEMP TABLE

Create Table #PercentPopulationVaccination
(
Continent varchar (255),
Location nvarchar (255),
Date datetime, 
Population numeric,
New_Vaccionations numeric,
RollingPeopleVaccinated numeric,
)

Insert Into #PercentPopulationVaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
    On dea.location = vac.location 
    and dea.date = vac.date
Where dea.continent is not null 
--order by 2, 3


Select * ,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccination


-- Crear View para almacenar datos para futuras visualizaciones 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
    On dea.location = vac.location 
    and dea.date = vac.date
Where dea.continent is not null 
--order by 2, 3