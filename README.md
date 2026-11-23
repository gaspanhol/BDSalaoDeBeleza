# Salão de Beleza: Banco de Dados (SQLite)

**Disciplina:** Banco de Dados
**Equipe:** Gabriel Spanhol, Gustavo Ramos, Louise Bertipaglia, Lucas Pacheco

**Tema:** Banco de dados para um salão de beleza (manicure, pedicure, massagem e corte de cabelo), com controle de horários e profissionais.
**SGBD:** SQLite (DB Browser for SQLite)

## O que o banco guarda

Clientes, profissionais (com vários telefones), serviços (com preço e duração mínima/máxima), os serviços que cada profissional realiza (N:N), o expediente semanal de cada profissional (entidade fraca), as indisponibilidades e os agendamentos. O preço do serviço é copiado para o agendamento no momento da reserva, para que reajustes futuros não alterem o histórico.

## Estrutura do repositório

| Caminho | Conteúdo |
|---|---|
| `docs/01_contexto_regras.md` | Contexto do negócio e 18 regras de negócio |
| `docs/02_mer/` | Diagrama MER (`mer.drawio`, `mer.png`) |
| `docs/03_modelo_relacional/` | Modelo relacional |
| `docs/04_normalizacao.md` | Normalização até a 3FN |
| `docs/05_dicionario_dados.md` | Dicionário de dados |
| `docs/06_aprofundamento.md` | Item de aprofundamento: **triggers** (justificativa, implementação e testes) |
| `sql/01_ddl.sql` | Criação das tabelas (PK, FK, NOT NULL, UNIQUE, CHECK, DEFAULT e ALTER TABLE documentado) |
| `sql/02_dml.sql` | Povoamento (INSERT, UPDATE e DELETE com WHERE) |
| `sql/03_consultas.sql` | 28 consultas de negócio e 2 views |
| `sql/04_aprofundamento.sql` | Triggers das regras 5, 6, 8 e 9 |
| `banco/salao.db` | Banco pronto, com tudo já executado |
| `relatorio/` | Relatório em PDF |

## Como executar

**Opção A: usar o banco pronto.** Abra `banco/salao.db` no DB Browser for SQLite (*Abrir banco de dados*). Para rodar as consultas, abra a aba *Executar SQL*, carregue `sql/03_consultas.sql` e execute uma consulta por vez (selecione o trecho e use *Executar linha atual*/`Ctrl+Return`).

**Opção B: reconstruir do zero.**

1. Crie um novo banco vazio (por exemplo, `banco/salao.db`).
2. Execute `sql/01_ddl.sql` (tabelas).
3. Execute `sql/02_dml.sql` (povoamento).
4. Execute `sql/03_consultas.sql` (consultas e views).
5. Execute `sql/04_aprofundamento.sql` (triggers).

> Os scripts começam com `PRAGMA foreign_keys = ON;`. No SQLite as chaves estrangeiras só valem se isso estiver ativo em cada sessão.
> O `01_ddl.sql` apaga e recria as tabelas, então pode ser executado de novo sem erro.

## Convenções

- Data e hora: texto `'AAAA-MM-DD HH:MM'` (SQLite não tem tipo data/hora).
- `dia_semana` no expediente: 0 a 6, igual ao `strftime('%w')` (0 = domingo).
- Status do agendamento: `agendado`, `concluido`, `cancelado`, `faltou`.
- O horário de fim do agendamento é **derivado** (não armazenado): `data_hora_inicio + duracao_efetiva`. A view `vw_agenda_completa` já o calcula.
- Os dados são fictícios.

## Itens da entrega

- [ ] Relatório em PDF (`relatorio/`)
- [x] Banco de dados `.db`
- [x] `01_ddl.sql`, `02_dml.sql`, `03_consultas.sql` (+ `04_aprofundamento.sql`)
- [ ] Apresentação individual (até 10 min): 3 consultas à escolha da equipe e 1 à escolha do professor
