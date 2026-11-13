# Relatorio da Semana 2

**Projeto:** Acelerador AES com interface SPI e baixo consumo

**Status:** Concluida; compilacao, lint e simulacao aprovados com VCS

## Entrega

- `rtl/minisoc_aes/minisoc_aes_sbox.sv`: S-box combinacional com tabela completa de 256 bytes.
- `rtl/minisoc_aes/minisoc_aes_sub_bytes.sv`: 16 instancias da S-box, preservando a ordem dos bytes.
- `rtl/minisoc_aes/minisoc_aes_shift_rows.sv`: reordenacao combinacional dos bytes conforme ShiftRows.
- `tb/tb_week2.sv` e `tb/aes_sbox_ref.hex`: testbench autoverificavel para todas as entradas da S-box e para SubBytes/ShiftRows nas rodadas 1 e 10 do Apêndice B da FIPS-197.
- `scripts/check_week2.sh`: comando unico de compilacao com lint e simulacao usando VCS.

## Convenção do estado

O byte 0 ocupa `state[127:120]` e o byte 15 ocupa `state[7:0]`. O byte `n`
corresponde a `s[r][c]`, com `r = n mod 4` e `c = n div 4`. ShiftRows
implementa `out[r,c] = in[r,(c+r) mod 4]`.

## Verificação

Execute na raiz do repositório:

```sh
./scripts/check_week2.sh
```

Executado com `source /Tools/synopsys-scripts/snps.sh` seguido de
`./scripts/check_week2.sh`. Resultado: compilação e lint aprovados, PASS para
as 256 entradas da S-box e PASS para SubBytes/ShiftRows nas rodadas 1 e 10 do
Apêndice B. O script também carrega `snps.sh` automaticamente se `vcs` ainda
não estiver no `PATH`.

## Revisão com o Block Guide v1.0.0

- As seções 1 e 8 especificam um datapath AES com bloco e chave de 128 bits; isso
  é compatível com os módulos SubBytes/ShiftRows de 128 bits desta entrega.
- A seção 7.1 confirma a ordem das quatro palavras do bloco na memória:
  Word 0 em `[127:96]` até Word 3 em `[31:0]`, compatível com a concatenação
  MSB-first adotada pelo testbench.
- A seção 10 organiza o RTL AES sob `rtl/minisoc_aes/`; os módulos desta entrega
  foram colocados nessa pasta para seguir a estrutura do guia.
- O guia não fixa a assinatura das portas nem a ordem dos bytes dentro do
  estado para estes módulos auxiliares. Continuam valendo, portanto, os nomes,
  portas e a convenção do estado definidos no roteiro da Semana 2. Confirmar
  esses detalhes com o instrutor antes da integração ao datapath.

## Próximos passos

1. Confirmar com o instrutor a assinatura e a convenção do estado para os módulos
   auxiliares, se o datapath precisar de uma interface diferente.
2. Na Semana 3, seguir a arquitetura indicada pelo guia ao implementar as demais
   transformações AES e a microarquitetura.
