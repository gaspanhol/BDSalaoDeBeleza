-- =====================================================================
-- 02_dml.sql: povoamento do banco (Salão de Beleza)
-- Ordem: tabelas pai primeiro, depois as filhas.
-- Dados fictícios (nomes/telefones inventados) revisados para fazer sentido no
-- negócio: preços em R$, durações coerentes com 'servico', agendamentos dentro
-- do expediente do profissional e sem sobreposição (regras 4, 5, 9 e 10).
-- Datas: histórico de 26/10/2026 a 21/11/2026 e agenda futura de 23/11 a 04/12.
-- Formato de data/hora: 'AAAA-MM-DD HH:MM'. dia_semana: 0 = domingo ... 6 = sábado.
-- =====================================================================

PRAGMA foreign_keys = ON;

-- ---------- CLIENTE ----------
INSERT INTO cliente (nome, telefone, email, data_cadastro) VALUES
  ('Camila Rodrigues', '(48) 99811-2034', 'camila.rodrigues@email.com', '2026-08-04'),
  ('Fernanda Souza', '(48) 99623-7781', NULL, '2026-08-06'),
  ('Juliana Martins', '(48) 99745-1190', 'ju.martins@email.com', '2026-08-12'),
  ('Patrícia Lima', '(48) 99102-4455', NULL, '2026-08-15'),
  ('Beatriz Almeida', '(48) 99876-3321', 'bia.almeida@email.com', '2026-08-21'),
  ('Renata Pacheco', '(48) 99234-9087', NULL, '2026-08-29'),
  ('Aline Ferreira', '(48) 99567-1243', 'aline.ferreira@email.com', '2026-09-02'),
  ('Larissa Costa', '(48) 99689-5502', NULL, '2026-09-03'),
  ('Gabriela Nunes', '(48) 99321-7764', 'gabi.nunes@email.com', '2026-09-09'),
  ('Tatiane Barbosa', '(48) 99455-0918', NULL, '2026-09-11'),
  ('Mariana Duarte', '(48) 99712-6630', 'mariana.duarte@email.com', '2026-09-14'),
  ('Vanessa Ribeiro', '(48) 99098-3417', NULL, '2026-09-18'),
  ('Carolina Teixeira', '(48) 99834-2256', 'carol.teixeira@email.com', '2026-09-22'),
  ('Daniela Moreira', '(48) 99276-8809', NULL, '2026-09-25'),
  ('Priscila Araújo', '(48) 99543-6071', 'pri.araujo@email.com', '2026-09-30'),
  ('Letícia Gomes', '(48) 99617-4492', NULL, '2026-10-02'),
  ('Roberto Cardoso', '(48) 99388-1525', NULL, '2026-10-05'),
  ('Eduardo Vieira', '(48) 99761-9034', 'eduardo.vieira@email.com', '2026-10-08'),
  ('Sandra Oliveira', '(48) 99159-7348', NULL, '2026-10-13'),
  ('Michele Santos', '(48) 99482-5916', 'michele.santos@email.com', '2026-10-19'),
  ('Thiago Machado', '(48) 99905-2287', NULL, '2026-10-23'),
  ('Isabela Campos', '(48) 99274-6603', 'isa.campos@email.com', '2026-10-27');

-- Cadastro feito sem informar data: usa o DEFAULT (CURRENT_DATE).
-- É um cadastro duplicado que será removido no DELETE mais abaixo.
INSERT INTO cliente (nome, telefone) VALUES ('Camila Rodriguez', '(48) 99811-2035');

-- ---------- PROFISSIONAL ----------
INSERT INTO profissional (nome) VALUES
  ('Marcos'),
  ('Maria'),
  ('Lucia'),
  ('Ana');

-- ---------- TELEFONE_PROFISSIONAL (multivalorado) ----------
INSERT INTO telefone_profissional (id_profissional, telefone) VALUES
  (1, '(48) 99901-1001'),
  (2, '(48) 99902-2002'),
  (3, '(48) 99903-3003'),
  (4, '(48) 99904-4004'),
  (4, '(48) 99905-5005');

-- ---------- SERVICO ----------
-- Manicure, pedicure e massagem têm duração fixa (min = max); corte varia de 60 a 180 min.
INSERT INTO servico (nome, preco, duracao_min, duracao_max) VALUES
  ('Corte de cabelo', 90.00, 60, 180),
  ('Manicure', 35.00, 45, 45),
  ('Pedicure', 45.00, 60, 60),
  ('Massagem', 120.00, 60, 60);

