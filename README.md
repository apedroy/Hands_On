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

O exemplo mínimo fica em `rtl/week1_smoke.v` e `tb/tb_week1.sv`. O fluxo usa o VCS da Synopsys (toolchain do curso). Basta executar na raiz do repositório:

```sh
./scripts/check_week1.sh
```

O script carrega o ambiente Synopsys (`source /Tools/synopsys-scripts/snps.sh`) automaticamente caso o VCS ainda não esteja no `PATH`, compila e simula o testbench com lint habilitado (`+lint=all`) e confirma os vetores do smoke-test. Consulte `docs/backlog.md` para as tarefas iniciais e `docs/reports/semana_01.md` para o registro da entrega.

## Semana 2: transformações AES

`rtl/minisoc_aes/minisoc_aes_sbox.sv`,
`rtl/minisoc_aes/minisoc_aes_sub_bytes.sv` e
`rtl/minisoc_aes/minisoc_aes_shift_rows.sv` implementam as transformações combinacionais
definidas no roteiro. Execute `./scripts/check_week2.sh` para compilar com lint
e conferir as 256 entradas da S-box e os estados das rodadas 1 e 10 do
Apêndice B da FIPS-197. O resultado e as pendências sobre o Block Guide estão
em `docs/reports/semana_02.md`.

## Semana 3: transformações de rodada e microarquitetura

As transformações diretas e inversas AES ficam em `rtl/minisoc_aes/`.
Execute `./scripts/check_week3.sh` para compilar com lint e simular os vetores
intermediários de cifragem/decifragem. A proposta iterativa de microarquitetura
e as decisões para revisão estão em `docs/architecture/microarquitetura_v1.md`;
os resultados estão em `docs/reports/semana_03.md`.

## Semana 4: expansao de chave e datapath AES-128

`rtl/minisoc_aes/minisoc_aes_key_exp.sv` pre-calcula as 11 chaves de rodada,
e `rtl/minisoc_aes/minisoc_aes_dp.sv` cifra ou decifra um bloco de 128 bits.
O datapath aceita `start` quando `busy=0`, captura as entradas e sinaliza o
resultado com um pulso de `done`. Ainda nao inclui SPI, memoria ou modos de
encadeamento.

```sh
source /Tools/synopsys-scripts/snps.sh
./scripts/check_week4.sh
```

O teste verifica todas as chaves do Apendice A.1, os vetores dos Apendices B
e C.1 da FIPS-197 nos dois sentidos e o controle de operacao/reset. A compilacao
da Semana 4 fica isolada em diretorio temporario, inclusive os intermediarios
do VCS. Consulte `docs/reports/semana_04.md` e a secao da Semana 4 em
`docs/architecture/microarquitetura_v1.md` para interfaces, latencia e escolhas.
