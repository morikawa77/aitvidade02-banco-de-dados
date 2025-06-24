# Sistema de Seguros - Atividade 02 ABD INFOM 2025-1

## 📋 Descrição do Projeto

Este projeto implementa um sistema completo de gerenciamento de seguros automotivos desenvolvido para a disciplina de **Administração de Banco de Dados** do curso de **Tecnologia em Informática para Negócios** da FATEC São José do Rio Preto.

### 👥 Autores
- **Reginaldo Morikawa**
- **Tháira Letícia Ibraim Lulio**

### 📅 Data de Entrega
25 de Junho de 2025 - Até 22h

### 👨‍🏫 Professor
Valéria Maria Volpe

---

## 🏗️ Estrutura do Banco de Dados

### Banco de Dados
- **Nome**: `Seguros_INFOM`

### Tabelas Principais

#### 1. **Pessoas**
- Armazena informações básicas de todas as pessoas (clientes e corretores)
- **Campos**: idPessoa, nome, cpf, dataNasc, status
- **Status**: 1 (Ativo), 2 (Inativo), 3 (Excluído)

#### 2. **Clientes**
- Informações específicas dos clientes
- **Campos**: pessoaId, nroCNH, idade
- **Relacionamento**: Herda de Pessoas

#### 3. **Corretores**
- Informações específicas dos corretores de seguros
- **Campos**: pessoaId, nroRegistro, telefone
- **Relacionamento**: Herda de Pessoas

#### 4. **Enderecos**
- Endereços dos clientes
- **Campos**: idEnd, rua, nro, complemento, bairro, cep, cidade, estado, clienteId

#### 5. **Seguros**
- Contratos de seguro
- **Campos**: idSeguro, valorFranquia, valor, dataInicio, dataFim, premio, clienteId, corretorId
- **Validações**: valorFranquia > 0, valor > 0, dataInicio < dataFim

#### 6. **Comissoes**
- Comissões dos corretores
- **Campos**: idComissao, valor, dataPgto, status, seguroId, corretorId
- **Status**: 1 (Pago), 2 (Pendente)

#### 7. **Carros**
- Veículos segurados
- **Campos**: idCarro, placa, marca, modelo, cor, seguroId

#### 8. **Sinistros**
- Registro de sinistros
- **Campos**: carroId, seguroId, dataS, hora, localS, obs
- **Chave Primária Composta**: (carroId, seguroId, dataS)

#### 9. **HistoricoSinistros**
- Histórico de sinistros com auditoria
- **Campos**: carroId, seguroId, dataS, hora, localS, obs, dataAbertura, usuario

---

## 🔧 Funcionalidades Implementadas

### Stored Procedures

#### 1. **CadastrarClienteCarroSeguro**
- Cadastra um novo cliente, seu carro e seguro em uma única operação
- **Parâmetros**: Dados pessoais, CNH, informações do carro e seguro
- **Funcionalidade**: Inserção transacional em múltiplas tabelas

#### 2. **CadastrarSinistro**
- Registra um novo sinistro
- **Parâmetros**: Dados do sinistro (carro, seguro, data, hora, local, observações)

### Views

#### 1. **vw_ClientesSegurosCarros**
- Consulta nome e status do cliente, dados do seguro e do carro
- **Uso**: Relatórios integrados cliente-seguro-veículo

#### 2. **vw_TodosClientes**
- Consulta completa de todos os clientes com endereço
- **Uso**: Listagem completa de clientes

#### 3. **vw_QuantidadeSinistrosPorCarro**
- Conta o número de sinistros por carro
- **Uso**: Análise de risco por veículo

### Triggers

#### 1. **trg_Clientes_InativarAoExcluir**
- **Tipo**: Instead of Delete
- **Funcionalidade**: Inativa cliente ao invés de excluir (soft delete)

#### 2. **trg_AposInserirSinistro**
- **Tipo**: After Insert
- **Funcionalidades**:
  - Registra sinistro no histórico
  - Aplica desconto de 10% no prêmio do seguro

#### 3. **trg_AposInserirSeguro**
- **Tipo**: After Insert
- **Funcionalidade**: Cadastra comissão automaticamente quando seguro é criado

