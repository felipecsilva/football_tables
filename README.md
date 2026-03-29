# Football Tables (Tabelas de Futebol)

Este projeto consiste em um sistema baseado em PL/SQL para automatizar a geração de confrontos e tabelas de campeonatos de futebol. Ele gerencia desde o cadastro de países e times até a criação lógica de rodadas (legs) para um campeonato.

## 1) Visão Geral do Projeto e Seu Propósito
O objetivo principal é fornecer uma estrutura de banco de dados e lógica de backend (em Oracle PL/SQL) que permita organizar campeonatos de futebol de forma automatizada. O sistema valida o número de participantes e gera os confrontos necessários para cobrir todos os jogos entre os times inscritos.

## 2) Instruções de Uso
Para utilizar este projeto, você deve ter acesso a um banco de dados Oracle. Siga a ordem de execução dos scripts:
1.  Execute o script de criação de tabelas localizado em `TABLES SCRIPT/TABLES.sql`.
2.  Compile o pacote de utilitários: `PACKAGES/PKG_UTILS.pck`.
3.  Compile o pacote principal de campeonatos: `PACKAGES/PKG_TABLESCHAMPIONSHIPS.pck`.

## 3) Guia Passo a Passo das Funcionalidades
1.  **Cadastrar Países**: Insira os países na tabela `COUNTRIES`.
2.  **Cadastrar Times**: Insira os times na tabela `TEAMS`, associando-os a um país.
3.  **Criar um Campeonato**: Insira um novo registro na tabela `CHAMPIONSHIPS`.
4.  **Inscrever Times**: Associe os times ao campeonato através da tabela `TEAMS_CHAMPIONSHIP`.
5.  **Gerar Partidas**: Execute o procedimento `PKG_TABLESCHAMPIONSHIPS.CREATE_CHAMPIONSHIP_MATCHES` passando o ID do campeonato.

## 4) Exemplos de Uso

### Inserindo Dados Básicos
```sql
-- Inserir um país
INSERT INTO COUNTRIES (name, initials) VALUES ('Brasil', 'BRA');

-- Inserir um time
INSERT INTO TEAMS (name, completename, initials, country_id)
VALUES ('Flamengo', 'Clube de Regatas do Flamengo', 'FLA', 1);

-- Criar um campeonato
INSERT INTO CHAMPIONSHIPS (name, country_id, season)
VALUES ('Brasileirão', 1, '2023');

-- Inscrever um time no campeonato (ID_TIME = 1, ID_CHAMP = 1)
INSERT INTO TEAMS_CHAMPIONSHIP (TEAM_ID, CHAMPIONSHIP_ID) VALUES (1, 1);
```

### Gerando as Partidas do Campeonato
```sql
DECLARE
  v_resultado VARCHAR2(4000);
BEGIN
  -- Supondo que o ID do campeonato seja 1
  PKG_TABLESCHAMPIONSHIPS.CREATE_CHAMPIONSHIP_MATCHES(1, v_resultado);
  DBMS_OUTPUT.PUT_LINE(v_resultado);
END;
/
```

## 5) Dependências e Requisitos de Sistema
-   **Banco de Dados**: Oracle Database 12c ou superior (devido ao uso de `GENERATED ALWAYS AS IDENTITY`).
-   **Permissões**: O usuário deve ter privilégios para criar tabelas, pacotes e sequências.

## 6) Perguntas Frequentes (FAQ)

### Por que o sistema exige que o número de times seja uma potência de 2 (2, 4, 8, 16...)?
A função `PKG_UTILS.CheckNumberOfTeams` valida se o número de times participantes segue uma progressão de potência de 2. Isso é comumente usado em formatos de torneio específicos ou para garantir um equilíbrio na distribuição das rodadas conforme a lógica atual do pacote.

### Como as partidas são organizadas?
As partidas são divididas em "legs" (rodadas). O sistema tenta garantir que cada time jogue apenas uma vez por rodada.

## 7) Orientação sobre como Contribuir
Sinta-se à vontade para contribuir com o projeto!
1.  Faça um **Fork** do repositório.
2.  Crie uma **Branch** para sua funcionalidade (`git checkout -b feature/nova-funcionalidade`).
3.  Faça o **Commit** de suas alterações.
4.  Envie um **Pull Request**.

---

## Por que usamos Cross Join para fazer as tabelas?
No procedimento `CREATE_CHAMPIONSHIP_MATCHES`, utilizamos uma técnica similar ao **Cross Join** (produto cartesiano) entre a tabela de times (alias `a` para mandantes e `b` para visitantes).

O motivo técnico é que, para gerar um campeonato onde todos jogam contra todos, precisamos inicialmente de todas as combinações possíveis de pares de times. O Cross Join gera esse "universo" de confrontos. A partir desse produto cartesiano, aplicamos filtros essenciais:
1.  `where a.home <> b.away`: Garante que um time não jogue contra si mesmo.
2.  `WHERE NOT EXISTS (...)`: Garante que não sejam criadas partidas duplicadas (evitando que o jogo "Time A x Time B" seja inserido novamente se "Time B x Time A" já existir ou vice-versa, dependendo da configuração de turnos).

Essa abordagem simplifica a lógica de descoberta de jogos, permitindo que o SQL resolva a combinação de dados enquanto o PL/SQL foca na organização dessas partidas dentro das rodadas cronológicas.
