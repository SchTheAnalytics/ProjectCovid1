
Select *
From Project1_Covid..CovidDeaths
Where continent is not null --vamos isolar o resultado Nullo
Order by 3,4

--Select * 
--from Project1_Covid..CovidVaccnations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From Project1_Covid..CovidDeaths
where continent is not null --vamos isolar o resultado Nullo
order by 1,2

-- Primeiramente identifiquei que os meus dados n�o eram numericos!

-- codigo para alterar o tipo de dados de uma coluna para num�ricos
alter table CovidDeaths
alter column total_cases NUMERIC(11)

alter table CovidDeaths
alter column total_deaths NUMERIC(11)

alter table CovidDeaths
alter column new_cases FLOAT

alter table CovidDeaths
alter Column new_deaths NUMERIC(11)

alter table CovidVaccnations
alter column new_vaccinations NUMERIC(11)

--Verificar a porcentagem de TOTAL DE CASOS vs TOTAL DE MORTES

-- >>QUAL A PROBABILIDADE DE MORTE SE VOCE CONTRAIR COVID NO BRASIL?
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as  DeathPercentage
From Project1_Covid..CovidDeaths
where continent is not null --vamos isolar o resultado Nullo
Where location like '%brazil%' -- selecionar apenas a porcentagem do Brasil
order by 1,2



-- Verificar TOTAL DE CASOS vs POPULA��O
-- Mostrar qual a porcentagem da popula��o contraiu COVID no Brasil
Select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
From Project1_Covid..CovidDeaths
where continent is not null --vamos isolar o resultado Nullo
where location like '%brazil%'
order by 1,2


-- >>QUAL A PORCENTAGEM DE INFEC��O DE TODOS OS PA�SES? - POPULA��O vs INFECTADOS

Select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
From Project1_Covid..CovidDeaths
where continent is not null --vamos isolar o resultado Nullo
Order by 1,2

-- >>QUAIS OS PA�SES COM MAIORES �NDICES DE INFEC��O COMPARADO COM A POPULA��O?
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Project1_Covid..CovidDeaths
where continent is not null --vamos isolar o resultado Nullo
Group by Location, population
order by PercentPopulationInfected desc --organizar pela popula��o mais alta!


-- >>QUAIS OS PAISES COM MAIORES MORTES POR POPULA��O?
-- temos um problema com esse c�digo pq o resultado dele est� agrupando continentes, por exemplo: world, North America, South America, e nao queremos isso.
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount --fun��o "cast as int" estamos pegando um n�mero varchar e convertendo em n�mero inteiro
From Project1_Covid..CovidDeaths
--Where location like '%brazil%'
where continent is not null --vamos isolar o resultado Nullo
Group by location
order by TotalDeathCount desc
-- com a linha de c�digo "where continetnt is not null" nos anulamos o continente, para no visual n�o haja aquele problema de puxar continentes inteiros, para nos nessa pesquisa n�o � importante

--vamos buscar o mesmo resultado que no c�digo acima por�m agora vamos olhar por continentes

-- >>QUAIS OS CONTINENTES COM MAIORES MORTES POR POPULA��O?
Select continent, MAX(cast(total_deaths as int)) as TotalDeathAcountPerContinent
From Project1_Covid..CovidDeaths
where continent is not null --vamos isolar o resultado Nullo
Group by continent
order by TotalDeathAcountPerContinent desc


-- >>CONTINENTES COM A MAIOR CONTAGEM DE MORTES
Select continent, MAX (cast(total_deaths as int)) as TotalDeathAcountPerContinent
From Project1_Covid..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathAcountPerContinent desc
-- voce pode usar esse codigo para ver os detalhes dos paises, vc tem que pensar que se vc tem o resultado dos continentes, vc tem o resultado detalhado por cada pa�s!


