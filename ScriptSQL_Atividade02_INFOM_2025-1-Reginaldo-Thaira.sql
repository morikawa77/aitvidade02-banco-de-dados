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
-- CRIAÇÃO DO BANCO DE DADOS
-------------------------------------------------------------------------------------
create database Seguros_INFOM
go

-------------------------------------------------------------------------------------
-- ACESSANDO O BANCO DE DADOS
-------------------------------------------------------------------------------------
use Seguros_INFOM
go

-------------------------------------------------------------------------------------
-- CRIAÇÃO DAS TABELAS
-------------------------------------------------------------------------------------

-- Tabela Pessoas
create table Pessoas (
    idPessoa    int             not null primary key identity,
    nome        varchar(50)     not null,
    cpf         varchar(14)     not null unique,
    dataNasc    date            not null,
    status      int             null check(status in (1, 2, 3))
)
go

-- Tabela Clientes
create table Clientes (
    pessoaId    int             not null primary key,
    nroCNH      varchar(12)     not null unique,
    idade       int             not null,
    foreign key(pessoaId) references Pessoas(idPessoa)
)
go

-- Tabela Corretores
create table Corretores (
    pessoaId        int             not null primary key references Pessoas(idPessoa),
    nroRegistro     varchar(14)     not null,
    telefone        varchar(15)     not null
)
go

-- Tabela Endereços
create table Enderecos (
    idEnd           int             not null primary key identity,
    rua             varchar(50)     not null,
    nro             varchar(10)     not null,
    complemento     varchar(30)     null,
    bairro          varchar(50)     not null,
    cep             varchar(9)      not null,
    cidade          varchar(50)     not null,
    estado          varchar(2)      not null,
    clienteId       int             not null references Clientes(pessoaId)
)
go

-- Tabela Seguros
create table Seguros (
    idSeguro        int             not null primary key identity,
    valorFranquia   money           not null check(valorFranquia > 0),
    valor           money           not null check(valor > 0),
    dataInicio      date            not null,
    dataFim         date            not null,
    premio          decimal(5, 2)   not null default 0.10,
    clienteId       int             not null references Clientes(pessoaId),
    corretorId      int             not null references Corretores(pessoaId),
    check(dataInicio < dataFim)
)
go

-- Tabela Comissões
create table Comissoes (
    idComissao      int         not null primary key identity,
    valor           money       not null check(valor >= 0),
    dataPgto        date        not null,
    -- status = 1 pago, status = 2 pendente
    status          int         null check(status in (1, 2)) default 2,
    seguroId        int         not null references Seguros(idSeguro),
    corretorId      int         not null references Corretores(pessoaId)
)
go

-- Tabela Carros
create table Carros (
    idCarro     int             not null primary key identity,
    placa       varchar(7)      not null unique,
    marca       varchar(20)     not null,
    modelo      varchar(20)     null,
    cor         varchar(10)     not null,
    seguroId    int             not null references Seguros(idSeguro)
)
go

-- Tabela Sinistros
create table Sinistros (
    carroId     int             not null,
    seguroId    int             not null,
    dataS       date            not null,
    hora        time            not null,
    localS      varchar(50)     not null,
    obs         varchar(500)    not null,
    primary key (carroId, seguroId, dataS),
    foreign key (carroId) references Carros(idCarro),
    foreign key (seguroId) references Seguros(idSeguro)
)
go

-------------------------------------------------------------------------------------
-- STORED PROCEDURES
-------------------------------------------------------------------------------------

-- 1) Procedure para cadastrar um Cliente novo, seu carro e seguro
create or alter procedure CadastrarClienteCarroSeguro 
    @nome           varchar(50),
    @cpf            varchar(14),
    @dataNasc       date,
    @statusPessoa   int,
    @nroCNH         varchar(12),
    @idade          int,
    @valorFranquia  money,
    @valorSeguro    money,
    @dataInicio     date,
    @dataFim        date,
    @premio         decimal(5, 2) = 0.10,
    @corretorId     int,
    @placa          varchar(7),
    @marca          varchar(20),
    @modelo         varchar(20),
    @corCarro       varchar(10) 
