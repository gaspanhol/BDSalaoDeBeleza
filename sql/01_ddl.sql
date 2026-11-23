-- =====================================================================
-- 01_ddl.sql: criação física do banco (Salão de Beleza) - SQLite
-- Ordem: tabelas sem dependência primeiro, depois as que referenciam outras.
-- O script é re-executável: os DROP removem tudo na ordem inversa.
-- Convenções de formato (SQLite não tem tipo data/hora):
--   data e hora  -> TEXT 'AAAA-MM-DD HH:MM'   (ex.: '2026-11-25 14:30')
--   hora         -> TEXT 'HH:MM'              (ex.: '09:00')
--   dia_semana   -> INTEGER 0..6, mesmo padrão do strftime('%w'): 0 = domingo
--   dinheiro     -> REAL em reais
-- =====================================================================

PRAGMA foreign_keys = ON;

-- ---------- limpeza (ordem inversa das dependências) ----------
DROP TABLE IF EXISTS agendamento;
DROP TABLE IF EXISTS indisponibilidade;
DROP TABLE IF EXISTS expediente;
DROP TABLE IF EXISTS profissional_servico;
DROP TABLE IF EXISTS telefone_profissional;
DROP TABLE IF EXISTS servico;
DROP TABLE IF EXISTS profissional;
DROP TABLE IF EXISTS cliente;

-- ---------- CLIENTE ----------
-- Regra 3: cadastro exige nome e telefone.
CREATE TABLE cliente (
    id_cliente     INTEGER PRIMARY KEY AUTOINCREMENT,
    nome           TEXT    NOT NULL CHECK (length(trim(nome)) >= 3),
    telefone       TEXT    NOT NULL UNIQUE
                   CHECK (telefone GLOB '([0-9][0-9]) 9[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
    data_cadastro  TEXT    NOT NULL DEFAULT CURRENT_DATE
);

-- ---------- PROFISSIONAL ----------
CREATE TABLE profissional (
    id_profissional INTEGER PRIMARY KEY AUTOINCREMENT,
    nome            TEXT    NOT NULL UNIQUE CHECK (length(trim(nome)) >= 2),
    ativo           INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1))
);

