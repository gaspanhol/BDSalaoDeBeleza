# 6. Item de aprofundamento

**Item escolhido:** trigger (SQLite) — script `sql/04_aprofundamento.sql`

## Justificativa

Algumas regras de negócio do salão **não podem ser expressas** com `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE` ou `CHECK`, porque dependem da **hora atual** ou de **outras linhas** da tabela. Sem elas, o banco aceitaria dados que quebram o negócio (dois clientes no mesmo horário com a mesma profissional, cancelamento em cima da hora etc.). O trigger é o mecanismo do SGBD para fazer essa verificação **dentro do próprio banco**, e não depender de cada aplicação lembrar de validar.

O que o DDL já garante, e o que ficou para os triggers:

| Regra | Descrição | Onde é garantida |
|---|---|---|
| 13 | Profissional só faz os serviços cadastrados para ele | **DDL** — FK composta `(id_profissional, id_servico)` |
| 17 | Preço congelado no agendamento | **DDL** — coluna `preco_cobrado` |
| 5 e 9 (parcial) | Dois agendamentos ativos **começando no mesmo instante** | **DDL** — índices únicos parciais |
| 6 | Cancelar só até 30 min antes do início | **Trigger** `trg_agend_cancelamento_prazo` |
| 5 e 9 | Nenhuma **sobreposição** de horários (profissional e cliente) | **Triggers** `trg_agend_sobreposicao_ins` / `_upd` |
| 8 | Duração efetiva entre a mínima e a máxima do serviço | **Triggers** `trg_agend_duracao_ins` / `_upd` |

## Cenário de uso

- Uma cliente tenta cancelar o horário **10 minutos antes** de começar: o banco recusa (regra 6).
- A recepção tenta marcar uma manicure às 10h30 para a Maria, que já tem massagem das 10h às 11h: o banco recusa (regra 9).
- A mesma cliente tenta marcar dois serviços que se cruzam, com profissionais diferentes: o banco recusa (regra 5).
- Alguém digita um corte de cabelo com 30 minutos (o mínimo é 60): o banco recusa (regra 8).

## Implementação

Código completo e comentado em [`sql/04_aprofundamento.sql`](../sql/04_aprofundamento.sql). Rodar depois de `01`, `02` e `03`.

Resumo dos 5 triggers (todos `BEFORE`, usando `RAISE(ABORT, 'mensagem')` para barrar a operação):

1. **`trg_agend_cancelamento_prazo`** — antes de mudar o `status` para `cancelado`: bloqueia se o agendamento não estiver `agendado` e bloqueia se a hora atual (`'now','localtime'`) passou de *início − 30 min*.
2. **`trg_agend_sobreposicao_ins`** e **`trg_agend_sobreposicao_upd`** — ao inserir ou alterar um agendamento não cancelado, procura outro agendamento **ativo** do mesmo profissional ou do mesmo cliente cujo intervalo se cruze. Dois intervalos se cruzam quando `início_A < fim_B` **e** `início_B < fim_A`. Agendamentos "colados" (um termina às 11h e o outro começa às 11h) são permitidos. O horário de fim é calculado na hora (atributo derivado).
3. **`trg_agend_duracao_ins`** e **`trg_agend_duracao_upd`** — compara `duracao_efetiva` com `duracao_min` e `duracao_max` do serviço.

Exemplo (regra 6):

```sql
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
```

## Evidência (testes)

Rodar **um comando por vez** na aba *Executar SQL* do DB Browser. Os que devem dar erro mostram a mensagem em vermelho. **Depois dos testes, não grave as alterações** (use *Reverter alterações*), para não sujar o banco.

Base dos `INSERT`: `INSERT INTO agendamento (id_cliente, id_profissional, id_servico, data_hora_inicio, duracao_efetiva, preco_cobrado, status) VALUES ...`

| # | Teste | Comando (após `VALUES`, ou `UPDATE`) | Resultado esperado |
|---|---|---|---|
| 1 | Duração abaixo do mínimo (corte com 30 min) | `(1, 1, 1, '2026-12-10 10:00', 30, 95, 'agendado')` | ❌ *Duração fora dos limites (mínimo/máximo) do serviço* |
| 2 | Duração acima do máximo (corte com 200 min) | `(1, 1, 1, '2026-12-10 10:00', 200, 95, 'agendado')` | ❌ mesma mensagem |
| 3 | Manicure com 60 min (a duração fixa é 45) | `(1, 4, 2, '2026-12-10 10:00', 60, 35, 'agendado')` | ❌ mesma mensagem |
| 4 | Profissional sobreposta (Maria já tem massagem 10h–11h em 01/12) | `(7, 2, 2, '2026-12-01 10:30', 45, 35, 'agendado')` | ❌ *Profissional já possui agendamento nesse intervalo* |
| 5 | Cliente sobreposta com outra profissional (cliente 4 tem a massagem 10h–11h) | `(4, 4, 2, '2026-12-01 10:30', 45, 35, 'agendado')` | ❌ *Cliente já possui agendamento nesse intervalo* |
| 6 | Agendamento colado (começa às 11h, quando a massagem termina) | `(7, 2, 2, '2026-12-01 11:00', 45, 35, 'agendado')` | ✅ inserido |
| 7 | Corte válido com 120 min | `(9, 1, 1, '2026-12-10 09:00', 120, 95, 'agendado')` | ✅ inserido |
| 8 | Remarcar um agendamento para cima de outro | `UPDATE agendamento SET data_hora_inicio = '2026-12-01 10:30' WHERE id_agendamento = 45;` | ❌ *Profissional já possui agendamento nesse intervalo* (a Maria tem a massagem do id 41 nesse horário) |
| 9 | Alterar duração da manicure para 90 | `UPDATE agendamento SET duracao_efetiva = 90 WHERE id_agendamento = 43;` | ❌ duração fora dos limites |
| 10 | Cancelar agendamento futuro (03/12) | `UPDATE agendamento SET status = 'cancelado' WHERE id_agendamento = 43;` | ✅ cancelado |
| 11 | "Cancelar" um atendimento já concluído | `UPDATE agendamento SET status = 'cancelado' WHERE id_agendamento = 2;` | ❌ *Só é possível cancelar agendamentos com status agendado* |
| 12 | Criar agendamento daqui a 10 min | `(1, 1, 1, strftime('%Y-%m-%d %H:%M','now','localtime','+10 minutes'), 60, 95, 'agendado')` | ✅ inserido |
| 13 | Cancelar o do teste 12 (faltam 10 min) | `UPDATE agendamento SET status = 'cancelado' WHERE id_agendamento = (SELECT MAX(id_agendamento) FROM agendamento);` | ❌ *Cancelamento só é permitido até 30 minutos antes do início* |

Os testes devem ser feitos na ordem da tabela. Todos foram executados no `banco/salao.db` e se comportaram como descrito.

## Limitações assumidas (ficam para a aplicação)

- O banco **não** verifica se o agendamento cabe dentro do **expediente** do profissional, nem se colide com uma **indisponibilidade** (regras 4, 7 e 10). Isso também exigiria trigger; foi deixado como responsabilidade da aplicação, para manter o item de aprofundamento enxuto.
- O prazo de 1 hora para marcar uma indisponibilidade (regra 10) também fica na aplicação.
- O trigger da regra 6 usa o **relógio do computador** onde o banco está rodando (`localtime`).
- Os agendamentos de `02_dml.sql` foram inseridos já com o status final (histórico fictício), por isso o trigger de cancelamento só atua em `UPDATE`.