as
begin
    -- Inserir na tabela Pessoas
    insert into Pessoas (nome, cpf, dataNasc, status)
    values (@nome, @cpf, @dataNasc, @statusPessoa)
    
    declare @idPessoa int
    set @idPessoa = SCOPE_IDENTITY()
    
    -- Inserir na tabela Clientes
    insert into Clientes (pessoaId, nroCNH, idade)
    values (@idPessoa, @nroCNH, @idade)
    
    -- Inserir na tabela Seguros
    insert into Seguros (
        valorFranquia,
        valor,
        dataInicio,
        dataFim,
        premio,
        clienteId,
        corretorId
    )
    values (
        @valorFranquia,
        @valorSeguro,
        @dataInicio,
        @dataFim,
        @premio,
        @idPessoa,
        @corretorId
    )
    
    declare @idSeguro int
    set @idSeguro = SCOPE_IDENTITY()
    
    -- Inserir na tabela Carros
    insert into Carros (placa, marca, modelo, cor, seguroId)
    values (@placa, @marca, @modelo, @corCarro, @idSeguro)
end
go

-- 2) Procedure para cadastrar um sinistro
create or alter procedure CadastrarSinistro 
    @carroId    int,
    @seguroId   int,
    @dataS      date,
    @hora       time,
    @localS     varchar(50),
    @obs        varchar(500) 
as
begin
        insert into Sinistros (carroId, seguroId, dataS, hora, localS, obs)
    values (@carroId, @seguroId, @dataS, @hora, @localS, @obs)
end
go

-------------------------------------------------------------------------------------
-- VIEWS
-------------------------------------------------------------------------------------

-- 3) View que consulta nome e status do cliente, dados do seguro e do carro
create or alter view vw_ClientesSegurosCarros as
select 
    p.nome as NomeCliente,
    p.status as StatusCliente,
    s.idSeguro as NumeroSeguro,
    s.valorFranquia,
    s.premio,
    c.idCarro,
    c.placa,
    c.marca,
    c.modelo,
    c.cor
from Pessoas p
    inner join Clientes cli on cli.pessoaId = p.idPessoa
    inner join Seguros s on s.clienteId = cli.pessoaId
    inner join Carros c on c.seguroId = s.idSeguro
go

-- 4) View para consultar todos os clientes
create or alter view vw_TodosClientes as
select 
    p.idPessoa,
    p.nome,
    p.cpf,
    p.dataNasc,
    p.status,
    c.nroCNH,
    c.idade,
    e.rua,
    e.nro as numero,
    e.complemento,
    e.bairro,
    e.cep,
    e.cidade,
    e.estado
from Pessoas p
    inner join Clientes c on c.pessoaId = p.idPessoa
    inner join Enderecos e on e.clienteId = c.pessoaId
go

-- 5) View que consulta o número de sinistros por carro
create or alter view vw_QuantidadeSinistrosPorCarro as
select 
    c.placa,
    count(s.carroId) as QuantidadeSinistros
from Carros c
    left join Sinistros s on s.carroId = c.idCarro
group by c.placa
go

-------------------------------------------------------------------------------------
-- TRIGGERS / TABELA HistoricoSinistros
-------------------------------------------------------------------------------------

-- 6) Trigger que inativa cliente ao invés de excluir
create or alter trigger trg_Clientes_InativarAoExcluir on Clientes 
instead of delete 
as 
begin
    -- Atualiza o status da pessoa para inativo (3)
    update Pessoas
    set status = 3
    from Pessoas p
        inner join deleted d on d.pessoaId = p.idPessoa
end
go

-- 7) Tabela HistoricoSinistros: mesmos dados do Sinistro e a data da abertura do sinistro e quem foi o usuário que cadastrou o sinistro.
-- Tabela Histórico de Sinistros
create or alter table HistoricoSinistros (
    carroId         int             not null,
    seguroId        int             not null,
    dataS           date            not null,
    hora            time            not null,
    localS          varchar(50)     not null,
    obs             varchar(500)    not null,
    dataAbertura    datetime        not null default getdate(),
    usuario         varchar(50)     not null,
    primary key (carroId, seguroId, dataS, dataAbertura),
    foreign key (carroId) references Carros(idCarro),
    foreign key (seguroId) references Seguros(idSeguro)
)
go

-- 8) Trigger que registra sinistros no histórico e aplica desconto no prêmio
create or alter trigger trg_AposInserirSinistro on Sinistros
after insert 
as 
begin
        -- Inserir no HistoricoSinistros
    insert into HistoricoSinistros (
        carroId,
        seguroId,
        dataS,
        hora,
        localS,
        obs,
        dataAbertura,
        usuario
    )
    select 
        i.carroId,
        i.seguroId,
        i.dataS,
        i.hora,
        i.localS,
        i.obs,
        getdate(),
        SYSTEM_USER
    from inserted i
    
    -- Aplicar desconto de 10% no prêmio do seguro relacionado
    update Seguros
    set premio = premio * 0.9
    from Seguros s
        inner join inserted i on i.seguroId = s.idSeguro
