
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

-- Primeiramente identifiquei que os meus dados não eram numericos!

-- codigo para alterar o tipo de dados de uma coluna para numéricos
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



-- Verificar TOTAL DE CASOS vs POPULAÇÃO
-- Mostrar qual a porcentagem da população contraiu COVID no Brasil
Select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
From Project1_Covid..CovidDeaths
where continent is not null --vamos isolar o resultado Nullo
where location like '%brazil%'
order by 1,2


-- >>QUAL A PORCENTAGEM DE INFECÇÃO DE TODOS OS PAÍSES? - POPULAÇÃO vs INFECTADOS

Select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
From Project1_Covid..CovidDeaths
where continent is not null --vamos isolar o resultado Nullo
Order by 1,2

-- >>QUAIS OS PAÍSES COM MAIORES ÍNDICES DE INFECÇÃO COMPARADO COM A POPULAÇÃO?
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Project1_Covid..CovidDeaths
where continent is not null --vamos isolar o resultado Nullo
Group by Location, population
order by PercentPopulationInfected desc --organizar pela população mais alta!


-- >>QUAIS OS PAISES COM MAIORES MORTES POR POPULAÇÃO?
-- temos um problema com esse código pq o resultado dele está agrupando continentes, por exemplo: world, North America, South America, e nao queremos isso.
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount --função "cast as int" estamos pegando um número varchar e convertendo em número inteiro
From Project1_Covid..CovidDeaths
--Where location like '%brazil%'
where continent is not null --vamos isolar o resultado Nullo
Group by location
order by TotalDeathCount desc
-- com a linha de código "where continetnt is not null" nos anulamos o continente, para no visual não haja aquele problema de puxar continentes inteiros, para nos nessa pesquisa não é importante

--vamos buscar o mesmo resultado que no código acima porém agora vamos olhar por continentes

-- >>QUAIS OS CONTINENTES COM MAIORES MORTES POR POPULAÇÃO?
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
-- voce pode usar esse codigo para ver os detalhes dos paises, vc tem que pensar que se vc tem o resultado dos continentes, vc tem o resultado detalhado por cada país!


-- >>NÚMEROS GLOBAIS PORCENTAGE DE MORTES POR TOTAL DE CASOS POR DIA 
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
--Para juntar vamos usar o código "JOIN, ON, =, and"

Select * 
From Project1_Covid..CovidDeaths dea --"dea" foi um apelido que dei a tabela para que não precise digitar o nome inteiro dela nas próximas vezes
Join Project1_Covid..CovidVaccnations vac --"vac" foi um apelido que dei a tabela para que não precise digitar o nome inteiro dela nas próximas vezes
	On dea.location = vac.location
	and dea.date = vac.date
	-- "on = ligar" a tabela "dea" e "vac" pela localidade
	-- "and = e" a tabela "dea" e "vac" pela data
		--com esse codigo teremos todas essas informações em uma tabela só;

--depois de ter juntado as duas tabelas, vamos olhar a quantidade total da população e quantas delas estão vacinadas;

-- >>OLHAR PARA O TOTAL DA POPULAÇÃO vs VACINAÇÃO
-- usaremos a função de particionar e dividir pq toda vez que zera a contagem de vacinas e chega em uma nova localidade ele esta continuando o valor e não queremos isso, queremos um valor real
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From Project1_Covid..CovidDeaths dea
join Project1_Covid..CovidVaccnations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
-- agora que chegamos nesse resultado, vamos usar esse número de RollingPeoplVaccinated e dvidir pelo numero de população para saber de fato Quantidade de população VS Pessoas vacinadas

--para isso precisamos criar uma tabela nova, tem varias formas de fazer, nesse caso usaremos o CTE

-->> CTE
With PopulationvsVaccinations  -- nome que daremos a essa função. (Numero de população VS Vacinas aplicadas) / Proxia função é específicas quais colunas iremos usar.
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





-- VAMOS CRIAR UMA TABELA TEMPORÁRIA (para calcular o total sem a coluna "Date") E CHAMAR DE PORCENTAGEM DA POPULAÇÃO VACINADA;

Drop table if exists #PercentPopulationVaccinated -- digamos que encontramos um erro dentro da nossa tabela e não podemos executar esse codigo novamente pois essa tabela ja esta criada, para contornar isso é muito fácil,
														--temos que digitar esse codigo de DROP TABLE EXISTS antes das linhas de códigos de criar tabela;
														--o que esse código vai fazer? ele vai excluir uma tabela com o nome ja existente, que é o nosso caso, e o codigo embaixo vai criala novamente.

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



-- >>CRIAR NOSSA VISÃO PARA ARMAZENAR DADOS PARA VISUALIZAÇÕES FUTURAS

--isso agora é permanente, é uma tabela de visão com resultados permanentes, nós podemos chamalas e visualizalas;
Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated

	From Project1_Covid..CovidDeaths dea
	join Project1_Covid..CovidVaccnations vac
		On dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null

	Select *
	From PercentPopulationVaccinated