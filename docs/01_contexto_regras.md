# 1. Contexto do negócio e regras de negócio

## 1.1 Contexto

O salão de beleza oferece os serviços de manicure, pedicure, massagem e corte de cabelo. O cliente pode agendar um horário com um dos profissionais, que realizará o serviço escolhido de forma gentil e profissional.

Os profissionais e os serviços que realizam são:

- **Marcos:** corte de cabelo
- **Maria:** manicure, pedicure e massagem
- **Lucia:** manicure, pedicure e massagem
- **Ana:** manicure e pedicure

Cada profissional possui um ou mais telefones de contato.

## 1.2 Regras de negócio

### Clientes e agendamentos

1. Um cliente pode ter vários agendamentos, mas cada agendamento pertence a um único cliente.
2. Um agendamento deve ter exatamente um cliente, um profissional, um serviço e um horário de início.
3. Um cliente deve ter cadastro com nome e telefone para poder reservar um horário.
4. Um cliente só pode reservar um horário que esteja livre por todo o tempo de duração do serviço escolhido.
5. Um cliente não pode ter dois agendamentos com horários sobrepostos, mesmo com profissionais diferentes.
6. Um cliente pode cancelar um agendamento até 30 minutos antes do seu início. O cancelamento altera o status do agendamento para cancelado e libera o horário.

### Profissionais, agenda e duração

7. Um profissional define os intervalos de tempo em que atende em cada dia, por exemplo, das 9h às 12h.
8. Cada serviço tem uma duração mínima e uma máxima, em minutos. A duração efetiva do agendamento fica entre esses valores e é informada no momento da reserva. Manicure, pedicure e massagem têm duração fixa; o corte de cabelo varia de 60 a 180 minutos, conforme a complexidade.
9. Um profissional não pode ter dois agendamentos ativos com sobreposição de tempo.
10. Um profissional pode marcar um intervalo como indisponível até 1 hora antes do seu início, desde que não haja agendamento sobreposto a ele.
11. Um profissional deve conseguir visualizar sua agenda, com cada intervalo marcado como livre, reservado ou indisponível.
12. Um cliente deve conseguir visualizar os horários livres de cada profissional, considerando a duração do serviço escolhido.
13. Um profissional só pode realizar os serviços que estão cadastrados para ele.

### Serviços e preços

14. O preço de cada serviço é único no salão, independentemente de quem o realiza.
15. O preço de um serviço pode ser alterado por qualquer profissional responsável por ele.
16. Um cliente deve conseguir visualizar os serviços oferecidos por cada profissional e seus respectivos preços.
17. No momento do agendamento, o preço do serviço é registrado no próprio agendamento, para que alterações futuras de preço não afetem atendimentos já realizados ou marcados.
18. Um cliente pode informar um e-mail opcional para receber lembretes de agendamento.

### Contatos

19. Um profissional pode ter um ou mais telefones, e um cliente deve conseguir visualizar os telefones dos profissionais.