end
go

-- 9) Trigger que cadastra comissão quando seguro é criado
create or alter trigger trg_AposInserirSeguro on Seguros
after insert 
as 
begin
        insert into Comissoes (
        valor,
        dataPgto,
        status,
        seguroId,
        corretorId
    )
    select 
        inserted.valor * inserted.premio,  -- valor da comissão
        getdate(),                         -- data de pagamento
        2,                                 -- status padrão: 2 = pendente
        inserted.idSeguro,
        inserted.corretorId
    from inserted
end
go

-------------------------------------------------------------------------------------
-- FUNCTIONS
-------------------------------------------------------------------------------------

-- 10) Função que calcula o valor da comissão
create or alter function fn_CalculaComissao (
    @valorBase money,
    @percentual decimal(5, 2)
) 
returns money 
as 
begin
    return @valorBase * @percentual
end
go

-- 11) Atualizar valor da comissão usando a função
update Comissoes
set valor = dbo.fn_CalculaComissao(s.valor, s.premio)
from Comissoes c
    inner join Seguros s on c.seguroId = s.idSeguro
go

-------------------------------------------------------------------------------------
-- INSERÇÃO DE DADOS NAS TABELAS POR INSERT OU USANDO STORED PROCEDURES
-------------------------------------------------------------------------------------
-- Inserir dados na tabela Pessoas para serem Corretores
-- Estes IDs de pessoa (1, 2, 3) serão usados como chave estrangeira em Corretores.
insert into Pessoas (nome, cpf, dataNasc, status) values
('Ana Paula Silva', '111.111.111-11', '1980-01-15', 1), -- Corretor 1 (idPessoa: 1)
('Bruno Costa', '222.222.222-22', '1975-05-20', 1),    -- Corretor 2 (idPessoa: 2)
('Carla Dias', '333.333.333-33', '1990-11-30', 1)    -- Corretor 3 (idPessoa: 3)
go

-- Inserir dados na tabela Corretores
-- Associa os corretores às Pessoas recém-criadas.
insert into Corretores (pessoaId, nroRegistro, telefone) values
(1, 'REG-0001/SP', '(11)98765-4321'),
(2, 'REG-0002/RJ', '(21)91234-5678'),
(3, 'REG-0003/MG', '(31)99876-1234')
go

-- Chamadas da Stored Procedure CadastrarClienteCarroSeguro (10 cadastros)
-- Esta SP insere dados em Pessoas, Clientes, Seguros e Carros.
-- Os IDs de corretor (1, 2 ou 3) são usados para associar o seguro a um corretor.
-- Os valores de idPessoa para clientes começarão a partir de 4, pois 1, 2 e 3 foram usados para corretores.
-- Assumimos que idSeguro e idCarro serão gerados sequencialmente a partir de 1 com cada chamada.

-- Cliente 1
exec CadastrarClienteCarroSeguro
    @nome = 'Mariana Oliveira',
    @cpf = '444.444.444-44',
    @dataNasc = '1992-03-10',
    @statusPessoa = 1, -- Ativo
    @nroCNH = '12345678901',
    @idade = 32,
    @valorFranquia = 1500.00,
    @valorSeguro = 50000.00,
    @dataInicio = '2024-01-01',
    @dataFim = '2025-01-01',
    @premio = 0.12,
    @corretorId = 1,
    @placa = 'ABC1A23',
    @marca = 'Chevrolet',
    @modelo = 'Onix',
    @corCarro = 'Preto'
go

-- Cliente 2
exec CadastrarClienteCarroSeguro
    @nome = 'João Santos',
    @cpf = '555.555.555-55',
    @dataNasc = '1985-07-22',
    @statusPessoa = 1, -- Ativo
    @nroCNH = '12345678902',
    @idade = 39,
    @valorFranquia = 2000.00,
    @valorSeguro = 75000.00,
    @dataInicio = '2024-02-15',
    @dataFim = '2025-02-15',
    @premio = 0.10,
    @corretorId = 2,
    @placa = 'BCD2B34',
    @marca = 'Ford',
    @modelo = 'Ka',
    @corCarro = 'Branco'
go

