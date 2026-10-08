# Acelerador AES com interface SPI

Repositório do projeto hands-on de RTL Design: desenvolvimento de um acelerador AES controlado por SPI, com verificação, síntese e intenção de potência.

## Estrutura

- `docs/spec/`: especificação funcional fornecida pelo instrutor.
- `docs/architecture/`: arquitetura do sistema e arquitetura de energia.
- `docs/reports/`: relatórios semanais (`semana_XX.md`) e resultados das ferramentas.
- `rtl/`: código RTL sintetizável.
- `tb/`: testbenches e vetores de teste.
- `formal/`: propriedades SVA e scripts de verificação formal/equivalência.
- `syn/`: restrições SDC, scripts, netlists e relatórios de síntese.
- `upf/`: arquivos UPF e relatórios de verificação power-aware.
- `scripts/`: automação dos fluxos de lint, simulação, formal, síntese e UPF.

## Fluxo de trabalho

Cada entrega semanal deve ser identificada por uma tag ou branch e acompanhada do relatório correspondente em `docs/reports/`. Consulte a especificação e os documentos de arquitetura antes de integrar mudanças ao top-level.

## Semana 1: fluxo mínimo

O exemplo mínimo fica em `rtl/week1_smoke.v` e `tb/tb_week1.sv`. Para executá-lo, tenha Icarus Verilog (`iverilog` e `vvp`) e Verilator (`verilator`) instalados e execute na raiz do repositório:

```sh
./scripts/check_week1.sh
```

O script compila e simula o testbench e executa o lint do RTL. Consulte `docs/backlog.md` para as tarefas iniciais e `docs/reports/semana_01.md` para o registro da entrega.