### Functions

#### 1. **fn_CalculaComissao**
- Calcula o valor da comissão baseado no valor do seguro e percentual
- **Parâmetros**: valorBase (money), percentual (decimal)
- **Retorno**: money

---

## 📊 Dados de Exemplo

### Corretores Cadastrados
- Ana Paula Silva (REG-0001/SP)
- Bruno Costa (REG-0002/RJ)
- Carla Dias (REG-0003/MG)

### Clientes de Exemplo
O sistema inclui 10 clientes com dados completos:
- Mariana Oliveira (Chevrolet Onix)
- João Santos (Ford Ka)
- Fernanda Lima (Volkswagen Virtus)
- Pedro Almeida (Fiat Cronos)
- Patricia Gomes (Renault Kwid)
- Rafael Souza (Hyundai HB20)
- Larissa Costa (Toyota Corolla)
- Gustavo Pereira (Honda Civic)
- Sofia Martins (Nissan Kicks)
- Diego Rocha (BMW X1)

### Sinistros de Exemplo
10 sinistros registrados com diferentes tipos de ocorrências:
- Colisões leves
- Danos em para-choques
- Vidros quebrados
- Pneus furados
- Arranhões

---
### Pré-requisitos
- SQL Server (qualquer versão compatível)
- SQL Server Client

### Estrutura dos Arquivos
- `ScriptSQL_Atividade02_INFOM_2025-1.sql` - Script básico com criação das tabelas
- `ScriptSQL_Atividade02_INFOM_2025-1-Reginaldo-Thaira.sql` - Script completo com todas as funcionalidades

---

## 📋 Consultas de Exemplo

### Consultar Clientes com Seguros e Carros
```sql
SELECT * FROM vw_ClientesSegurosCarros
ORDER BY NomeCliente
```

### Consultar Todos os Clientes
```sql
SELECT * FROM vw_TodosClientes
```

### Consultar Clientes de São José do Rio Preto
```sql
SELECT * FROM vw_TodosClientes
WHERE cidade = 'São José do Rio Preto'
```

### Consultar Quantidade de Sinistros por Carro
```sql
SELECT * FROM vw_QuantidadeSinistrosPorCarro
```

---

## 🔍 Características Técnicas

### Validações Implementadas
- **CPF único** para cada pessoa
- **CNH única** para cada cliente
- **Placa única** para cada carro
- **Valores positivos** para franquia e valor do seguro
- **Datas válidas** (data início < data fim)
- **Status controlado** (1, 2, 3 para pessoas; 1, 2 para comissões)

### Relacionamentos
- **Herança**: Clientes e Corretores herdam de Pessoas
- **Composição**: Carros pertencem a Seguros
- **Associação**: Sinistros relacionam Carros e Seguros
- **Dependência**: Endereços dependem de Clientes

### Recursos Avançados
- **Soft Delete**: Clientes são inativados ao invés de excluídos
- **Auditoria**: Histórico de sinistros com data e usuário
- **Automação**: Comissões e descontos aplicados automaticamente
- **Transações**: Cadastro completo em uma única operação

---

## 📝 Observações Importantes

1. **Integridade Referencial**: Todas as chaves estrangeiras estão devidamente configuradas
2. **Performance**: Índices automáticos nas chaves primárias
3. **Segurança**: Validações de dados em nível de banco
4. **Manutenibilidade**: Código bem documentado e estruturado
5. **Escalabilidade**: Estrutura preparada para crescimento

---

## 🎯 Objetivos Alcançados

✅ Criação completa do banco de dados  
✅ Implementação de todas as tabelas com relacionamentos  
✅ Desenvolvimento de Stored Procedures funcionais  
✅ Criação de Views para consultas complexas  
✅ Implementação de Triggers para automação  
✅ Desenvolvimento de Functions para cálculos  
✅ Inserção de dados de exemplo realistas  
✅ Validações e constraints de integridade  
✅ Documentação completa do projeto  

---

*Projeto desenvolvido para a disciplina de Administração de Banco de Dados - FATEC São José do Rio Preto* 