-- Cliente 3
exec CadastrarClienteCarroSeguro
    @nome = 'Fernanda Lima',
    @cpf = '666.666.666-66',
    @dataNasc = '1978-11-05',
    @statusPessoa = 1, -- Ativo
    @nroCNH = '12345678903',
    @idade = 46,
    @valorFranquia = 2500.00,
    @valorSeguro = 120000.00,
    @dataInicio = '2024-03-01',
    @dataFim = '2025-03-01',
    @premio = 0.08,
    @corretorId = 3,
    @placa = 'CDE3C45',
    @marca = 'Volkswagen',
    @modelo = 'Virtus',
    @corCarro = 'Prata'
go

-- Cliente 4
exec CadastrarClienteCarroSeguro
    @nome = 'Pedro Almeida',
    @cpf = '777.777.777-77',
    @dataNasc = '1995-02-28',
    @statusPessoa = 1, -- Ativo
    @nroCNH = '12345678904',
    @idade = 29,
    @valorFranquia = 1800.00,
    @valorSeguro = 60000.00,
    @dataInicio = '2024-04-10',
    @dataFim = '2025-04-10',
    @premio = 0.15,
    @corretorId = 1,
    @placa = 'DEF4D56',
    @marca = 'Fiat',
    @modelo = 'Cronos',
    @corCarro = 'Azul'
go

-- Cliente 5
exec CadastrarClienteCarroSeguro
    @nome = 'Patricia Gomes',
    @cpf = '888.888.888-88',
    @dataNasc = '1989-09-12',
    @statusPessoa = 1, -- Ativo
    @nroCNH = '12345678905',
    @idade = 35,
    @valorFranquia = 2200.00,
    @valorSeguro = 90000.00,
    @dataInicio = '2024-05-01',
    @dataFim = '2025-05-01',
    @premio = 0.11,
    @corretorId = 2,
    @placa = 'EFG5E67',
    @marca = 'Renault',
    @modelo = 'Kwid',
    @corCarro = 'Vermelho'
go

-- Cliente 6
exec CadastrarClienteCarroSeguro
    @nome = 'Rafael Souza',
    @cpf = '999.999.999-99',
    @dataNasc = '1982-06-03',
    @statusPessoa = 1, -- Ativo
    @nroCNH = '12345678906',
    @idade = 42,
    @valorFranquia = 2800.00,
    @valorSeguro = 150000.00,
    @dataInicio = '2024-06-20',
    @dataFim = '2025-06-20',
    @premio = 0.07,
    @corretorId = 3,
    @placa = 'FGH6F78',
    @marca = 'Hyundai',
    @modelo = 'HB20',
    @corCarro = 'Cinza'
go

-- Cliente 7
exec CadastrarClienteCarroSeguro
    @nome = 'Larissa Costa',
    @cpf = '101.101.101-01',
    @dataNasc = '1998-01-25',
    @statusPessoa = 1, -- Ativo
    @nroCNH = '12345678907',
    @idade = 26,
    @valorFranquia = 1400.00,
    @valorSeguro = 45000.00,
    @dataInicio = '2024-07-01',
    @dataFim = '2025-07-01',
    @premio = 0.18,
    @corretorId = 1,
    @placa = 'GHI7G89',
    @marca = 'Toyota',
    @modelo = 'Corolla',
    @corCarro = 'Branco'
go

-- Cliente 8
exec CadastrarClienteCarroSeguro
    @nome = 'Gustavo Pereira',
    @cpf = '112.112.112-12',
    @dataNasc = '1970-04-18',
    @statusPessoa = 1, -- Ativo
    @nroCNH = '12345678908',
    @idade = 54,
    @valorFranquia = 3000.00,
    @valorSeguro = 180000.00,
    @dataInicio = '2024-08-10',
    @dataFim = '2025-08-10',
    @premio = 0.06,
    @corretorId = 2,
    @placa = 'HIJ8H90',
    @marca = 'Honda',
    @modelo = 'Civic',
    @corCarro = 'Azul'
go

-- Cliente 9
exec CadastrarClienteCarroSeguro
    @nome = 'Sofia Martins',
    @cpf = '123.123.123-23',
    @dataNasc = '1993-10-01',
    @statusPessoa = 1, -- Ativo
    @nroCNH = '12345678909',
    @idade = 31,
    @valorFranquia = 1700.00,
    @valorSeguro = 55000.00,
    @dataInicio = '2024-09-05',
    @dataFim = '2025-09-05',
    @premio = 0.13,
    @corretorId = 3,
    @placa = 'IJK9I01',
    @marca = 'Nissan',
    @modelo = 'Kicks',
    @corCarro = 'Preto'
