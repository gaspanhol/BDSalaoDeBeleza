# 5. Dicionário de dados

Tipos usados (SQLite): INTEGER, TEXT e REAL. Datas e horas são armazenadas como TEXT nos formatos AAAA-MM-DD, HH:MM e AAAA-MM-DD HH:MM.

Legenda das restrições: PK = chave primária; FK = chave estrangeira; NN = NOT NULL; UQ = UNIQUE; CK = CHECK; DF = DEFAULT.

| Tabela | Campo | Tipo | Restrições | Descrição |
|---|---|---|---|---|
| cliente | id_cliente | INTEGER | PK, AUTOINCREMENT, NN | Identificador do cliente. |
| cliente | nome | TEXT | NN, CK (tamanho mínimo de 3 caracteres) | Nome do cliente. Exigido no cadastro (regra 3). |
| cliente | telefone | TEXT | NN, UQ, CK (formato (DD) 9XXXX-XXXX) | Telefone de contato. Exigido no cadastro (regra 3). |
| cliente | data_cadastro | TEXT | NN, DF CURRENT_DATE | Data em que o cliente foi cadastrado. |
| cliente | email | TEXT | UQ, CK (formato de e-mail ou NULL) | Opcional. Usado para lembretes de agendamento (regra 18). Adicionado por ALTER TABLE. |
| profissional | id_profissional | INTEGER | PK, AUTOINCREMENT, NN | Identificador do profissional. |
| profissional | nome | TEXT | NN, UQ, CK (tamanho mínimo de 2 caracteres) | Nome do profissional. |
| profissional | ativo | INTEGER | NN, DF 1, CK (0 ou 1) | Indica se o profissional está ativo (1) ou inativo (0). |
| telefone_profissional | id_profissional | INTEGER | PK (composta), FK → profissional.id_profissional (ON DELETE e ON UPDATE CASCADE), NN | Profissional dono do telefone. |
| telefone_profissional | telefone | TEXT | PK (composta), NN, CK (formato (DD) 9XXXX-XXXX) | Telefone do profissional. Atributo multivalorado (regra 19). |
| servico | id_servico | INTEGER | PK, AUTOINCREMENT, NN | Identificador do serviço. |
| servico | nome | TEXT | NN, UQ | Nome do serviço (corte de cabelo, manicure, pedicure, massagem). |
| servico | preco | REAL | NN, CK (maior que zero) | Preço único do serviço, em reais (regra 14). |
| servico | duracao_min | INTEGER | NN, CK (maior que zero) | Duração mínima do serviço, em minutos (regra 8). |
| servico | duracao_max | INTEGER | NN, CK (maior que zero e maior ou igual a duracao_min) | Duração máxima do serviço, em minutos (regra 8). |
| profissional_servico | id_profissional | INTEGER | PK (composta), FK → profissional.id_profissional (ON DELETE e ON UPDATE CASCADE), NN | Profissional que realiza o serviço. |
| profissional_servico | id_servico | INTEGER | PK (composta), FK → servico.id_servico (ON DELETE e ON UPDATE CASCADE), NN | Serviço que o profissional realiza (regra 13). |
| expediente | id_profissional | INTEGER | PK (composta), FK → profissional.id_profissional (ON DELETE e ON UPDATE CASCADE), NN | Profissional ao qual o expediente pertence. |
| expediente | dia_semana | INTEGER | PK (composta), NN, CK (entre 0 e 6) | Dia da semana: 0 = domingo, 6 = sábado (mesmo padrão de strftime('%w')). |
| expediente | hora_inicio | TEXT | PK (composta), NN, CK (formato HH:MM) | Horário de início do intervalo de atendimento. |
| expediente | hora_fim | TEXT | NN, CK (formato HH:MM e maior que hora_inicio) | Horário de fim do intervalo de atendimento (regra 7). |
| indisponibilidade | id_indisponibilidade | INTEGER | PK, AUTOINCREMENT, NN | Identificador do bloqueio de horário. |
| indisponibilidade | id_profissional | INTEGER | FK → profissional.id_profissional (ON DELETE e ON UPDATE CASCADE), NN | Profissional que marcou o bloqueio. |
| indisponibilidade | data_hora_inicio | TEXT | NN, CK (formato AAAA-MM-DD HH:MM, valor de data válido) | Início do período indisponível (regra 10). |
| indisponibilidade | data_hora_fim | TEXT | NN, CK (formato AAAA-MM-DD HH:MM, valor de data válido, maior que data_hora_inicio) | Fim do período indisponível (regra 10). |
| indisponibilidade | motivo | TEXT | (opcional) | Motivo do bloqueio, por exemplo, manutenção de equipamento. |
| agendamento | id_agendamento | INTEGER | PK, AUTOINCREMENT, NN | Identificador do agendamento. |
| agendamento | id_cliente | INTEGER | FK → cliente.id_cliente (ON DELETE RESTRICT, ON UPDATE CASCADE), NN | Cliente que fez a reserva (regra 2). |
| agendamento | id_profissional | INTEGER | FK → profissional.id_profissional (ON DELETE RESTRICT, ON UPDATE CASCADE), NN | Profissional que atende o agendamento (regra 2). |
| agendamento | id_servico | INTEGER | FK → servico.id_servico (ON DELETE RESTRICT, ON UPDATE CASCADE), NN | Serviço agendado (regra 2). |
| agendamento | data_hora_inicio | TEXT | NN, CK (formato AAAA-MM-DD HH:MM, valor de data válido) | Início do atendimento. O horário de fim é derivado: início + duração efetiva. |
| agendamento | duracao_efetiva | INTEGER | NN, CK (maior que zero) | Duração do atendimento em minutos, informada na reserva (regra 8). O DDL não garante que esteja entre duracao_min e duracao_max. |
| agendamento | preco_cobrado | REAL | NN, CK (maior que zero) | Preço do serviço copiado no momento da reserva (regra 17). |
| agendamento | status | TEXT | NN, DF 'agendado', CK (agendado, concluido, cancelado ou faltou) | Situação do agendamento (regra 6). |

**Restrições únicas de horário (índices, não aparecem na tabela acima):**
- `ux_agend_prof_inicio_ativo`: impede dois agendamentos ativos do mesmo profissional no mesmo horário de início (regras 5 e 9).
- `ux_agend_cli_inicio_ativo`: impede dois agendamentos ativos do mesmo cliente no mesmo horário de início (regra 5).
- `ux_cliente_email`: impede e-mails repetidos entre clientes.