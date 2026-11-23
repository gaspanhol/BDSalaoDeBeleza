# 4. Normalização (até 3FN)

O modelo relacional foi derivado do MER e está implementado no `01_ddl.sql`. Todas as tabelas estão na 3FN. Duas decisões envolvem cópias intencionais de dados (`preco_cobrado` e `duracao_efetiva` em `agendamento`), justificadas na seção da tabela `agendamento`.

Convenção usada: X → Y significa "X determina Y", ou seja, Y depende funcionalmente de X.

---

## Tabela: cliente

- **Chave primária:** `id_cliente`. Chaves candidatas: `telefone` e `email` (ambos UNIQUE).
- **1FN:** todos os atributos são valores atômicos (nome, telefone, data de cadastro e e-mail são valores simples).
- **2FN:** a chave primária é simples (um único atributo), então não há dependência parcial.
- **3FN:** `nome`, `telefone`, `data_cadastro` e `email` dependem diretamente de `id_cliente`. Nenhum atributo não-chave determina outro atributo não-chave. Os campos `telefone` e `email` são chaves candidatas, não dependências transitivas.
- **Conclusão:** a tabela `cliente` está em 3FN porque todos os atributos não-chave dependem diretamente de `id_cliente`.

---

## Tabela: profissional

- **Chave primária:** `id_profissional`. Chave candidata: `nome` (UNIQUE).
- **1FN:** valores atômicos. O telefone do profissional não está aqui, porque é multivalorado (ver `telefone_profissional`).
- **2FN:** chave simples, sem dependência parcial.
- **3FN:** `nome` e `ativo` dependem diretamente de `id_profissional`. Não há dependência entre dois atributos não-chave.
- **Conclusão:** a tabela `profissional` está em 3FN.

---

## Tabela: telefone_profissional

- **Chave primária:** composta por (`id_profissional`, `telefone`).
- **1FN:** cada linha tem um único telefone. Se o telefone ficasse na tabela `profissional` (como telefone1, telefone2), haveria grupos repetidos, o que viola a 1FN. Por isso o atributo multivalorado vira tabela própria.
- **2FN:** a tabela não tem atributos não-chave, então não há dependência parcial.
- **3FN:** não há atributos não-chave, portanto não há dependência transitiva.
- **Conclusão:** a tabela `telefone_profissional` está em 3FN.

---

## Tabela: servico

- **Chave primária:** `id_servico`. Chave candidata: `nome` (UNIQUE).
- **1FN:** valores atômicos.
- **2FN:** chave simples, sem dependência parcial.
- **3FN:** `preco`, `duracao_min` e `duracao_max` dependem diretamente de `id_servico`. Não há dependência entre `preco` e as durações, nem entre `duracao_min` e `duracao_max`.
- **Conclusão:** a tabela `servico` está em 3FN.

---

## Tabela: profissional_servico

- **Chave primária:** composta por (`id_profissional`, `id_servico`).
- **1FN:** valores atômicos.
- **2FN e 3FN:** a tabela só tem atributos de chave, então não há dependências parciais nem transitivas.
- **Conclusão:** a tabela é a implementação do relacionamento N:N entre profissional e serviço e está em 3FN.

---

## Tabela: expediente

- **Chave primária:** composta por (`id_profissional`, `dia_semana`, `hora_inicio`).
- **1FN:** `hora_inicio` e `hora_fim` são valores atômicos no formato HH:MM.
- **2FN:** o único atributo não-chave é `hora_fim`. Ele depende da chave inteira: o fim de um expediente depende do profissional, do dia da semana e do horário de início. Não depende só de `id_profissional`, porque um mesmo profissional tem vários expedientes com horários de fim diferentes. Não há dependência parcial.
- **3FN:** como há apenas um atributo não-chave, não há dependência transitiva.
- **Conclusão:** a tabela `expediente` está em 3FN.

---

## Tabela: indisponibilidade

- **Chave primária:** `id_indisponibilidade`.
- **1FN:** `data_hora_inicio` e `data_hora_fim` são valores temporais únicos no formato AAAA-MM-DD HH:MM, tratados como um valor atômico.
- **2FN:** chave simples, sem dependência parcial.
- **3FN:** `id_profissional`, `data_hora_inicio`, `data_hora_fim` e `motivo` dependem diretamente de `id_indisponibilidade`. A data de fim não depende da data de início de forma transitiva, porque a duração do bloqueio varia.
- **Conclusão:** a tabela `indisponibilidade` está em 3FN.

---

## Tabela: agendamento

- **Chave primária:** `id_agendamento`.
- **1FN:** valores atômicos. `data_hora_inicio` é um valor temporal único.
- **2FN:** chave simples, sem dependência parcial.
- **3FN:** esta é a tabela que exige análise cuidadosa.
  - `id_cliente`, `id_profissional`, `id_servico`, `data_hora_inicio`, `duracao_efetiva`, `preco_cobrado` e `status` dependem de `id_agendamento`.
  - `preco_cobrado` não depende de `id_servico` sozinho. Dois agendamentos do mesmo serviço podem ter preços diferentes ao longo do tempo (por exemplo, o corte a R$ 90 antes do reajuste e a R$ 95 depois). Por isso, não há dependência transitiva. O preço depende do serviço e do momento da reserva, ou seja, é um fato histórico do agendamento.
  - `duracao_efetiva` também não depende de `id_servico`, porque o corte varia de 60 a 180 minutos. Não há dependência transitiva.
  - `id_profissional` e `id_servico` não se determinam dentro desta tabela. A consistência entre eles (o profissional realiza o serviço) é garantida pela chave estrangeira composta para `profissional_servico`. Isso é integridade referencial, não dependência funcional.
- **Conclusão:** a tabela `agendamento` está em 3FN.

**Decisão de projeto:** `preco_cobrado` e `duracao_efetiva` são copiados de `servico` no momento da reserva. Isso atende à regra 17, que exige preservar o histórico quando o preço muda. Sem a cópia, uma alteração de preço em `servico` mudaria o valor de atendimentos já realizados.

**Observação:** a regra 8 (duração efetiva entre a duração mínima e a máxima do serviço) não está garantida no DDL. Ela fica para um trigger ou para a aplicação, e isso deve ser registrado no item de aprofundamento.

---

## Resumo

| Tabela | 1FN | 2FN | 3FN |
|---|---|---|---|
| cliente | sim | sim | sim |
| profissional | sim | sim | sim |
| telefone_profissional | sim | sim | sim |
| servico | sim | sim | sim |
| profissional_servico | sim | sim | sim |
| expediente | sim | sim | sim |
| indisponibilidade | sim | sim | sim |
| agendamento | sim | sim | sim (com cópias intencionais justificadas) |