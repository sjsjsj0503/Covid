-- Checking that the tables are right

Select * 
From CovidDeaths

Select *
From CovidVaccinations

-- Streamlining only necessary tables

Select continent, location, date, total_cases, total_deaths, population
From CovidDeaths

-- Ordering table by location in ascending alphabetical oder

Select continent, location, date, total_cases, total_deaths, population
From CovidDeaths
Order by location

-- Calculating rate of infection against population by location

Select continent, location, total_cases, (total_cases/population)*100 as Infection_Rate
From CovidDeaths
Order by location

-- Extracting only the latest rate of infection against population in each location

Select continent, location, Max(total_cases) as Total_Infected, population, Max(total_cases/population)*100 as Infection_Rate
From CovidDeaths
Where continent is not null
Group by continent, location, population
Order by Infection_rate desc

-- Location includes both countries and continents. Removing locations that are continents.

Select continent, location, Max(total_cases) as Total_Infected, population, Max(total_cases/population)*100 as Infection_Rate
From CovidDeaths
Where continent is not null
Group by continent, location, population
Order by Infection_rate desc

-- Finding out Singapore's latest rate of infection

Select continent, location, Max(total_cases) as Total_Infected_Singapore, population, Max(total_cases/population)*100 as Infection_Rate_Singapore
From CovidDeaths
where location = 'Singapore'
Group by continent, location, population

-- Growth of infection rate in Singapore

Select continent, location, date, new_cases, total_cases, population, (total_cases/population)*100 as Infection_Rate_Singapore
From CovidDeaths
where location = 'Singapore'

-- Calulating the rate of death against cases

Select continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as  Death_Rate
From CovidDeaths
Order by location

-- Finding out death count by location

Select continent, location, Sum(new_cases) as Total_Infected_Count, Sum(new_deaths) as Total_Deaths_Count 
From CovidDeaths
Where continent is not null
Group by continent, location
Order by location

-- Syntax error as datatype of 'new deaths' is varchar

Select continent, location, Sum(new_cases) as Total_Infected_Count, Sum(convert(int, new_deaths)) as Total_Deaths_Count 
From CovidDeaths
Where continent is not null
Group by continent, location
Order by location

-- Finding out death count by continent

Select continent, location, Sum(new_cases) as Total_Infected_Count, Sum(convert(int, new_deaths)) as Total_Deaths_Count 
From CovidDeaths
Where (location = 'North America'or location = 'Asia'or location = 'Africa'or location = 'Oceania'or location = 'Europe'or location = 'South America')
Group by continent, location

-- Extracting the latest rate of death against population in each location

Select continent, location, Sum(new_cases) as Total_Infected_Count, Sum(convert(int, new_deaths)) as Total_Deaths_Count, Sum(convert(int, new_deaths))/Sum(new_cases)*100 as Mortality_Rate
From CovidDeaths
Where continent is not null
Group by continent, location
Order by Mortality_Rate desc

-- Finding out mortality rate in Singapore

Select continent, location, Sum(new_cases) as Total_Infected_Count, Sum(convert(int, new_deaths)) as Total_Deaths_Count, Sum(convert(int, new_deaths))/Sum(new_cases)*100 as Mortality_Rate
From CovidDeaths
Where location = 'Singapore'
Group by continent, location

-- Joining CovidDeaths and CovidVaccinations tables

Select CD.continent, CD.location, Sum(convert(int, CD.new_deaths)) as Total_Deaths_Count, Max(CV.total_vaccinations) as Total_Vaccinated, CD.population
From CovidDeaths CD 
Join CovidVaccinations CV
On CD.continent = CV.continent
And CD.location = CV.location
Where CD.continent is not null
Group by CD.continent, CD.location, CD.population
Order by CD.location

-- Creating a new table (total deaths vs total vaccinations) for quick access

Create Table Total_Deaths_v_Total_Vaccinations
(continent nvarchar(225),
location nvarchar(225),
Total_Deaths_Count float,
Total_Vaccinated float,
Population float)

Insert into Total_Deaths_v_Total_Vaccinations
Select CD.continent, CD.location, Sum(convert(int, CD.new_deaths)) as Total_Deaths_Count, Max(CV.total_vaccinations) as Total_Vaccinated, CD.population
From CovidDeaths CD 
Join CovidVaccinations CV
On CD.continent = CV.continent
And CD.location = CV.location
Where CD.continent is not null
Group by CD.continent, CD.location, CD.population

Select * 
From Total_Deaths_v_Total_Vaccinations
Order by location

-- Displaying total deaths in countries where total vaccinations is less than 5 million

Select distinct location, Max(total_deaths) as Total_Deaths
From CovidDeaths
Where location IN
	(Select location
		From CovidVaccinations
		Where continent is not null
		Group by continent, location
		Having convert(int, Max(total_vaccinations)) < 5000000)
Group by location
