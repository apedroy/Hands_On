# Relatório de estudo — AES e SPI (Semana 1)

**Projeto:** Acelerador AES com interface SPI e baixo consumo
**Autor:** aluno da trilha RTL Design
**Data:** 2026-10-08
**Objetivo:** consolidar o estudo do algoritmo AES (FIPS-197) e do protocolo SPI que
fundamentam a arquitetura e o RTL das próximas semanas.

---

## 1. AES — Advanced Encryption Standard (FIPS-197)

### 1.1 Visão geral

O AES é uma **cifra simétrica de blocos** padronizada pelo NIST (FIPS-197), derivada
do algoritmo Rijndael. "Simétrica" significa que a mesma chave é usada para cifrar e
decifrar. Opera sempre sobre blocos de **128 bits** (16 bytes).

| Parâmetro | Valor |
| --- | --- |
| Tamanho do bloco | 128 bits (Nb = 4 palavras de 32 bits) |
| Tamanhos de chave | 128 / 192 / 256 bits (Nk = 4 / 6 / 8 palavras) |
| Número de rodadas (Nr) | 10 / 12 / 14 |

### 1.2 O estado (state)

O bloco de 128 bits é organizado como uma **matriz 4×4 de bytes** chamada *state*.
Os bytes são preenchidos por coluna (*column-major*): o primeiro byte vai para a
posição (linha 0, coluna 0), o segundo para (linha 1, coluna 0), e assim por diante.
Todas as transformações de rodada operam sobre essa matriz.

### 1.3 Aritmética em GF(2⁸)

As operações do AES são definidas no **corpo finito GF(2⁸)**. Cada byte é tratado como
um polinômio de grau ≤ 7. A multiplicação é feita módulo o polinômio irredutível
`x⁸ + x⁴ + x³ + x + 1` (0x11B). Isso é o que torna SubBytes e MixColumns não triviais —
é importante dominar isso para implementar o datapath nas Semanas 3–4.

### 1.4 Transformações de rodada

1. **SubBytes** — substituição **não linear** byte a byte usando a *S-box*. A S-box é
   a composição do inverso multiplicativo em GF(2⁸) com uma transformação afim. É a
   principal fonte de confusão (no sentido de Shannon) da cifra. Em hardware,
   costuma ser implementada como tabela (ROM/LUT) ou como lógica combinacional.
2. **ShiftRows** — permutação: a linha *i* da matriz é rotacionada para a esquerda em
   *i* bytes (linha 0 não se move, linha 1 roda 1, linha 2 roda 2, linha 3 roda 3).
   Promove difusão entre colunas. É apenas reconexão de fios em hardware (custo ~0).
3. **MixColumns** — cada coluna é multiplicada por um polinômio fixo em GF(2⁸),
   equivalente à matriz de constantes:
   ```
   | 02 03 01 01 |
   | 01 02 03 01 |
   | 01 01 02 03 |
   | 03 01 01 02 |
   ```
   Promove difusão **dentro** de cada coluna. **Omitida na rodada final.**
4. **AddRoundKey** — XOR bit a bit entre o *state* e a chave da rodada. É a única
   etapa que depende da chave. (Observação: o XOR do nosso smoke-test da Semana 1 é
   exatamente a operação base desta etapa.)

### 1.5 Estrutura da cifragem

```
AddRoundKey (chave inicial)
repetir (Nr − 1) vezes:
    SubBytes → ShiftRows → MixColumns → AddRoundKey
rodada final:
    SubBytes → ShiftRows → AddRoundKey        (sem MixColumns)
```

### 1.6 Expansão de chave (Key Expansion)

A chave original é expandida em `Nb × (Nr + 1)` palavras de 32 bits, uma chave por
rodada. O algoritmo usa três operações auxiliares:
- **RotWord** — rotação cíclica de bytes dentro da palavra;
- **SubWord** — aplicação da S-box a cada byte da palavra;
- **Rcon** — constante de rodada, somada (XOR) para quebrar simetrias.

Será implementada na Semana 4.

### 1.7 Decifragem

Usa as transformações inversas (InvSubBytes, InvShiftRows, InvMixColumns) e as chaves
de rodada em ordem reversa. O escopo deste IP será definido pela especificação
funcional (pode ser apenas cifragem, ou cifragem + decifragem).

### 1.8 Implicações para a microarquitetura (Semanas 3–6)

- **Iterativa por rodada** (uma rodada por ciclo, reutilizando o hardware): menor área,
  maior latência — candidata natural para um acelerador de baixo consumo.
- Alternativas: *loop unrolling* (desenrolar rodadas) ou *pipeline* (maior vazão, maior
  área). A escolha será justificada no documento de arquitetura da Semana 2.
