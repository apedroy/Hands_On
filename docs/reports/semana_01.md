# Relatorio da Semana 1

**Projeto:** Acelerador AES com interface SPI e baixo consumo  
**Data do registro:** 2026-10-01  
**Status:** Parcial; estudo e artefatos minimos registrados, aceite HDL bloqueado por dependencias ausentes

## Estudo

- O AES e uma cifra simetrica de blocos definida pelo NIST. O tamanho do bloco e 128 bits; as chaves podem ter 128, 192 ou 256 bits, com 10, 12 ou 14 rodadas, respectivamente.
- Na cifragem, as operacoes fundamentais incluem SubBytes, ShiftRows, MixColumns e AddRoundKey. A rodada final omite MixColumns. A expansao da chave gera as chaves de rodada.
- SPI e uma interface serial sincrona tipicamente composta por SCLK, CS_N, MOSI e MISO. CPOL define a polaridade de repouso do clock e CPHA define a fase de amostragem; suas combinacoes formam os modos 0 a 3. A especificacao funcional do projeto ainda deve determinar o modo e o enquadramento adotados.
- A integracao futura deve tratar explicitamente a travessia entre o clock SPI e o clock do sistema; sincronizadores simples nao substituem um protocolo de transferencia coerente para barramentos multibit.

## Ambiente e artefatos

- Estrutura inicial do repositorio criada, com areas separadas para RTL, testbench, documentacao, formal, sintese, UPF e scripts.
- Exemplo combinacional de XOR e testbench de quatro vetores adicionados.
- O comando unico `./scripts/check_week1.sh` foi preparado para compilar e simular com Icarus Verilog e executar lint com Verilator.
- Backlog inicial registrado em `docs/backlog.md`.
- Revisao dos arquivos RTL e testbench sem erros reportados pelo editor.

## Resultados e bloqueios

Na verificacao do ambiente em 2026-10-01, a execucao de `bash scripts/check_week1.sh` parou com `Erro: ferramenta obrigatoria nao encontrada: iverilog`. `iverilog`, `vvp` e `verilator` nao estao disponiveis no `PATH`. Portanto, compilacao RTL, simulacao e lint ainda nao foram executados; o criterio de aceite da Semana 1 permanece pendente. O script reporta a dependencia ausente sem declarar sucesso indevidamente.

O PDK, a especificacao funcional e as ferramentas licenciadas de sintese/formal/UPF devem ser fornecidos pelo instrutor conforme o plano do projeto.

## Proximos passos

1. Obter acesso ou instalar Icarus Verilog (`iverilog`, `vvp`) e Verilator (`verilator`).
2. Executar `./scripts/check_week1.sh` e, se aprovado, registrar compilacao, simulacao dos quatro vetores e lint neste relatorio.
3. Confirmar com o instrutor as versoes de ferramenta aceitas e obter a especificacao funcional.
4. Revisar o backlog inicial com o instrutor e o verificador parceiro.

## Referencias de estudo

- NIST, *FIPS 197: Advanced Encryption Standard (AES)*: https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.197.pdf
- Analog Devices, *Introduction to SPI Interface*: https://www.analog.com/en/resources/analog-dialogue/articles/introduction-to-spi-interface.html