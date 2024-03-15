
Select *
From dbo.['CovidDeaths I$']
Where continent is not null
Order by 3,4


--Select *
--From dbo.CovidVaccinations$
--Order by 3,4


-- Selection Of Data 

Select Location, date, total_cases, new_cases,total_deaths, population
From dbo.['CovidDeaths I$']
Where continent is null
Order by 1,2


--  Total Cases Vs Total Deaths
-- These Information Shows The likelihood Of Dying If You Contact Covid In Your Country 

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases) *100	As DeathPercentage
From dbo.['CovidDeaths I$']
Where location like '%Nigeria%'
and  continent is not null
Order by 1,2


Select location, total_cases, total_deaths,(total_deaths/total_cases) *100	As DeathPercentage
From dbo.['CovidDeaths I$']
Where location like '%States%'
and continent is not null
Order by 1,2



Select location, total_cases, total_deaths,(total_deaths/total_cases) *100	As DeathPercentage
From dbo.['CovidDeaths I$']
--Where location like '%States%'
Where continent is not null
Order by 1,2 Desc

-- Likelihood of Dying If One Contact Covid In Various Continents 

Select continent, date, total_cases, total_deaths,(total_deaths/total_cases) *100	As DeathPercentage
From dbo.['CovidDeaths I$']
Where Continent like '%Africa%'
and  continent is not null
Order by 1,2

-- Total Cases Vs Population
-- Showing  What Percentage Of Population Got Covid

Select Location, date, population, total_cases,(total_cases/population) *100 As PercentageOfPopulationWithCovid
From dbo.['CovidDeaths I$']
Where location like '%States%'
and continent is not null
Order by 1,2

Select Location, date, population, total_cases,(total_cases/population) *100 As PercentageOfPopulationWithCovid
From dbo.['CovidDeaths I$']
--Where location like '%Nigeria%'
Order by 1,2


-- Countries With Highest Infection Rate Compared To Population

Select continent,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 As 
     PercentPopulationInfected
From dbo.['CovidDeaths I$']
--Where location like '%Nigeria%'
Group by continent, population
Order by PercentPopulationInfected desc


--  Countries With Highest Death Count Per Population

Select Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount 
From dbo.['CovidDeaths I$']
--Where location like '%Nigeria%'
Where Location is not null
Group by Location 
Order by TotalDeathCount desc




--  BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

Select continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount 
From dbo.['CovidDeaths I$']
--Where location like '%Nigeria%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date,SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/ 
SUM(new_cases)*100 as DeathPercentage 
From dbo.['CovidDeaths I$']
--Where location like '%Nigeria%'
Where continent is not  null
Group By date
Order by 1,2



Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/ 
SUM(new_cases)*100 as DeathPercentage 
From dbo.['CovidDeaths I$']
--Where location like '%Nigeria%'
Where continent is not null
--Group By date
Order by 1,2


-- Total Population Vs Vaccinations
-- Total Amount Of People In The World That Has Been Vaccinated

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
  SUM(Cast( vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) 
     as RollingCountOfPeopleVaccinated
-- ( RollingCountOfPeopleVaccinated/Population)*100
From dbo.['CovidDeaths I$'] dea
Join dbo.CovidVaccinations$ vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Using  CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingCountOfPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
  SUM(Cast( vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) 
     as RollingCountOfPeopleVaccinated
-- ( RollingCountOfPeopleVaccinated/Population)*100
From dbo.['CovidDeaths I$'] dea
Join dbo.CovidVaccinations$ vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3 Desc
)
Select *, (RollingCountOfPeopleVaccinated/Population)*100
From PopvsVac 



-- Using TEMP TABLE


Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCountOfPeopleVaccinated numeric
)          

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location, dea.Date)
  as RollingCountOfPeopleVaccinated
--, ( RollingPeopleVaccinated/Population)*100
From [Portfolio Project]..['CovidDeaths I$'] dea
Join [Portfolio Project]..CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date 
Where dea. Continent is not null
-- Order By 2,3
 
 Select *, (RollingCountOfPeopleVaccinated/Population)*100
 From  #PercentPopulationVaccinated



DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCountOfPeopleVaccinated numeric
)          

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST( vac.new_vaccinations As bigint )) OVER (Partition by dea.Location Order by dea.location, dea.Date)
  as RollingCountOfPeopleVaccinated
--, ( RollingPeopleVaccinated/Population)*100
From [Portfolio Project]..['CovidDeaths I$'] dea
Join [Portfolio Project]..CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date 
--Where dea. Continent is not null 
-- Order By 2,3
 
 Select *, (RollingCountOfPeopleVaccinated/Population)*100
 From  #PercentPopulationVaccinated     



 -- Creating View To Store Data For Later Visualizations

 Create View  PercentageOfPopulationVaccinated As  
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST( vac.new_vaccinations As bigint )) OVER (Partition by dea.Location Order by dea.location, dea.Date)
  as RollingCountOfPeopleVaccinated
--, ( RollingPeopleVaccinated/Population)*100
From [Portfolio Project]..['CovidDeaths I$'] dea
Join [Portfolio Project]..CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date 
Where dea. Continent is not null 
-- Order By 2,3

Select *
From PercentageOfPopulationVaccinated


Create View DeathPercentage As
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases) *100	As DeathPercentage
From dbo.['CovidDeaths I$']
Where location like '%Nigeria%'
and  continent is not null
--Order by 1,2

Select *
From DeathPercentage