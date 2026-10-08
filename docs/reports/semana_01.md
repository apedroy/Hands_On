# Relatorio da Semana 1

**Projeto:** Acelerador AES com interface SPI e baixo consumo  
**Data do registro:** 2026-10-08  
**Status:** Concluido; estudo, artefatos minimos e fluxo de compilacao/lint/simulacao executados com VCS

## Estudo

- O AES e uma cifra simetrica de blocos definida pelo NIST. O tamanho do bloco e 128 bits; as chaves podem ter 128, 192 ou 256 bits, com 10, 12 ou 14 rodadas, respectivamente.
- Na cifragem, as operacoes fundamentais incluem SubBytes, ShiftRows, MixColumns e AddRoundKey. A rodada final omite MixColumns. A expansao da chave gera as chaves de rodada.
- SPI e uma interface serial sincrona tipicamente composta por SCLK, CS_N, MOSI e MISO. CPOL define a polaridade de repouso do clock e CPHA define a fase de amostragem; suas combinacoes formam os modos 0 a 3. A especificacao funcional do projeto ainda deve determinar o modo e o enquadramento adotados.
- A integracao futura deve tratar explicitamente a travessia entre o clock SPI e o clock do sistema; sincronizadores simples nao substituem um protocolo de transferencia coerente para barramentos multibit.

## Ambiente e artefatos

- Estrutura inicial do repositorio criada, com areas separadas para RTL, testbench, documentacao, formal, sintese, UPF e scripts.
- Exemplo combinacional de XOR e testbench de quatro vetores adicionados.
- O comando unico `./scripts/check_week1.sh` compila e simula com o VCS da Synopsys e habilita o lint (`+lint=all`), carregando o ambiente Synopsys automaticamente quando necessario.
- Backlog inicial registrado em `docs/backlog.md`.
- Revisao dos arquivos RTL e testbench sem erros reportados pelo editor.

## Resultados

Em 2026-10-08, com o ambiente Synopsys carregado via `source /Tools/synopsys-scripts/snps.sh`, a execucao de `./scripts/check_week1.sh` concluiu com sucesso em ambiente limpo (um unico comando):

- Compilacao e elaboracao do RTL e do testbench com VCS X-2025.06-SP2 sem erros.
- Lint habilitado (`+lint=all`) sem avisos.
- Simulacao dos quatro vetores do smoke-test aprovada (`PASS: all 4 smoke-test vectors`), com `$finish` normal.
- Mensagem final `PASS: compilacao, lint e simulacao concluidos com VCS.` e codigo de saida 0.

Ferramentas Synopsys disponiveis no ambiente: VCS (`vcs`), Design Compiler (`dc_shell`), Formality (`fm_shell`), PrimeTime (`pt_shell`), ICC2 (`icc2_shell`) e Verdi, a serem usadas nas fases de sintese, equivalencia formal e analise.

O PDK e a especificacao funcional ainda devem ser fornecidos pelo instrutor conforme o plano do projeto.

## Proximos passos

1. Confirmar com o instrutor as versoes de ferramenta aceitas e obter a especificacao funcional.
2. Revisar o backlog inicial com o instrutor e o verificador parceiro.
3. Iniciar a Semana 2 (arquitetura e microarquitetura) apos receber a especificacao.

## Referencias de estudo

- NIST, *FIPS 197: Advanced Encryption Standard (AES)*: https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.197.pdf
- Analog Devices, *Introduction to SPI Interface*: https://www.analog.com/en/resources/analog-dialogue/articles/introduction-to-spi-interface.html