go

-- Cliente 10
exec CadastrarClienteCarroSeguro
    @nome = 'Diego Rocha',
    @cpf = '134.134.134-34',
    @dataNasc = '1987-12-07',
    @statusPessoa = 1, -- Ativo
    @nroCNH = '12345678910',
    @idade = 37,
    @valorFranquia = 2100.00,
    @valorSeguro = 80000.00,
    @dataInicio = '2024-10-20',
    @dataFim = '2025-10-20',
    @premio = 0.09,
    @corretorId = 1,
    @placa = 'JKL0J12',
    @marca = 'BMW',
    @modelo = 'X1',
    @corCarro = 'Branco'
go

-- Inserir dados na tabela Enderecos (10 endereços, um para cada cliente)
-- Os 'clienteId' aqui são recuperados dinamicamente com base no CPF, garantindo que o idPessoa correto seja utilizado.
insert into Enderecos (rua, nro, complemento, bairro, cep, cidade, estado, clienteId)
values ('Rua das Flores', '100', 'Ap 101', 'Centro', '12345-678', 'São Paulo', 'SP', (select idPessoa from Pessoas where cpf = '444.444.444-44'))
go

insert into Enderecos (rua, nro, complemento, bairro, cep, cidade, estado, clienteId)
values ('Avenida Principal', '250', null, 'Jardins', '87654-321', 'Rio de Janeiro', 'RJ', (select idPessoa from Pessoas where cpf = '555.555.555-55'))
go

insert into Enderecos (rua, nro, complemento, bairro, cep, cidade, estado, clienteId)
values ('Rua do Comércio', '30', 'Loja B', 'Vila Nova', '54321-876', 'Belo Horizonte', 'MG', (select idPessoa from Pessoas where cpf = '666.666.666-66'))
go

insert into Enderecos (rua, nro, complemento, bairro, cep, cidade, estado, clienteId)
values ('Travessa da Paz', '55', 'Casa', 'Liberdade', '98765-432', 'Curitiba', 'PR', (select idPessoa from Pessoas where cpf = '777.777.777-77'))
go

insert into Enderecos (rua, nro, complemento, bairro, cep, cidade, estado, clienteId)
values ('Alameda dos Anjos', '120', null, 'Boa Vista', '32109-876', 'Porto Alegre', 'RS', (select idPessoa from Pessoas where cpf = '888.888.888-88'))
go

insert into Enderecos (rua, nro, complemento, bairro, cep, cidade, estado, clienteId)
values ('Rua Nova', '700', 'Bl. A', 'Campinas', '10987-654', 'Salvador', 'BA', (select idPessoa from Pessoas where cpf = '999.999.999-99'))
go

insert into Enderecos (rua, nro, complemento, bairro, cep, cidade, estado, clienteId)
values ('Avenida do Sol', '15', null, 'Parque Imperial', '67890-123', 'Fortaleza', 'CE', (select idPessoa from Pessoas where cpf = '101.101.101-01'))
go

insert into Enderecos (rua, nro, complemento, bairro, cep, cidade, estado, clienteId)
values ('Rua da Montanha', '99', 'Sítio', 'Alto da Serra', '23456-789', 'Brasília', 'DF', (select idPessoa from Pessoas where cpf = '112.112.112-12'))
go

insert into Enderecos (rua, nro, complemento, bairro, cep, cidade, estado, clienteId)
values ('Praça da Liberdade', '10', 'Ed. Comercial', 'Centro', '78901-234', 'Recife', 'PE', (select idPessoa from Pessoas where cpf = '123.123.123-23'))
go

insert into Enderecos (rua, nro, complemento, bairro, cep, cidade, estado, clienteId)
values ('Rua das Palmeiras', '20', null, 'Morumbi', '45678-901', 'São José do Rio Preto', 'SP', (select idPessoa from Pessoas where cpf = '134.134.134-34'))
go


-- Chamadas da Stored Procedure CadastrarSinistro (10 cadastros)
-- É crucial que os 'carroId' e 'seguroId' existam no banco de dados.
-- Assumindo que os IDs de Carro e Seguro foram gerados sequencialmente a partir de 1 pelas 10 chamadas anteriores
-- da SP 'CadastrarClienteCarroSeguro'.
-- Ou seja, o primeiro carro/seguro criado pela SP terá id 1, o segundo id 2, e assim por diante.

