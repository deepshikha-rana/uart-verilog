# UART (TX/RX) in Verilog

A parameterized 8N1 UART transmitter and receiver written in Verilog, with a self-checking loopback testbench. Verified using Icarus Verilog on [EDA Playground](https://edaplayground.com).

## Overview

UART (Universal Asynchronous Receiver-Transmitter) sends data one bit at a time over a single wire, framed as:

```
[ start bit (0) ] [ 8 data bits, LSB first ] [ stop bit (1) ]
```

This project implements:

- `uart_tx.v` — serializes an 8-bit byte onto a `tx` line
- `uart_rx.v` — deserializes a `rx` line back into an 8-bit byte
- `uart_top.v` — wraps both into a single module with one clean interface
- `tb_uart_top.v` — self-checking testbench that loops `tx` directly into `rx` and verifies multiple bytes round-trip correctly

## Folder structure

```
uart-verilog/
├── src/
│   ├── uart_tx.v      # transmitter module
│   ├── uart_rx.v      # receiver module
│   └── uart_top.v     # top-level wrapper (instantiates tx + rx)
└── tb/
    └── tb_uart_top.v  # loopback testbench
```

## Module interfaces

### `uart_tx`

| Port | Direction | Width | Description |
|---|---|---|---|
| `clk` | input | 1 | System clock |
| `rst_n` | input | 1 | Active-low reset |
| `tx_start` | input | 1 | Pulse high for 1 clock to begin transmission |
| `tx_data` | input | 8 | Byte to transmit |
| `tx` | output | 1 | Serial output line |
| `tx_busy` | output | 1 | High while a transmission is in progress |

### `uart_rx`

| Port | Direction | Width | Description |
|---|---|---|---|
| `clk` | input | 1 | System clock |
| `rst_n` | input | 1 | Active-low reset |
| `rx` | input | 1 | Serial input line |
| `rx_data` | output | 8 | Last received byte |
| `rx_done` | output | 1 | Pulses high for 1 clock when a byte has been received |

### `uart_top`

Combines both above into one module with the union of their ports (`tx_start`, `tx_data`, `tx`, `tx_busy`, `rx`, `rx_data`, `rx_done`).

### Parameters (both modules)

| Parameter | Default | Description |
|---|---|---|
| `CLK_FREQ` | 50,000,000 | System clock frequency in Hz |
| `BAUD_RATE` | 9600 | Serial baud rate |

## Verification approach

1. **Loopback integration test** (`tb_uart_top.v`): connects `tx` directly to `rx` and sends several test bytes (`0xA5`, `0x3C`, `0x00`, `0xFF`, `0x55`), checking that each byte received matches what was sent.
2. Waveforms are dumped to `dump.vcd` for visual inspection in EPWave.

## How to run

1. Go to [EDA Playground](https://edaplayground.com)
2. Paste `uart_tx.v`, `uart_rx.v`, and `uart_top.v` into the design files box
3. Paste `tb_uart_top.v` into the testbench box
4. Select **Icarus Verilog** as the simulator
5. Check **"Open EPWave after run"** if you want to see waveforms
6. Click **Run**

Expected output:

```
PASS: sent 0xa5, received 0xa5
PASS: sent 0x3c, received 0x3c
PASS: sent 0x00, received 0x00
PASS: sent 0xff, received 0xff
PASS: sent 0x55, received 0x55
ALL TESTS PASSED
```
