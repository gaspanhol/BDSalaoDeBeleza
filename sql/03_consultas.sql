-- =====================================================================
-- 03_consultas.sql: consultas de negócio do Salão de Beleza (28 consultas)
-- Rodar DEPOIS de 01_ddl.sql e 02_dml.sql.
-- Cada consulta traz a pergunta de negócio que ela responde.
-- Data de referência ("hoje") fixada em 22/11/2026 para o resultado não mudar
-- no dia da apresentação. Basta trocar '2026-11-22' / '2026-11-23' se precisar.
-- Convenção: datas/horas em texto 'AAAA-MM-DD HH:MM'; o horário de fim do
-- agendamento é DERIVADO: strftime(..., data_hora_inicio, '+' || duracao_efetiva || ' minutes').
-- =====================================================================

PRAGMA foreign_keys = ON;

-- #####################################################################
-- BLOCO A: SELECT com filtros (WHERE, LIKE, IN, BETWEEN) e ordenação
-- #####################################################################

-- Q01 (WHERE + BETWEEN + ORDER BY)
-- Pergunta de negócio: Quais serviços custam entre R$ 30 e R$ 100, do mais caro ao mais barato?
SELECT nome, preco, duracao_min, duracao_max
FROM servico
WHERE preco BETWEEN 30 AND 100
ORDER BY preco DESC;

-- Q02 (LIKE + ORDER BY)
-- Pergunta de negócio: Quais clientes têm nome iniciado pela letra M (ex.: para uma lista de contatos)?
SELECT id_cliente, nome, telefone
FROM cliente
WHERE nome LIKE 'M%'
ORDER BY nome;

-- Q03 (IN + BETWEEN + ORDER BY)
-- Pergunta de negócio: Quais agendamentos (marcados ou cancelados) existem para a semana de 23 a 30/11?
SELECT id_agendamento, id_cliente, id_profissional, data_hora_inicio, status
FROM agendamento
WHERE status IN ('agendado', 'cancelado')
  AND data_hora_inicio BETWEEN '2026-11-23 00:00' AND '2026-11-30 23:59'
ORDER BY data_hora_inicio;

-- #####################################################################
-- BLOCO B: funções de agregação, GROUP BY e HAVING
-- #####################################################################

-- Q04 (COUNT, SUM, GROUP BY)
-- Pergunta de negócio: Quanto cada serviço já faturou (somente atendimentos concluídos)?
SELECT s.nome AS servico,
       COUNT(*)              AS atendimentos,
       SUM(a.preco_cobrado)  AS faturamento
FROM agendamento a
JOIN servico s ON s.id_servico = a.id_servico
WHERE a.status = 'concluido'
GROUP BY s.id_servico, s.nome
ORDER BY faturamento DESC;

-- Q05 (COUNT + GROUP BY + HAVING)
-- Pergunta de negócio: Quais profissionais já fizeram 5 ou mais atendimentos concluídos?
SELECT p.nome AS profissional, COUNT(*) AS atendimentos_concluidos
FROM agendamento a
JOIN profissional p ON p.id_profissional = a.id_profissional
WHERE a.status = 'concluido'
GROUP BY p.id_profissional, p.nome
HAVING COUNT(*) >= 5
ORDER BY atendimentos_concluidos DESC;

-- Q06 (SUM, AVG, MIN, MAX, COUNT)
-- Pergunta de negócio: Qual o resumo financeiro geral (total, ticket médio, menor e maior valor)?
SELECT COUNT(*)                    AS atendimentos,
       SUM(preco_cobrado)          AS faturamento_total,
       ROUND(AVG(preco_cobrado),2) AS ticket_medio,
       MIN(preco_cobrado)          AS menor_valor,
       MAX(preco_cobrado)          AS maior_valor
FROM agendamento
WHERE status = 'concluido';

-- Q07 (GROUP BY + subconsulta escalar para o percentual)
-- Pergunta de negócio: Qual a proporção de agendamentos por status (concluído, cancelado, faltou, agendado)?
SELECT status,
       COUNT(*) AS qtd,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM agendamento), 1) AS percentual
FROM agendamento
GROUP BY status
ORDER BY qtd DESC;

