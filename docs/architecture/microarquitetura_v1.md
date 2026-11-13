# Microarquitetura AES v1.0 — proposta para revisão

**Status:** proposta para discussão com o instrutor e o verificador parceiro.

**Escopo:** a organização do sistema continua sendo uma proposta; o
`minisoc_aes_dp` e a expansão de chave foram implementados na Semana 4,
conforme a seção de implementação abaixo. O `minisoc_aes_top` ainda não existe.

## Diagrama de blocos

```text
spi_sclk                         clk (always-on)                  sys_clk
┌────────────────────┐          ┌──────────────────────┐        ┌──────────────────────┐
│ SPI shift/frame RX │─ frame ─>│ toggle synchronizer  │─ cfg ─>│ AES controller/FSM   │
└────────────────────┘          │ config/status regs   │        │ block/mode sequencer │
                                └──────────────────────┘        └──────────┬───────────┘
                                                                           │ start/round
                                                               ┌───────────▼───────────┐
                                                               │ AES-128 iterative DP  │
                                                               │ state + round-key regs│
                                                               └───────────────────────┘
                                                                           │
                                                               shared memory interface
```

`spi_sclk`, `clk`, `sys_clk` e `mem_clk` são domínios distintos, conforme o
Block Guide. O acesso à memória compartilhada será exclusivo: SPI/host ou AES,
nunca ambos simultaneamente.

## Microarquitetura do AES

Escolha proposta: datapath iterativo com um registrador de estado de 128 bits
e uma rodada AES por ciclo de `sys_clk`. As transformações combinacionais desta
entrega são reutilizadas pelo datapath; a expansão de chave e os registradores
de controle foram implementados na Semana 4.

Para cifragem, aplicar `AddRoundKey(K0)` antes das rodadas 1–10. As rodadas 1–9
fazem SubBytes, ShiftRows, MixColumns e AddRoundKey. A rodada 10 omite
MixColumns.

Para decifragem, iniciar com `AddRoundKey(K10)`. As rodadas 9–1 fazem
InvShiftRows, InvSubBytes, AddRoundKey e InvMixColumns. A rodada final faz
InvShiftRows, InvSubBytes e AddRoundKey(K0), sem InvMixColumns.

As 11 round keys AES-128 ficam disponíveis em registradores no módulo de
expansão, instanciado pelo datapath; cifra percorre K0→K10 e decifra K10→K0. Essa escolha simplifica o
controle da ordem inversa e evita regenerar chaves durante a operação, ao custo
de guardar 1408 bits de round keys, além dos registradores auxiliares. Essa
capacidade é lógica; área física e timing ainda dependem de síntese.

## Implementação da Semana 4

### Expansão da chave

`minisoc_aes_key_exp` recebe a chave original e guarda K0 no ciclo que aceita
`start`. Calcula K1 a K10 nos dez ciclos seguintes, uma chave por ciclo.
Usa quatro instâncias da S-box existente para calcular
`SubWord(RotWord(ultimo_word))`, aplica Rcon ao byte superior e encadeia XORs
com as quatro palavras da chave anterior.

```text
chave capturada -> RotWord + 4 S-boxes + Rcon + XORs -> proxima chave
                       ^                                  |
                       +------- registrador anterior -----+

                 banco K0..K10 -> selecao round_index -> round_key
```

Os sinais são `clk`, `rst_n` (reset assíncrono ativo baixo), `start`,
`key[127:0]`, `round_index[3:0]`, `round_key[127:0]`, `busy` e `done`.
A interface exige `round_index` entre 0 e 10. Consumir as chaves somente após
`done` e antes de iniciar outra expansão; uma nova chave invalida o banco
anterior até a nova conclusão. `done` dura um ciclo; `start` com `busy=1`
é ignorado. O banco permanece armazenado até outra expansão ou reset.

### Datapath de um bloco

```text
block_in/key/decrypt -- START aceito --> registradores de entrada
                                              |
                         key_reg --> key_exp --> K[round_index]
                                              |
        +--------------------- state_reg <-----------------------+
        |                                                       |
        +-> SubBytes -> ShiftRows -> MixColumns/bypass --+       |
        |                                               |       |
        +-> InvShiftRows -> InvSubBytes -----------------+       |
        |                                               v       |
        +--------- bypass da chave inicial ----------> MUX      |
                                                        |       |
                                                  AddRoundKey   |
                                                        |       |
                                              InvMixColumns/    |
                                                   bypass       |
                                                        |       |
                                                        +-------+
                                                        |
                                             rodada final: block_out
```