-- ---------- TELEFONE_PROFISSIONAL (atributo multivalorado, regra 19) ----------
CREATE TABLE telefone_profissional (
    id_profissional INTEGER NOT NULL,
    telefone        TEXT    NOT NULL
                    CHECK (telefone GLOB '([0-9][0-9]) 9[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
    PRIMARY KEY (id_profissional, telefone),
    FOREIGN KEY (id_profissional) REFERENCES profissional (id_profissional)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ---------- SERVICO (regras 8 e 14: preço único; duração mínima e máxima) ----------
CREATE TABLE servico (
    id_servico  INTEGER PRIMARY KEY AUTOINCREMENT,
    nome        TEXT    NOT NULL UNIQUE,
    preco       REAL    NOT NULL CHECK (preco > 0),
    duracao_min INTEGER NOT NULL CHECK (duracao_min > 0),
    duracao_max INTEGER NOT NULL CHECK (duracao_max > 0),
    CHECK (duracao_max >= duracao_min)
);

-- ---------- PROFISSIONAL_SERVICO (relacionamento N:N, regra 13) ----------
CREATE TABLE profissional_servico (
    id_profissional INTEGER NOT NULL,
    id_servico      INTEGER NOT NULL,
    PRIMARY KEY (id_profissional, id_servico),
    FOREIGN KEY (id_profissional) REFERENCES profissional (id_profissional)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_servico) REFERENCES servico (id_servico)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ---------- EXPEDIENTE (entidade fraca de PROFISSIONAL, regra 7) ----------
-- Identificada por (profissional, dia da semana, hora de início).
CREATE TABLE expediente (
    id_profissional INTEGER NOT NULL,
    dia_semana      INTEGER NOT NULL CHECK (dia_semana BETWEEN 0 AND 6),
    hora_inicio     TEXT    NOT NULL CHECK (hora_inicio GLOB '[0-2][0-9]:[0-5][0-9]'),
    hora_fim        TEXT    NOT NULL CHECK (hora_fim    GLOB '[0-2][0-9]:[0-5][0-9]'),
    PRIMARY KEY (id_profissional, dia_semana, hora_inicio),
    CHECK (hora_fim > hora_inicio),
    FOREIGN KEY (id_profissional) REFERENCES profissional (id_profissional)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ---------- INDISPONIBILIDADE (regra 10) ----------
CREATE TABLE indisponibilidade (
    id_indisponibilidade INTEGER PRIMARY KEY AUTOINCREMENT,
    id_profissional      INTEGER NOT NULL,
    data_hora_inicio     TEXT    NOT NULL
                         CHECK (length(data_hora_inicio) = 16 AND datetime(data_hora_inicio) IS NOT NULL),
    data_hora_fim        TEXT    NOT NULL
                         CHECK (length(data_hora_fim) = 16 AND datetime(data_hora_fim) IS NOT NULL),
    motivo               TEXT,
    CHECK (data_hora_fim > data_hora_inicio),
    FOREIGN KEY (id_profissional) REFERENCES profissional (id_profissional)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ---------- AGENDAMENTO ----------
-- Regra 2: exatamente 1 cliente, 1 profissional, 1 serviço e 1 horário de início.
-- Regra 13: a FK composta (id_profissional, id_servico) -> profissional_servico
--           impede agendar um serviço que o profissional não realiza.
-- Regra 17: preco_cobrado congela o preço do serviço no momento da reserva.
-- Atributo derivado "horário de fim" NÃO é armazenado:
--           datetime(data_hora_inicio, '+' || duracao_efetiva || ' minutes')
CREATE TABLE agendamento (
    id_agendamento   INTEGER PRIMARY KEY AUTOINCREMENT,
    id_cliente       INTEGER NOT NULL,
    id_profissional  INTEGER NOT NULL,
    id_servico       INTEGER NOT NULL,
    data_hora_inicio TEXT    NOT NULL
                     CHECK (length(data_hora_inicio) = 16 AND datetime(data_hora_inicio) IS NOT NULL),
    duracao_efetiva  INTEGER NOT NULL CHECK (duracao_efetiva > 0),
    preco_cobrado    REAL    NOT NULL CHECK (preco_cobrado > 0),
    status           TEXT    NOT NULL DEFAULT 'agendado'
                     CHECK (status IN ('agendado', 'concluido', 'cancelado', 'faltou')),
    FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_servico) REFERENCES servico (id_servico)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_profissional) REFERENCES profissional (id_profissional)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_profissional, id_servico)
        REFERENCES profissional_servico (id_profissional, id_servico)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Parte das regras 5 e 9: nenhum profissional/cliente pode ter dois agendamentos
-- ATIVOS começando no mesmo instante (cancelados liberam o horário, regra 6).
-- A sobreposição parcial (um começa no meio do outro) não dá para expressar em
-- CHECK/UNIQUE: fica para o trigger do item de aprofundamento.
CREATE UNIQUE INDEX ux_agend_prof_inicio_ativo
    ON agendamento (id_profissional, data_hora_inicio) WHERE status <> 'cancelado';
CREATE UNIQUE INDEX ux_agend_cli_inicio_ativo
    ON agendamento (id_cliente, data_hora_inicio) WHERE status <> 'cancelado';

-- ---------- ALTER TABLE (documentado) ----------
-- Regra 18: o cliente pode informar e-mail opcional para receber lembretes.
-- Motivo: depois de criar o cadastro de clientes percebeu-se que o salão quer
-- enviar lembretes de agendamento por e-mail. O campo é opcional (a regra 3 só
-- exige nome e telefone), por isso entra por ALTER e não como NOT NULL.
-- Obs.: o SQLite não aceita UNIQUE dentro do ADD COLUMN; a unicidade é garantida
-- por um índice único logo em seguida (vários NULL continuam permitidos).
ALTER TABLE cliente
    ADD COLUMN email TEXT CHECK (email IS NULL OR email LIKE '_%@_%._%');
CREATE UNIQUE INDEX ux_cliente_email ON cliente (email);