-- Q08 (INNER JOIN + SUM + GROUP BY + HAVING)
-- Pergunta de negócio: Quais clientes já gastaram R$ 100 ou mais no salão (clientes mais valiosos)?
SELECT c.nome AS cliente,
       COUNT(*)             AS visitas,
       SUM(a.preco_cobrado) AS total_gasto
FROM cliente c
INNER JOIN agendamento a ON a.id_cliente = c.id_cliente
WHERE a.status = 'concluido'
GROUP BY c.id_cliente, c.nome
HAVING SUM(a.preco_cobrado) >= 100
ORDER BY total_gasto DESC;

-- #####################################################################
-- BLOCO C: INNER JOIN, LEFT JOIN e junção de 3 ou mais tabelas
-- #####################################################################

-- Q09 (INNER JOIN de 4 tabelas + horário de fim derivado)
-- Pergunta de negócio: Qual é a agenda futura completa (cliente, profissional, serviço, início e fim)?
SELECT a.data_hora_inicio                                           AS inicio,
       strftime('%H:%M', a.data_hora_inicio,
                '+' || a.duracao_efetiva || ' minutes')             AS fim,
       c.nome AS cliente, p.nome AS profissional, s.nome AS servico
FROM agendamento a
INNER JOIN cliente      c ON c.id_cliente      = a.id_cliente
INNER JOIN profissional p ON p.id_profissional = a.id_profissional
INNER JOIN servico      s ON s.id_servico      = a.id_servico
WHERE a.status = 'agendado'
  AND a.data_hora_inicio >= '2026-11-23 00:00'
ORDER BY a.data_hora_inicio, p.nome;

-- Q10 (LEFT JOIN + IS NULL)
-- Pergunta de negócio: Quais clientes cadastrados nunca fizeram nenhum agendamento (para campanha de reativação)?
SELECT c.id_cliente, c.nome, c.telefone, c.data_cadastro
FROM cliente c
LEFT JOIN agendamento a ON a.id_cliente = c.id_cliente
WHERE a.id_agendamento IS NULL
ORDER BY c.data_cadastro;

-- Q11 (JOIN de 3 tabelas N:N + GROUP_CONCAT)  [regra 16]
-- Pergunta de negócio: Quais serviços cada profissional realiza e por qual preço?
SELECT p.nome AS profissional,
       GROUP_CONCAT(s.nome || ' (R$ ' || printf('%.2f', s.preco) || ')', ', ') AS servicos
FROM profissional p
JOIN profissional_servico ps ON ps.id_profissional = p.id_profissional
JOIN servico s               ON s.id_servico       = ps.id_servico
GROUP BY p.id_profissional, p.nome
ORDER BY p.nome;

-- Q12 (LEFT JOIN + GROUP_CONCAT)  [regra 18]
-- Pergunta de negócio: Quais são os telefones de contato de cada profissional?
SELECT p.nome AS profissional,
       GROUP_CONCAT(t.telefone, ' / ') AS telefones
FROM profissional p
LEFT JOIN telefone_profissional t ON t.id_profissional = p.id_profissional
GROUP BY p.id_profissional, p.nome
ORDER BY p.nome;

-- Q13 (JOIN de 3 tabelas + SUM + GROUP BY)
-- Pergunta de negócio: Quanto cada profissional faturou em cada tipo de serviço?
SELECT p.nome AS profissional, s.nome AS servico,
       COUNT(*) AS atendimentos, SUM(a.preco_cobrado) AS faturamento
FROM agendamento a
JOIN profissional p ON p.id_profissional = a.id_profissional
JOIN servico s      ON s.id_servico      = a.id_servico
WHERE a.status = 'concluido'
GROUP BY p.id_profissional, p.nome, s.id_servico, s.nome
ORDER BY p.nome, faturamento DESC;

-- Q14 (JOIN + CASE WHEN + IN)  [regra 7]
-- Pergunta de negócio: Quem atende às sextas e aos sábados, e em que horários?
SELECT p.nome AS profissional,
       CASE e.dia_semana WHEN 5 THEN 'Sexta' WHEN 6 THEN 'Sábado' END AS dia,
       e.hora_inicio, e.hora_fim
FROM expediente e
JOIN profissional p ON p.id_profissional = e.id_profissional
WHERE e.dia_semana IN (5, 6)
ORDER BY e.dia_semana, p.nome, e.hora_inicio;

