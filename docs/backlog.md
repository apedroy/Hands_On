# Backlog inicial

Status inicial em 2026-10-01. Itens dependentes de material ou acesso do instrutor estao identificados como bloqueados.

| Semana | Tarefas | Status |
| --- | --- | --- |
| 01 | Estudar AES e SPI; preparar ambiente; validar exemplo minimo; registrar backlog e estudo | Concluido: estudo, exemplo, testbench e fluxo minimo (compilacao, lint e simulacao com VCS) executados e aprovados |
| 02 | Receber especificacao; definir arquitetura, clocks, resets, interfaces e mapa de registradores | Aguardando especificacao funcional |
| 03 | Implementar transformacoes de rodada AES e testes unitarios | Pendente |
| 04 | Implementar expansao de chave, controle e vetores FIPS-197 | Pendente |
| 05 | Implementar SPI, sincronizacao e banco de registradores | Pendente |
| 06 | Integrar top-level, executar teste ponta a ponta e analise CDC; congelar RTL v1.0 | Pendente |
| 07 | Preparar SDC, sintetizar baseline e analisar area, timing e potencia | Aguardando PDK e ferramentas do instrutor |
| 08 | Definir plano de propriedades e executar verificacao formal inicial | Aguardando ferramenta formal |
| 09 | Fechar propriedades e executar equivalencia RTL/netlist; publicar RTL v1.1 | Aguardando ferramenta formal |
| 10 | Definir dominios, modos e sequencias de energia | Pendente |
| 11 | Escrever UPF e executar verificacao estatica e simulacao power-aware | Aguardando PDK e ferramentas do instrutor |
| 12 | Implementar controlador e sequencia de power gating | Pendente |
| 13 | Aplicar clock gating e demais tecnicas; publicar RTL v2.0 | Aguardando biblioteca/celulas ICG |
| 14 | Sintetizar low power, comparar baseline e executar regressao formal | Aguardando PDK e ferramentas do instrutor |
| 15 | Consolidar documentacao, apresentar resultados e preparar artigo | Pendente |

## Pendencias imediatas

- [ ] Solicitar ao instrutor a especificacao funcional e os criterios detalhados de cada interface.
- [ ] Solicitar o PDK e as bibliotecas necessarios para sintese, formal, CDC e UPF.
- [x] Executar `./scripts/check_week1.sh` com o ambiente Synopsys (VCS); compilacao, simulacao e lint aprovados e registrados no relatorio da Semana 1.
- [ ] Abrir issue para cada defeito encontrado pelo verificador parceiro nas entregas futuras.