- Pontos de atenção de RTL: implementação da S-box (LUT vs lógica), multiplicação em
  GF(2⁸) do MixColumns, armazenamento das chaves de rodada.

---

## 2. SPI — Serial Peripheral Interface

### 2.1 Visão geral

O SPI é uma interface serial **síncrona**, **full-duplex**, do tipo **mestre/escravo**.
No sistema, o SPI é usado para **configurar e controlar** o chip (escrita/leitura de
registradores de configuração, controle e status, incluindo os bits de configuração do
PLL). Neste projeto o nosso bloco atua como **escravo**.

### 2.2 Sinais

| Sinal | Direção | Função |
| --- | --- | --- |
| **SCLK** | mestre → escravo | clock serial, gerado pelo mestre |
| **CS_N** (SS) | mestre → escravo | *chip select* ativo-baixo; delimita a transação |
| **MOSI** | mestre → escravo | dados do mestre para o escravo |
| **MISO** | escravo → mestre | dados do escravo para o mestre |

A cada pulso de SCLK, um bit sai e um bit entra simultaneamente (full-duplex). O
enquadramento (*framing*) é feito pelo CS_N — não há endereçamento nem confirmação
(*ACK*) no protocolo base.

### 2.3 Modos (CPOL / CPHA)

Dois parâmetros definem o comportamento do clock:
- **CPOL** (*clock polarity*) — nível de repouso do SCLK (0 = repouso em baixo, 1 = em alto);
- **CPHA** (*clock phase*) — em qual borda o dado é amostrado (primeira ou segunda borda).

As combinações geram os **4 modos**:

| Modo | CPOL | CPHA | Amostragem |
| --- | --- | --- | --- |
| 0 | 0 | 0 | borda de subida |
| 1 | 0 | 1 | borda de descida |
| 2 | 1 | 0 | borda de descida |
| 3 | 1 | 1 | borda de subida |

Normalmente a transmissão é **MSB-first**. **O modo exato e o enquadramento adotados
serão definidos pela especificação funcional** (pendência registrada no backlog).

### 2.4 Operação típica no projeto

1. Mestre baixa CS_N (inicia a transação).
2. Envia pela MOSI um cabeçalho (ex.: bit de leitura/escrita + endereço do registrador)
   seguido do dado — formato exato conforme a especificação.
3. O escravo desloca os bits para dentro de um *shift register* no ritmo do SCLK e
   devolve, pela MISO, o conteúdo lido.
4. Mestre sobe CS_N (encerra a transação).

Será implementado na Semana 5 (RTL do SPI + banco de registradores).

---

## 3. Integração e domínios de clock (CDC) — principal risco técnico

A arquitetura do sistema de topo tem **dois domínios de clock**:
- **Domínio do SCLK:** o SPI opera nativamente no clock serial — *shift register*,
  contador de bits e saída MISO ficam nesse domínio.
- **Domínio do sistema:** o banco de registradores, o núcleo AES e a interface de
  memória operam no clock gerado pelo **PLL**.

Consequências que precisam ser tratadas na arquitetura (Semana 2) e na integração
(Semana 6, análise de CDC):
- Sinais de controle de 1 bit que cruzam domínios precisam de **sincronizadores**
  (ex.: dois flip-flops) para evitar metaestabilidade.
- **Barramentos multibit** não podem ser sincronizados bit a bit — exigem um
  **protocolo de transferência coerente** (handshake ou FIFO), senão ocorrem
  capturas inconsistentes de bits de diferentes ciclos.
- O **PLL** sai do reset com uma configuração padrão e trava sozinho (sinal `locked`);
  seus registradores só são reprogramados pelo SPI **depois** do `locked`.
- A estratégia de **reset** de cada domínio precisa ser definida.

Esse é o ponto de maior atenção do projeto e deve ser desenhado explicitamente antes
de escrever o RTL do SPI.

---

## 4. Conclusões do estudo

- O AES é bem estruturado para implementação em hardware; a microarquitetura
  (iterativa vs pipeline) é a principal decisão de arquitetura e impacta diretamente
  área, timing e potência — foco do projeto.
- O SPI é simples no fluxo de bits, mas a sua integração ao sistema introduz o
  problema de **CDC**, que é o maior risco técnico e precisa de solução arquitetural.
- As definições em aberto (tamanho de chave suportado, escopo cifragem/decifragem,
  modo SPI e formato de enquadramento, mapa de registradores) dependem da
  **especificação funcional** do instrutor e estão registradas no backlog.

---

## 5. Referências

- NIST, *FIPS 197: Advanced Encryption Standard (AES)* —
  https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.197.pdf
- Analog Devices, *Introduction to SPI Interface* —
  https://www.analog.com/en/resources/analog-dialogue/articles/introduction-to-spi-interface.html