-- #####################################################################
-- BLOCO D: subconsultas (IN, EXISTS, escalar)
-- #####################################################################

-- Q15 (subconsulta com IN)
-- Pergunta de negócio: Quais clientes já cancelaram pelo menos um agendamento?
SELECT nome, telefone
FROM cliente
WHERE id_cliente IN (SELECT id_cliente FROM agendamento WHERE status = 'cancelado')
ORDER BY nome;

-- Q16 (subconsulta com EXISTS, duas vezes)
-- Pergunta de negócio: Quais clientes já faltaram a um atendimento mas voltaram a agendar?
SELECT c.nome, c.telefone
FROM cliente c
WHERE EXISTS (SELECT 1 FROM agendamento f
              WHERE f.id_cliente = c.id_cliente AND f.status = 'faltou')
  AND EXISTS (SELECT 1 FROM agendamento n
              WHERE n.id_cliente = c.id_cliente AND n.status = 'agendado'
                AND n.data_hora_inicio >= '2026-11-23 00:00')
ORDER BY c.nome;

-- Q17 (subconsulta escalar na cláusula WHERE)
-- Pergunta de negócio: Quais atendimentos concluídos custaram mais do que o ticket médio do salão?
SELECT a.id_agendamento, c.nome AS cliente, s.nome AS servico, a.preco_cobrado
FROM agendamento a
JOIN cliente c ON c.id_cliente = a.id_cliente
JOIN servico s ON s.id_servico = a.id_servico
WHERE a.status = 'concluido'
  AND a.preco_cobrado > (SELECT AVG(preco_cobrado) FROM agendamento WHERE status = 'concluido')
ORDER BY a.preco_cobrado DESC, a.data_hora_inicio;

-- Q18 (JOIN com comparação entre colunas)  [regra 17]
-- Pergunta de negócio: Quais agendamentos foram feitos com um preço diferente do preço atual do serviço?
SELECT a.id_agendamento, s.nome AS servico, a.data_hora_inicio,
       a.preco_cobrado, s.preco AS preco_atual,
       ROUND(s.preco - a.preco_cobrado, 2) AS diferenca
FROM agendamento a
JOIN servico s ON s.id_servico = a.id_servico
WHERE a.preco_cobrado <> s.preco
ORDER BY a.data_hora_inicio;

-- #####################################################################
-- BLOCO E: UNION / DISTINCT, CASE WHEN, funções de data e de texto
-- #####################################################################

-- Q19 (UNION)
-- Pergunta de negócio: Qual a lista única de telefones do salão (clientes e profissionais)?
SELECT nome, telefone, 'Cliente' AS tipo
FROM cliente
UNION
SELECT p.nome, t.telefone, 'Profissional'
FROM profissional p
JOIN telefone_profissional t ON t.id_profissional = p.id_profissional
ORDER BY 3, 1;

-- Q20 (CASE WHEN + função de data strftime)
-- Pergunta de negócio: Os agendamentos se concentram de manhã ou à tarde?
SELECT CASE WHEN CAST(strftime('%H', data_hora_inicio) AS INTEGER) < 12
            THEN 'Manhã' ELSE 'Tarde' END AS turno,
       COUNT(*) AS agendamentos
FROM agendamento
WHERE status <> 'cancelado'
GROUP BY turno;

-- Q21 (função de data strftime + GROUP BY)
-- Pergunta de negócio: Quanto o salão faturou em cada mês?
SELECT strftime('%Y-%m', data_hora_inicio) AS mes,
       COUNT(*) AS atendimentos,
       SUM(preco_cobrado) AS faturamento
FROM agendamento
WHERE status = 'concluido'
GROUP BY mes
ORDER BY mes;

-- Q22 (DISTINCT dentro de COUNT)
-- Pergunta de negócio: Quantos clientes diferentes cada profissional já atendeu?
SELECT p.nome AS profissional,
       COUNT(*)                     AS atendimentos,
       COUNT(DISTINCT a.id_cliente) AS clientes_distintos
FROM agendamento a
JOIN profissional p ON p.id_profissional = a.id_profissional
WHERE a.status = 'concluido'
GROUP BY p.id_profissional, p.nome
ORDER BY clientes_distintos DESC;

