# Relatório da Semana 3

**Projeto:** Acelerador AES com interface SPI e baixo consumo

**Status:** RTL das transformações e testes aprovados; microarquitetura proposta
para revisão do instrutor/verificador parceiro

## Entrega

- `minisoc_aes_add_round_key.sv`: XOR de estado e round key; AddRoundKey é sua
  própria inversa.
- `minisoc_aes_mix_columns.sv`: mistura independente das quatro colunas sobre
  GF(2^8), usando o polinômio AES `x^8 + x^4 + x^3 + x + 1`.
- `minisoc_aes_inv_sbox.sv` e `minisoc_aes_inv_sub_bytes.sv`: tabela inversa e
  aplicação byte a byte.
- `minisoc_aes_inv_shift_rows.sv`: rotação inversa das linhas.
- `minisoc_aes_inv_mix_columns.sv`: transformação inversa com coeficientes
  `0e`, `0b`, `0d` e `09` em GF(2^8).
- Testbench autoverificável em `tb/tb_week3.sv` e comando único
  `./scripts/check_week3.sh`.
- Proposta de microarquitetura em `docs/architecture/microarquitetura_v1.md`.

## Verificação

Executado com:

```sh
source /Tools/synopsys-scripts/snps.sh
./scripts/check_week3.sh
```

Resultado: compilação e lint VCS aprovados; 256 valores da InvS-box passaram;
MixColumns/InvMixColumns conferem com os estados do exemplo AES-128; AddRoundKey
confere com a round key 1; InvSubBytes e InvShiftRows conferem com estados de
referência do exemplo AES-128 de decifragem. Todos os testes finalizaram em PASS.

## Pendências

- A microarquitetura é uma proposta, não uma arquitetura aprovada. Apresentá-la
  ao instrutor e ao verificador parceiro e registrar as decisões pendentes.
- A implementação de `minisoc_aes_key_exp` e do datapath completo pertence à
  Semana 4; o controlador/memória integrados ficam para a Semana 6.