-- ---------- PROFISSIONAL_SERVICO (N:N) ----------
INSERT INTO profissional_servico (id_profissional, id_servico) VALUES
  (1, 1),
  (2, 2),
  (2, 3),
  (2, 4),
  (3, 2),
  (3, 3),
  (3, 4),
  (4, 2),
  (4, 3);

-- ---------- EXPEDIENTE ----------
INSERT INTO expediente (id_profissional, dia_semana, hora_inicio, hora_fim) VALUES
  (1, 2, '09:00', '12:00'),
  (1, 2, '13:30', '18:00'),
  (1, 3, '09:00', '12:00'),
  (1, 3, '13:30', '18:00'),
  (1, 4, '09:00', '12:00'),
  (1, 4, '13:30', '18:00'),
  (1, 5, '09:00', '12:00'),
  (1, 5, '13:30', '18:00'),
  (1, 6, '09:00', '12:00'),
  (1, 6, '13:30', '18:00'),
  (2, 1, '09:00', '12:00'),
  (2, 1, '14:00', '18:00'),
  (2, 2, '09:00', '12:00'),
  (2, 2, '14:00', '18:00'),
  (2, 3, '09:00', '12:00'),
  (2, 3, '14:00', '18:00'),
  (2, 4, '09:00', '12:00'),
  (2, 4, '14:00', '18:00'),
  (2, 5, '09:00', '12:00'),
  (2, 5, '14:00', '18:00'),
  (3, 2, '09:00', '12:00'),
  (3, 2, '13:00', '17:00'),
  (3, 3, '09:00', '12:00'),
  (3, 3, '13:00', '17:00'),
  (3, 4, '09:00', '12:00'),
  (3, 4, '13:00', '17:00'),
  (3, 5, '09:00', '12:00'),
  (3, 5, '13:00', '17:00'),
  (3, 6, '09:00', '12:00'),
  (3, 6, '13:00', '17:00'),
  (4, 1, '08:00', '12:00'),
  (4, 1, '13:00', '17:00'),
  (4, 2, '08:00', '12:00'),
  (4, 2, '13:00', '17:00'),
  (4, 3, '08:00', '12:00'),
  (4, 3, '13:00', '17:00'),
  (4, 4, '08:00', '12:00'),
  (4, 4, '13:00', '17:00'),
  (4, 5, '08:00', '12:00'),
  (4, 5, '13:00', '17:00');

-- ---------- INDISPONIBILIDADE ----------
INSERT INTO indisponibilidade (id_profissional, data_hora_inicio, data_hora_fim, motivo) VALUES
  (1, '2026-11-05 09:00', '2026-11-05 12:00', 'Compromisso pessoal'),
  (2, '2026-11-10 14:00', '2026-11-10 18:00', 'Manutenção do equipamento'),
  (2, '2026-11-24 14:00', '2026-11-24 16:00', 'Curso de aperfeiçoamento'),
  (1, '2026-11-26 13:30', '2026-11-26 15:30', 'Consulta médica'),
  (4, '2026-11-30 13:00', '2026-11-30 17:00', 'Folga'),
  (3, '2026-12-01 09:00', '2026-12-01 12:00', 'Compromisso pessoal');

