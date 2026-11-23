-- =====================================================================
-- 04_aprofundamento.sql: item de aprofundamento = TRIGGERS (SQLite)
-- Rodar DEPOIS de 01_ddl.sql, 02_dml.sql e 03_consultas.sql.
-- Implementa as regras de negócio dinâmicas que CHECK/UNIQUE/FK não conseguem
-- expressar (precisam olhar a hora atual ou outras linhas da tabela):
--   regra 6      -> cancelar só até 30 min antes do início
--   regras 5 e 9 -> sem sobreposição de horários (profissional e cliente)
--   regra 8      -> duração efetiva entre a mínima e a máxima do serviço
-- Documentação, justificativa e testes: docs/06_aprofundamento.md
-- Observação: comparações de data/hora usam strftime('%Y-%m-%d %H:%M', ...)
-- para ficarem sempre no mesmo formato de texto do banco.
-- =====================================================================

PRAGMA foreign_keys = ON;

DROP TRIGGER IF EXISTS trg_agend_cancelamento_prazo;
DROP TRIGGER IF EXISTS trg_agend_sobreposicao_ins;
DROP TRIGGER IF EXISTS trg_agend_sobreposicao_upd;
DROP TRIGGER IF EXISTS trg_agend_duracao_ins;
DROP TRIGGER IF EXISTS trg_agend_duracao_upd;

-- ---------------------------------------------------------------------
-- Regra 6: cancelamento até 30 minutos antes do início.
-- Dispara quando alguém muda o status para 'cancelado'.
-- Também impede "cancelar" o que já foi concluído ou marcado como falta.
-- Usa a hora local do computador ('localtime').
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_agend_cancelamento_prazo
BEFORE UPDATE OF status ON agendamento
FOR EACH ROW
WHEN NEW.status = 'cancelado' AND OLD.status <> 'cancelado'
BEGIN
    SELECT RAISE(ABORT, 'Só é possível cancelar agendamentos com status agendado')
    WHERE OLD.status <> 'agendado';

    SELECT RAISE(ABORT, 'Cancelamento só é permitido até 30 minutos antes do início')
    WHERE strftime('%Y-%m-%d %H:%M', 'now', 'localtime')
        > strftime('%Y-%m-%d %H:%M', OLD.data_hora_inicio, '-30 minutes');
END;

-- ---------------------------------------------------------------------
-- Regras 5 e 9: sem sobreposição de tempo entre agendamentos ativos
-- (não cancelados). Dois intervalos se sobrepõem quando
--     início_A < fim_B  E  início_B < fim_A
-- Versão para INSERT (novo agendamento).
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_agend_sobreposicao_ins
BEFORE INSERT ON agendamento
FOR EACH ROW
WHEN NEW.status <> 'cancelado'
BEGIN
    SELECT RAISE(ABORT, 'Profissional já possui agendamento nesse intervalo')
    WHERE EXISTS (
        SELECT 1 FROM agendamento a
        WHERE a.id_profissional = NEW.id_profissional
          AND a.status <> 'cancelado'
          AND a.data_hora_inicio < strftime('%Y-%m-%d %H:%M', NEW.data_hora_inicio, '+' || NEW.duracao_efetiva || ' minutes')
          AND NEW.data_hora_inicio < strftime('%Y-%m-%d %H:%M', a.data_hora_inicio, '+' || a.duracao_efetiva || ' minutes'));

    SELECT RAISE(ABORT, 'Cliente já possui agendamento nesse intervalo')
    WHERE EXISTS (
        SELECT 1 FROM agendamento a
        WHERE a.id_cliente = NEW.id_cliente
          AND a.status <> 'cancelado'
          AND a.data_hora_inicio < strftime('%Y-%m-%d %H:%M', NEW.data_hora_inicio, '+' || NEW.duracao_efetiva || ' minutes')
          AND NEW.data_hora_inicio < strftime('%Y-%m-%d %H:%M', a.data_hora_inicio, '+' || a.duracao_efetiva || ' minutes'));
END;

-- Versão para UPDATE (remarcar horário, trocar profissional/cliente, reativar).
-- Ignora a própria linha (a.id_agendamento <> NEW.id_agendamento).
CREATE TRIGGER trg_agend_sobreposicao_upd
BEFORE UPDATE OF id_cliente, id_profissional, data_hora_inicio, duracao_efetiva, status ON agendamento
FOR EACH ROW
WHEN NEW.status <> 'cancelado'
BEGIN
    SELECT RAISE(ABORT, 'Profissional já possui agendamento nesse intervalo')
    WHERE EXISTS (
        SELECT 1 FROM agendamento a
        WHERE a.id_agendamento <> NEW.id_agendamento
          AND a.id_profissional = NEW.id_profissional
          AND a.status <> 'cancelado'
          AND a.data_hora_inicio < strftime('%Y-%m-%d %H:%M', NEW.data_hora_inicio, '+' || NEW.duracao_efetiva || ' minutes')
          AND NEW.data_hora_inicio < strftime('%Y-%m-%d %H:%M', a.data_hora_inicio, '+' || a.duracao_efetiva || ' minutes'));

    SELECT RAISE(ABORT, 'Cliente já possui agendamento nesse intervalo')
    WHERE EXISTS (
        SELECT 1 FROM agendamento a
        WHERE a.id_agendamento <> NEW.id_agendamento
          AND a.id_cliente = NEW.id_cliente
          AND a.status <> 'cancelado'
          AND a.data_hora_inicio < strftime('%Y-%m-%d %H:%M', NEW.data_hora_inicio, '+' || NEW.duracao_efetiva || ' minutes')
          AND NEW.data_hora_inicio < strftime('%Y-%m-%d %H:%M', a.data_hora_inicio, '+' || a.duracao_efetiva || ' minutes'));
END;

-- ---------------------------------------------------------------------
-- Regra 8: a duração efetiva deve ficar entre duracao_min e duracao_max do serviço.
-- (Manicure/pedicure/massagem têm min = max; o corte varia de 60 a 180.)
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_agend_duracao_ins
BEFORE INSERT ON agendamento
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Duração fora dos limites (mínimo/máximo) do serviço')
    WHERE NEW.duracao_efetiva < (SELECT duracao_min FROM servico WHERE id_servico = NEW.id_servico)
       OR NEW.duracao_efetiva > (SELECT duracao_max FROM servico WHERE id_servico = NEW.id_servico);
END;

CREATE TRIGGER trg_agend_duracao_upd
BEFORE UPDATE OF duracao_efetiva, id_servico ON agendamento
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Duração fora dos limites (mínimo/máximo) do serviço')
    WHERE NEW.duracao_efetiva < (SELECT duracao_min FROM servico WHERE id_servico = NEW.id_servico)
       OR NEW.duracao_efetiva > (SELECT duracao_max FROM servico WHERE id_servico = NEW.id_servico);
END;