-- Q23 (funções de texto: UPPER, SUBSTR, INSTR, LENGTH)
-- Pergunta de negócio: Como montar a lista de lembretes com o primeiro nome da cliente em maiúsculas e o DDD?
SELECT UPPER(SUBSTR(nome, 1, INSTR(nome, ' ') - 1)) AS primeiro_nome,
       LENGTH(nome)                                  AS tamanho_nome,
       SUBSTR(telefone, 2, 2)                        AS ddd,
       telefone
FROM cliente
ORDER BY primeiro_nome;

-- #####################################################################
-- BLOCO F: views úteis para o negócio
-- #####################################################################

DROP VIEW IF EXISTS vw_agenda_completa;
DROP VIEW IF EXISTS vw_resumo_cliente;

-- View 1: agenda legível (junta tudo e já calcula o horário de fim derivado)  [regras 11 e 12]
CREATE VIEW vw_agenda_completa AS
SELECT a.id_agendamento,
       a.data_hora_inicio,
       strftime('%Y-%m-%d %H:%M', a.data_hora_inicio,
                '+' || a.duracao_efetiva || ' minutes') AS data_hora_fim,
       p.nome AS profissional,
       c.nome AS cliente,
       s.nome AS servico,
       a.duracao_efetiva,
       a.preco_cobrado,
       a.status
FROM agendamento a
JOIN cliente      c ON c.id_cliente      = a.id_cliente
JOIN profissional p ON p.id_profissional = a.id_profissional
JOIN servico      s ON s.id_servico      = a.id_servico;

-- View 2: histórico resumido de cada cliente (visitas, gasto, última visita, faltas)
CREATE VIEW vw_resumo_cliente AS
SELECT c.id_cliente, c.nome, c.telefone,
       COUNT(CASE WHEN a.status = 'concluido' THEN 1 END)                      AS atendimentos_concluidos,
       COALESCE(SUM(CASE WHEN a.status = 'concluido' THEN a.preco_cobrado END), 0) AS total_gasto,
       MAX(CASE WHEN a.status = 'concluido' THEN a.data_hora_inicio END)       AS ultima_visita,
       COUNT(CASE WHEN a.status = 'faltou' THEN 1 END)                         AS faltas
FROM cliente c
LEFT JOIN agendamento a ON a.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome, c.telefone;

-- Q24 (consulta sobre a view 1)
-- Pergunta de negócio: Como está a agenda da Maria a partir de 23/11 (horários ocupados, em ordem)?
SELECT data_hora_inicio, data_hora_fim, cliente, servico, status
FROM vw_agenda_completa
WHERE profissional = 'Maria'
  AND data_hora_inicio >= '2026-11-23 00:00'
ORDER BY data_hora_inicio;

-- Q25 (consulta sobre a view 2)
-- Pergunta de negócio: Quais clientes mais gastaram e há quanto tempo não voltam (última visita)?
SELECT nome, atendimentos_concluidos, total_gasto, ultima_visita, faltas
FROM vw_resumo_cliente
WHERE atendimentos_concluidos > 0
ORDER BY total_gasto DESC, nome
LIMIT 10;

-- #####################################################################
-- BLOCO G: expressões de ÁLGEBRA RELACIONAL (com o SQL equivalente)
-- Notação:  σ = seleção   π = projeção   ⋈ = junção natural/theta
-- Para conferir no RelaX (opcional) digite os mesmos nomes de tabela/coluna.
-- #####################################################################

-- Q26 (SELEÇÃO)   σ preco > 40 (servico)
-- Pergunta de negócio: Quais serviços custam mais de R$ 40?
SELECT * FROM servico WHERE preco > 40;

-- Q27 (PROJEÇÃO)   π nome, telefone (cliente)
-- Pergunta de negócio: Qual a lista apenas de nomes e telefones dos clientes?
SELECT DISTINCT nome, telefone FROM cliente;

-- Q28 (SELEÇÃO + JUNÇÃO + PROJEÇÃO)
--   π nome, data_hora_inicio ( σ status = 'agendado' ( cliente ⋈ cliente.id_cliente = agendamento.id_cliente agendamento ) )
-- Pergunta de negócio: Quais clientes têm horário marcado e quando?
SELECT DISTINCT c.nome, a.data_hora_inicio
FROM cliente c
JOIN agendamento a ON c.id_cliente = a.id_cliente
WHERE a.status = 'agendado'
ORDER BY a.data_hora_inicio;