-- Sinistro 1 (Cliente 1, Carro 1, Seguro 1)
exec CadastrarSinistro
    @carroId = 1,
    @seguroId = 1,
    @dataS = '2024-03-20',
    @hora = '10:30:00',
    @localS = 'Avenida Brasil, 123',
    @obs = 'Colisão leve na parte traseira.'
go

-- Sinistro 2 (Cliente 2, Carro 2, Seguro 2)
exec CadastrarSinistro
    @carroId = 2,
    @seguroId = 2,
    @dataS = '2024-04-05',
    @hora = '15:00:00',
    @localS = 'Rua das Gaivotas, 45',
    @obs = 'Pequeno amassado na porta do motorista.'
go

-- Sinistro 3 (Cliente 3, Carro 3, Seguro 3)
exec CadastrarSinistro
    @carroId = 3,
    @seguroId = 3,
    @dataS = '2024-05-10',
    @hora = '08:45:00',
    @localS = 'Praça da Sé, próximo ao semáforo.',
    @obs = 'Vidro lateral quebrado.'
go

-- Sinistro 4 (Cliente 4, Carro 4, Seguro 4)
exec CadastrarSinistro
    @carroId = 4,
    @seguroId = 4,
    @dataS = '2024-06-01',
    @hora = '11:15:00',
    @localS = 'Rodovia Castelo Branco, KM 100.',
    @obs = 'Pneu furado e roda danificada.'
go

-- Sinistro 5 (Cliente 5, Carro 5, Seguro 5)
exec CadastrarSinistro
    @carroId = 5,
    @seguroId = 5,
    @dataS = '2024-07-14',
    @hora = '18:00:00',
    @localS = 'Estacionamento do Shopping ABC.',
    @obs = 'Arranhão na lateral direita.'
go

-- Sinistro 6 (Cliente 6, Carro 6, Seguro 6)
exec CadastrarSinistro
    @carroId = 6,
    @seguroId = 6,
    @dataS = '2024-08-22',
    @hora = '09:00:00',
    @localS = 'Rua 7 de Setembro, 500.',
    @obs = 'Dano no para-choque dianteiro.'
go

-- Sinistro 7 (Cliente 7, Carro 7, Seguro 7)
exec CadastrarSinistro
    @carroId = 7,
    @seguroId = 7,
    @dataS = '2024-09-03',
    @hora = '14:00:00',
    @localS = 'Avenida Atlântica, em frente ao número 80.',
    @obs = 'Farol esquerdo quebrado.'
go

-- Sinistro 8 (Cliente 8, Carro 8, Seguro 8)
exec CadastrarSinistro
    @carroId = 8,
    @seguroId = 8,
    @dataS = '2024-10-11',
    @hora = '20:00:00',
    @localS = 'Garagem do edifício Central Park.',
    @obs = 'Retrovisor direito danificado.'
go

-- Sinistro 9 (Cliente 9, Carro 9, Seguro 9)
exec CadastrarSinistro
    @carroId = 9,
    @seguroId = 9,
    @dataS = '2024-11-25',
    @hora = '07:30:00',
    @localS = 'Marginal Pinheiros, sentido centro.',
    @obs = 'Colisão traseira, danos leves.'
go

-- Sinistro 10 (Cliente 10, Carro 10, Seguro 10)
exec CadastrarSinistro
    @carroId = 10,
    @seguroId = 10,
    @dataS = '2024-12-30',
    @hora = '16:45:00',
    @localS = 'Rua do Bosque, esquina com Rua das Árvores.',
    @obs = 'Porta dianteira esquerda amassada.'
go

-------------------------------------------------------------------------------------
-- EXECUÇÃO DAS VIEWS
-------------------------------------------------------------------------------------

-- Executar a view vw_ClientesSegurosCarros ordenada alfabeticamente: (Exercício 01)
select * from vw_ClientesSegurosCarros
order by NomeCliente
go

-- Para consultar todos os clientes utilizando a view vw_TodosClientes: (Exercício 04)
select * from vw_TodosClientes
go

-- Para consultar apenas os clientes que moram em São José do Rio Preto utilizando a view vw_TodosClientes: (Exercício 04)
select * from vw_TodosClientes
where cidade = 'São José do Rio Preto'
go

-- Para consultar a view vw_QuantidadeSinistrosPorCarro: (Exercício 05)
select * from vw_QuantidadeSinistrosPorCarro
go