O MUX seleciona a entrada de AddRoundKey de acordo com direção, fase inicial
e última rodada. Na cifra, a rodada final desvia MixColumns; na decifra,
desvia InvMixColumns. Só o caminho inverso usa InvMixColumns após o XOR.
O bloco de AddRoundKey é compartilhado pelas duas direções.

FSM interna do datapath (distinta da futura FSM do engine):

```text
IDLE -- start --> KEY_START --> KEY_WAIT -- keys_done --> INITIAL_KEY
  ^                                                           |
  |                                                           v
  +---------------- ultima rodada -------------------------- ROUND
                                                               |
                                             mais rodadas -----+
```

| Sinal | Contrato |
| --- | --- |
| `clk` | Clock do datapath; será conectado a `sys_clk` na integração |
| `rst_n` | Reset assíncrono ativo baixo; aborta a operação e zera a saída |
| `start` | Pulso de um ciclo, aceito na borda de subida apenas em IDLE |
| `decrypt` | 0 = cifra; 1 = decifra |
| `key[127:0]` | Chave AES-128, capturada ao aceitar START |
| `block_in[127:0]` | Bloco de entrada, capturado ao aceitar START |
| `busy` | 1 desde a aceitação até a conclusão |
| `done` | Pulso de um ciclo indicando saída válida; não é status sticky |
| `block_out[127:0]` | Atualizado na conclusão, mantido até outra conclusão ou reset |

`key`, `block_in` e `decrypt` podem mudar depois da captura. Comandos START
enquanto ocupado são ignorados, sem fila. O chamador deve retirar START depois
de um ciclo; se mantiver em 1 até IDLE, será aceita outra operação.

São 23 períodos de clock entre a borda que aceita START e a borda que conclui,
em ambas as direções: lançamento da expansão, dez ciclos de expansão,
observação de `keys_done`, XOR inicial e dez rodadas. Não há cache de chave:
cada bloco recalcula as chaves, simplificando o contrato para trocas de chave.
Reutilizar o banco entre blocos é uma otimização futura, não parte desta versão.

Uma rodada por ciclo é a organização funcional, não uma garantia de frequência:
não houve síntese, análise de timing nem comprovação de operação a 2 GHz.
Reset sincronizado com o domínio e condições do PLL continuam responsabilidade
da integração futura, conforme a seção de reset abaixo.

## FSM proposta para `minisoc_aes_top`

1. `IDLE`: aguarda START.
2. `VALIDATE`: captura a configuração e valida modo e número de blocos.
3. `READ_BLOCK`: solicita e captura as quatro palavras do bloco.
4. `START_DP`: inicia o datapath com estado, chave e direção.
5. `WAIT_DP`: aguarda `dp_done`.
6. `WRITE_BLOCK`: escreve o resultado nas mesmas quatro posições.
7. `NEXT_BLOCK`: atualiza chaining/contador conforme o modo e avança o índice.
8. `DONE`: sinaliza conclusão; retorna a `IDLE` após novo comando aceito.
9. `ERROR`: sinaliza configuração inválida sem iniciar processamento.

Os detalhes de latência da memória, sinais e transições serão fechados na
integração da Semana 6, respeitando a interface externa definida pelo guia.

## CDC de evento SPI

O receptor monta e mantém estável o frame completo no domínio `spi_sclk` e
alterna um bit `frame_toggle` ao completar o frame. No domínio `clk`, dois
flip-flops sincronizam o toggle; a diferença em relação ao valor já observado
indica um novo evento. O domínio `clk` captura o barramento do frame depois da
sincronização e confirma a captura por um toggle de acknowledge. O receptor
mantém os dados estáveis até o acknowledge, evitando depender da largura de um
pulso ou sincronizar cada bit do barramento separadamente.

O protocolo de acknowledge e a política para frames recebidos enquanto houver
um frame pendente deverão ser revisados com o instrutor antes da implementação
do SPI na Semana 5.

## Reset e liberação do clock AES

`rst_n` reseta os blocos de controle always-on. O domínio AES permanece em reset
enquanto o PLL mock não indicar `locked`. Após o lock, a liberação do reset do
domínio `sys_clk` é sincronizada nesse clock (assert assíncrono e deassert
síncrono por cadeia de dois flip-flops), seguida de dois ciclos de inicialização
antes de aceitar START. Se o PLL perder lock, o domínio AES volta ao reset e o
controle deve reportar erro ou reinicialização conforme decisão de integração.

## Questões para aprovação

- Aprovar o datapath iterativo de uma rodada por ciclo e o armazenamento das
  11 round keys.
- Confirmar protocolo de acknowledge para o frame SPI e tratamento de eventos
  enquanto houver captura pendente.
- Confirmar o comportamento de status/erro após perda de PLL lock durante
  processamento.
- Confirmar tempos de leitura/escrita da memória single-port na Semana 6.
