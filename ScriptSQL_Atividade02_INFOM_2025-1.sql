-------------------------------------------------------------------------------------
-- FACULDADE DE TECNOLOGIA DE SÃO JOSÉ DO RIO PRETO - FATEC
-- CURSO: TECNOLOGIA EM INFORMÁTICA PARA NEGÓCIOS - MANHÃ
-- DISCIPLINA: ADMINISTRAÇÃO DE BANCO DE DADOS
-- PROFA.: VALÉRIA MARIA VOLPE
-- ALUNO 1: Reginaldo Morikawa
-- ALUNO 2: Tháira Letícia Ibraim Lulio
-- DATA DA ENTREGA: 25 DE JUNHO DE 2025 - ATÉ 22h
-------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------
-- Criação do Banco de Dados
-------------------------------------------------------------------------------------
create database Seguros_INFOM
go

-------------------------------------------------------------------------------------
-- Acessando o Banco de Dados
------------------------------------------------------------------------------------
use Seguros_INFOM
go

-------------------------------------------------------------------------------------
-- Criação das tabelas
-------------------------------------------------------------------------------------
create table Pessoas
(
	idPessoa		int		not null	primary key		identity,
	nome		varchar(50)	not null,
	cpf			varchar(14)	not null	unique,
	dataNasc	date		not null,
	status			int			null	check(status in (1,2,3))
)
go

create table Clientes
(
	pessoaId	int			not null	primary key,
	nroCNH		varchar(12)	not null	unique,
	idade		int			not null,
	foreign key(pessoaId)	references	Pessoas(idPessoa)
)
go

create table Corretores
(
	pessoaid	int			not null	primary key		references Pessoas(idPessoa),
	nroRegistro	varchar(14)	not null,
	telefone	varchar(15)	not null
)
go

create table Enderecos
(
	idEnd		int			not null	primary key		identity,
	rua			varchar(50)	not null,
	nro			varchar(10)	not null,
	complemento varchar(30)		null,
	bairro		varchar(50)	not null,
	cep			varchar(9)	not null,
	cidade		varchar(50)	not null,
	estado		varchar(2)	not null,
	clienteId	int			not null	references	Clientes(pessoaId)	
)
go

create table Seguros
(
	idSeguro		int				not null	primary key		identity,
	valorFranquia	money			not null	check(valorFranquia > 0),
	valor			money			not null	check(valor > 0),
	dataInicio		date			not null,
	dataFim			date			not null,
	premio			decimal(5,2)	not null	default 0.10,
	clienteId		int				not null	references	Clientes(pessoaId),
	corretorId		int				not null	references	Corretores(pessoaId),
	check(dataInicio < dataFim)
)
go

create table Comissoes
(
	idComissao		int		not null	primary key		identity,
	valor			money	not null	check(valor >= 0),
	dataPgto		date	not null,
	-- status = 1 pago	status = 2 pendente
	status			int			null	check(status in (1,2))	default 2,
	seguroId		int		not null	references	Seguros(idSeguro),
	corretorId		int		not	null	references	Corretores(pessoaId)
)
go

create table Carros
(
	idCarro		int			not null	primary key		identity,
	placa		varchar(7)	not null	unique,
	marca		varchar(20)	not null,
	modelo		varchar(20)		null,
	cor			varchar(10)	not null,
	seguroId	int			not null	references	Seguros(idSeguro)
)
go

create table Sinistros
(
	carroId		int			not null,
	seguroId	int			not null,
	dataS		date		not null,
	hora		time		not null,
	localS	varchar(50)		not null,
	obs		varchar(500)	not null,
	primary key	(carroId, seguroId, dataS),
	foreign key	(carroId)	references	Carros(idCarro),
	foreign Key	(seguroId)	references	Seguros(idSeguro)
)
go