# Relatorio da Semana 4

**Projeto:** Acelerador AES com interface SPI e baixo consumo

**Status:** expansao e datapath AES-128 implementados; testes funcionais
aprovados com VCS em 2026-11-13.

## Entrega

- [minisoc_aes_key_exp.sv](../../rtl/minisoc_aes/minisoc_aes_key_exp.sv):
  expansao da chave AES-128 em K0..K10.
- [minisoc_aes_dp.sv](../../rtl/minisoc_aes/minisoc_aes_dp.sv):
  cifra e cifra inversa de um bloco de 128 bits, com START/BUSY/DONE.
- [tb_week4.sv](../../tb/tb_week4.sv): teste autoverificavel das chaves,
  dos blocos completos e do controle.
- [check_week4.sh](../../scripts/check_week4.sh): compilacao, lint e simulacao
  com intermediarios isolados em diretorio temporario.
- [Microarquitetura](../architecture/microarquitetura_v1.md): diagrama interno,
  interfaces, estados e latencia atualizados para a implementacao.

## Como e por que

A expansao e pre-computada: uma chave por ciclo, com quatro S-boxes para
RotWord/SubWord, Rcon e XORs. As 11 chaves ocupam 1408 bits de armazenamento
logico, alem dos auxiliares. Isso evita implementar a expansao reversa e permite
decifrar usando K10..K0. Nao e uma medida de area fisica.

O datapath reutiliza as transformacoes das Semanas 2 e 3. Guarda estado, chave
e direcao ao aceitar START e executa uma rodada por ciclo apos preparar as
chaves. A ultima rodada nao usa MixColumns nem, na inversa, InvMixColumns.
AddRoundKey e compartilhado entre os caminhos.

O resultado sai 23 ciclos apos aceitar START; DONE e um pulso, e BUSY volta a
zero na conclusao. As chaves sao recalculadas para cada bloco, inclusive quando
a chave externa nao muda. START durante BUSY e ignorado. Reset aborta a
operacao, limpa o banco de chaves e zera a saida. Nao foi usado `genvar`.

## Verificacao executada

```sh
source /Tools/synopsys-scripts/snps.sh
./scripts/check_week4.sh
```

VCS X-2025.06-SP2, com `+lint=all`:

- PASS: todas as 11 chaves comparadas com a FIPS-197, Apendice A.1.
- PASS: cifragem e decifragem do vetor do Apendice C.1:
  chave `000102030405060708090a0b0c0d0e0f`,
  texto claro `00112233445566778899aabbccddeeff`,
  texto cifrado `69c4e0d86a7b0430d8cdb78070b4c55a`.
- PASS: cifragem e decifragem do vetor do Apendice B:
  chave `2b7e151628aed2a6abf7158809cf4f3c`,
  texto claro `3243f6a8885a308d313198a2e0370734`,
  texto cifrado `3925841d02dc09fbdc118597196a0b32`.
- PASS: chave/bloco zerados, cifrado `66e94bd4ef8a2c3b884cfa59ca342b2e`,
  nos dois sentidos.
- PASS: operacoes consecutivas com mudanca de chave/direcao; captura das entradas;
  START ignorado durante expansao e rodadas; DONE de um ciclo; saida estavel;
  latencias de dez ciclos para expansao e 23 para o datapath.
- PASS: reset durante expansao e durante as rodadas, sem conclusao espuria e
  com recuperacao para uma nova operacao.

Nao houve erros de compilacao ou avisos de lint no RTL. O VCS emitiu avisos
`Lint-[NS]` para esperas `@(negedge clk);` no testbench: sao esperas de simulacao,
nao instrucoes de hardware incompletas. Tambem emitiu o aviso informativo de
habilitacao de `-lca`, ja utilizado nos fluxos anteriores.

## Limites e proximos passos

- Este bloco nao inclui SPI, memoria, modos CBC/CTR/PCBC/CFB/OFB nem engine
  multi-bloco. Isso nao faz parte do datapath primitivo desta semana.
- Nao houve sintese, verificacao formal ou analise de timing/potencia; passar
  vetores nao prova seguranca contra canais laterais nem fechamento a 2 GHz.
- A microarquitetura geral ainda depende da revisao do instrutor/parceiro.
- A identificacao da entrega por branch/tag deve ser feita ao publicar;
  nenhum commit, branch ou tag foi criado nesta atividade.