-- >>N�MEROS GLOBAIS PORCENTAGE DE MORTES POR TOTAL DE CASOS POR DIA 
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as GlobalNumbersDeathPercentage
From Project1_Covid..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- >> NUMEROS GLOBAIS
select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PorcentagemDeMortesMundial
From Project1_Covid..CovidDeaths
where continent is not null
order by 1,2
-- isso nos da o resultado de que 1,4% de pessoas que contrairam o Covid no mundo, morreram



-- Agora vamos olhar para a tabela de vacinas
Select *
From Project1_Covid..CovidVaccnations
-- vamos usar as colunas Total de vacinas, pessoas vacinadas e pessoas infectadas, para isso vamos juntas as duas tabelas;
--vamos juntas as duas tabelas no "local" e "data"
--Para juntar vamos usar o c�digo "JOIN, ON, =, and"

Select * 
From Project1_Covid..CovidDeaths dea --"dea" foi um apelido que dei a tabela para que n�o precise digitar o nome inteiro dela nas pr�ximas vezes
Join Project1_Covid..CovidVaccnations vac --"vac" foi um apelido que dei a tabela para que n�o precise digitar o nome inteiro dela nas pr�ximas vezes
	On dea.location = vac.location
	and dea.date = vac.date
	-- "on = ligar" a tabela "dea" e "vac" pela localidade
	-- "and = e" a tabela "dea" e "vac" pela data
		--com esse codigo teremos todas essas informa��es em uma tabela s�;

--depois de ter juntado as duas tabelas, vamos olhar a quantidade total da popula��o e quantas delas est�o vacinadas;

-- >>OLHAR PARA O TOTAL DA POPULA��O vs VACINA��O
-- usaremos a fun��o de particionar e dividir pq toda vez que zera a contagem de vacinas e chega em uma nova localidade ele esta continuando o valor e n�o queremos isso, queremos um valor real
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From Project1_Covid..CovidDeaths dea
join Project1_Covid..CovidVaccnations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
-- agora que chegamos nesse resultado, vamos usar esse n�mero de RollingPeoplVaccinated e dvidir pelo numero de popula��o para saber de fato Quantidade de popula��o VS Pessoas vacinadas

--para isso precisamos criar uma tabela nova, tem varias formas de fazer, nesse caso usaremos o CTE

-->> CTE
With PopulationvsVaccinations  -- nome que daremos a essa fun��o. (Numero de popula��o VS Vacinas aplicadas) / Proxia fun��o � espec�ficas quais colunas iremos usar.
	(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
From Project1_Covid..CovidDeaths dea
Join Project1_Covid..CovidVaccnations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
--agora usaremos isso para criar calculos adicionais.
Select *, (RollingPeopleVaccinated/Population)*100
From PopulationvsVaccinations





-- VAMOS CRIAR UMA TABELA TEMPOR�RIA (para calcular o total sem a coluna "Date") E CHAMAR DE PORCENTAGEM DA POPULA��O VACINADA;

Drop table if exists #PercentPopulationVaccinated -- digamos que encontramos um erro dentro da nossa tabela e n�o podemos executar esse codigo novamente pois essa tabela ja esta criada, para contornar isso � muito f�cil,
														--temos que digitar esse codigo de DROP TABLE EXISTS antes das linhas de c�digos de criar tabela;
														--o que esse c�digo vai fazer? ele vai excluir uma tabela com o nome ja existente, que � o nosso caso, e o codigo embaixo vai criala novamente.

Create table #PercentPopulationVaccinated
(
-- vamos definir o tipo de dados de cada coluna
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

Insert into #PercentPopulationVaccinated
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
	From Project1_Covid..CovidDeaths dea
	join Project1_Covid..CovidVaccnations vac
		On dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	

--agora vamos chamar a tabela que acabamos de criar
Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- >>CRIAR NOSSA VIS�O PARA ARMAZENAR DADOS PARA VISUALIZA��ES FUTURAS

--isso agora � permanente, � uma tabela de vis�o com resultados permanentes, n�s podemos chamalas e visualizalas;
Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated

	From Project1_Covid..CovidDeaths dea
	join Project1_Covid..CovidVaccnations vac
		On dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null

	Select *
	From PercentPopulationVaccinated