-- ---------- AGENDAMENTO ----------
-- preco_cobrado = preço do serviço no momento da reserva (regra 17).
INSERT INTO agendamento (id_cliente, id_profissional, id_servico, data_hora_inicio, duracao_efetiva, preco_cobrado, status) VALUES
  (18, 4, 3, '2026-10-28 09:30', 60, 45.00, 'faltou'),
  (3, 2, 4, '2026-10-29 09:00', 60, 120.00, 'concluido'),
  (5, 4, 2, '2026-10-29 10:30', 45, 35.00, 'concluido'),
  (1, 2, 3, '2026-10-29 14:00', 60, 45.00, 'concluido'),
  (17, 3, 3, '2026-10-29 16:00', 60, 45.00, 'concluido'),
  (8, 4, 2, '2026-10-30 09:00', 45, 35.00, 'cancelado'),
  (20, 3, 3, '2026-10-30 15:00', 60, 45.00, 'concluido'),
  (5, 4, 2, '2026-10-30 15:30', 45, 35.00, 'faltou'),
  (19, 2, 2, '2026-10-30 16:30', 45, 35.00, 'concluido'),
  (6, 2, 3, '2026-11-02 15:00', 60, 45.00, 'concluido'),
  (8, 4, 3, '2026-11-03 15:30', 60, 45.00, 'concluido'),
  (4, 2, 3, '2026-11-04 09:00', 60, 45.00, 'concluido'),
  (16, 3, 3, '2026-11-05 11:00', 60, 45.00, 'cancelado'),
  (20, 2, 4, '2026-11-05 14:30', 60, 120.00, 'faltou'),
  (18, 4, 3, '2026-11-05 14:30', 60, 45.00, 'concluido'),
  (22, 1, 1, '2026-11-07 13:30', 150, 90.00, 'concluido'),
  (22, 2, 2, '2026-11-09 11:00', 45, 35.00, 'concluido'),
  (11, 4, 2, '2026-11-09 14:00', 45, 35.00, 'concluido'),
  (19, 4, 3, '2026-11-10 14:30', 60, 45.00, 'cancelado'),
  (6, 4, 2, '2026-11-10 14:30', 45, 35.00, 'concluido'),
  (17, 3, 2, '2026-11-11 09:30', 45, 35.00, 'cancelado'),
  (5, 2, 2, '2026-11-12 09:30', 45, 35.00, 'concluido'),
  (12, 3, 4, '2026-11-12 10:30', 60, 120.00, 'concluido'),
  (20, 4, 2, '2026-11-12 10:30', 45, 35.00, 'concluido'),
  (4, 2, 4, '2026-11-12 14:00', 60, 120.00, 'cancelado'),
  (19, 2, 2, '2026-11-13 16:30', 45, 35.00, 'concluido'),
  (8, 4, 2, '2026-11-16 11:00', 45, 35.00, 'concluido'),
  (15, 3, 4, '2026-11-18 09:30', 60, 120.00, 'concluido'),
  (21, 1, 1, '2026-11-19 13:30', 180, 90.00, 'concluido'),
  (5, 2, 2, '2026-11-20 16:00', 45, 35.00, 'concluido'),
  (20, 4, 3, '2026-11-24 16:00', 60, 45.00, 'agendado'),
  (22, 4, 2, '2026-11-25 09:30', 45, 35.00, 'agendado'),
  (18, 2, 3, '2026-11-25 15:30', 60, 45.00, 'agendado'),
  (15, 2, 2, '2026-11-25 16:30', 45, 35.00, 'agendado'),
  (15, 3, 4, '2026-11-27 10:00', 60, 120.00, 'agendado'),
  (3, 1, 1, '2026-11-28 09:00', 180, 90.00, 'agendado'),
  (2, 3, 3, '2026-11-28 09:00', 60, 45.00, 'agendado'),
  (18, 3, 2, '2026-11-28 11:00', 45, 35.00, 'agendado'),
  (5, 3, 2, '2026-11-28 13:30', 45, 35.00, 'agendado'),
  (22, 4, 2, '2026-12-01 09:30', 45, 35.00, 'agendado'),
  (4, 2, 4, '2026-12-01 10:00', 60, 120.00, 'agendado'),
  (18, 1, 1, '2026-12-02 16:00', 90, 90.00, 'agendado'),
  (1, 3, 2, '2026-12-03 09:00', 45, 35.00, 'agendado'),
  (6, 2, 2, '2026-12-03 14:30', 45, 35.00, 'cancelado'),
  (1, 2, 2, '2026-12-03 14:30', 45, 35.00, 'agendado');

-- =====================================================================
-- UPDATE e DELETE (sempre com WHERE)
-- =====================================================================

-- UPDATE 1: reajuste do preço do corte de cabelo (regras 14 e 15).
-- Os agendamentos já criados mantêm o preco_cobrado antigo (regra 17).
UPDATE servico
   SET preco = 95.00
 WHERE nome = 'Corte de cabelo';

-- UPDATE 2: a cliente trocou de número de telefone.
UPDATE cliente
   SET telefone = '(48) 99623-7790'
 WHERE nome = 'Fernanda Souza';

-- UPDATE 3: encerrar o expediente de sábado da Lucia mais cedo (passa a sair às 15h).
UPDATE expediente
   SET hora_fim = '15:00'
 WHERE id_profissional = (SELECT id_profissional FROM profissional WHERE nome = 'Lucia')
   AND dia_semana = 6
   AND hora_inicio = '13:00';

-- DELETE 1: remove o cadastro duplicado (sem nenhum agendamento).
-- Se tivesse agendamentos, o ON DELETE RESTRICT impediria a exclusão.
DELETE FROM cliente
 WHERE telefone = '(48) 99811-2035'
   AND id_cliente NOT IN (SELECT id_cliente FROM agendamento);

-- DELETE 2: apaga um bloqueio antigo de indisponibilidade (já passou).
DELETE FROM indisponibilidade
 WHERE data_hora_fim < '2026-11-11 00:00'
   AND motivo = 'Manutenção do equipamento';
