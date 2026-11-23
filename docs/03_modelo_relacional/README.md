# 3. Modelo relacional

## Arquivos
- `modelo_relacional.png`: imagem exportada do dbdiagram.io, usada no relatório.
- `modelo_relacional.dbml`: código DBML do diagrama, para recriar o modelo no dbdiagram.io.

## Ferramenta
dbdiagram.io. O código DBML está espelhado no `sql/01_ddl.sql`.

## Conversão do MER
| Origem no MER | Tabela no modelo relacional |
|---|---|
| Cliente | cliente |
| Profissional | profissional |
| Telefone do profissional (multivalorado) | telefone_profissional |
| Serviço | servico |
| Relacionamento N:N profissional—serviço | profissional_servico |
| Expediente (entidade fraca) | expediente |
| Indisponibilidade | indisponibilidade |
| Agendamento | agendamento |

## Tabelas (8)
- cliente: PK `id_cliente`.
- profissional: PK `id_profissional`.
- telefone_profissional: PK composta (`id_profissional`, `telefone`); FK `id_profissional`.
- servico: PK `id_servico`.
- profissional_servico: PK composta (`id_profissional`, `id_servico`); FKs para profissional e servico.
- expediente: PK composta (`id_profissional`, `dia_semana`, `hora_inicio`); FK `id_profissional`.
- indisponibilidade: PK `id_indisponibilidade`; FK `id_profissional`.
- agendamento: PK `id_agendamento`; FKs `id_cliente`, `id_profissional`, `id_servico` e a FK composta (`id_profissional`, `id_servico`) para `profissional_servico`.

## Checklist
- [x] Todas as PKs definidas
- [x] Todas as FKs definidas
- [x] Tabela de N:N criada (profissional_servico)
- [x] Atributo multivalorado convertido em tabela própria (telefone_profissional)
- [x] Entidade fraca com chave composta que inclui a chave da entidade dona (expediente)
- [x] Atributo derivado não armazenado (horário de fim do agendamento)

## Decisões de projeto
- **Chave estrangeira composta em agendamento:** `agendamento (id_profissional, id_servico)` aponta para `profissional_servico`. Isso garante no banco que um profissional só realiza serviços cadastrados para ele (regra 13).
- **Horário de fim derivado:** não é armazenado. Pode ser calculado como `data_hora_inicio + duracao_efetiva`.
- **Preço e duração copiados em agendamento:** `preco_cobrado` e `duracao_efetiva` preservam o histórico (regra 17). Ver a justificativa em `docs/04_normalizacao.md`.
- **Atributo email:** adicionado por ALTER TABLE, por isso aparece depois da criação da tabela cliente.

## Restrições que não aparecem no diagrama
O dbdiagram.io não representa CHECK, índices parciais nem regras entre linhas. Essas restrições estão no `docs/05_dicionario_dados.md` e no `01_ddl.sql`:
- Sem sobreposição de horários para o mesmo profissional ou cliente (regras 5 e 9). O DDL cobre apenas o mesmo horário de início.
- Duração efetiva entre a duração mínima e a máxima do serviço (regra 8).
- Cancelamento até 30 minutos antes do início (regra 6).

## Observação sobre tipos
O diagrama usa notação de tipos genérica (varchar, decimal). O banco SQLite armazena esses dados como TEXT, INTEGER e REAL. Essa diferença deve ser explicada no relatório.