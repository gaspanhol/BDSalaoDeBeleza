# 2. MER

## Arquivos
- `mer.drawio` (ou `.drawio`): arquivo-fonte do diagrama
- `mer.png`: imagem exportada para o relatório

## Convenções usadas
- Chave primária: atributo sublinhado
- Atributo multivalorado: elipse dupla (telefone do profissional)
- Atributo derivado: elipse tracejada (horário de fim do agendamento)
- Entidade fraca: retângulo duplo (expediente)
- Relacionamento identificador: losango duplo, quando a entidade fraca depende da forte
- Cardinalidades na notação (mínimo, máximo)

## Entidades (6)
- Cliente
- Profissional
- Serviço
- Agendamento
- Expediente (entidade fraca de Profissional)
- Indisponibilidade

## Relacionamentos
- Cliente faz Agendamento: (0,N) — (1,1)
- Profissional atende Agendamento: (0,N) — (1,1)
- Serviço é agendado em Agendamento: (0,N) — (1,1)
- Profissional realiza Serviço: N:N, (1,N) — (1,N)
- Profissional possui Expediente: (0,N) — (1,1), identificador
- Profissional bloqueia Indisponibilidade: (0,N) — (1,1)

## Requisitos obrigatórios
- [x] Mínimo de 6 entidades
- [x] Relacionamento N:N (Profissional — Serviço)
- [x] Entidade fraca (Expediente)
- [x] Atributo multivalorado (telefone do profissional)
- [x] Atributo derivado (horário de fim do agendamento)

## Restrições que não aparecem no diagrama
Ficam para o modelo relacional, DDL e trigger/aplicação:
- Um cliente não pode ter agendamentos com horários sobrepostos (regra 5).
- Um profissional não pode ter agendamentos com tempo sobreposto (regra 9).
- Um profissional só pode realizar serviços cadastrados para ele (regra 13).
- A duração efetiva deve estar entre a mínima e a máxima do serviço (regra 8).

## Decisões de projeto
- Preço fica em Serviço e é copiado para o Agendamento no momento da reserva (regras 14 a 17).
- Duração mínima e máxima ficam em Serviço; a duração efetiva fica em Agendamento.