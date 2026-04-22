# Multi-Mode Procedural VGA Graphics Engine

A TinyTapeout submission that generates real-time procedural visuals over VGA
(640x480) using pure combinational and sequential logic — no memory, no ROM,
no lookup tables.

## Features

- Four distinct procedural rendering modes
- Automatic mode switching driven by a frame counter
- Radial distance approximation via octagonal norm (no division, no square root)
- Centered coordinate system with signed arithmetic
- Full 640x480 VGA output at 2 bits per color channel (RGB222)
- Synthesizable Verilog, TinyTapeout-compatible
- Zero external memory requirements

## How It Works

The design operates as a purely combinational rendering pipeline. On every
pixel clock tick, the current pixel position (hpos, vpos) is transformed into
centered coordinates and fed through one of four pattern generators. The
selected generator produces an 8-bit pattern value that is mapped directly to
RGB output bits.

A 10-bit frame counter increments once per frame (at hpos=0, vpos=0). The
upper two bits of this counter select the active rendering mode, causing the
display to cycle through all four modes automatically.

### Rendering Pipeline

```
hpos, vpos
    │
    ▼
Centered coordinates (cx, cy)
    │
    ▼
Absolute values (ax, ay)
    │
    ▼
Scaled inputs (ax_s, ay_s = ax>>2, ay>>2)
    │
    ▼
Octagonal radial approximation: r = max + min/2
    │
    ├──── Mode 0: Radial Energy Field
    ├──── Mode 1: Plasma
    ├──── Mode 2: Interference
    └──── Mode 3: Chaos
              │
              ▼
        pattern[7:0]
              │
              ▼
    color = pattern + t
              │
              ▼
    R[1:0] G[1:0] B[1:0] → VGA output
```

## Rendering Modes

| Mode | Bits [9:8] | Name              | Character                          |
|------|------------|-------------------|------------------------------------|
| 0    | 00         | Radial Energy     | Concentric rings with vortex twist |
| 1    | 01         | Plasma            | Diagonal color waves               |
| 2    | 10         | Interference      | Crossed wave grid                  |
| 3    | 11         | Chaos             | Nonlinear bitwise turbulence       |

Each mode lasts 256 frames before the counter rolls over to the next.

## Running Simulation

```bash
cd test
make sim
```

Requires Icarus Verilog (`iverilog`) and optionally GTKWave for waveform viewing.

```bash
# View waveform
make wave
```

## Using on TinyTapeout

1. Fork this repository.
2. Ensure `info.yaml` has your correct author details.
3. Push to GitHub. The TinyTapeout CI workflow will synthesize the design.
4. Connect VGA output according to the TinyTapeout VGA PMOD pinout.
5. Power on. No configuration is required; the design begins running immediately.

### Pin Mapping

| Signal  | uo_out bit |
|---------|-----------|
| R[1]    | 0         |
| G[1]    | 1         |
| B[1]    | 2         |
| vsync   | 3         |
| R[0]    | 4         |
| G[0]    | 5         |
| B[0]    | 6         |
| hsync   | 7         |

## Repository Structure

```
.
├── src/
│   ├── project.v            Top-level VGA rendering module
│   └── hvsync_generator.v   VGA sync signal generator
├── test/
│   ├── testbench.v          Simulation testbench
│   └── Makefile             Simulation build rules
├── docs/
│   ├── architecture.md      Pipeline and data-flow documentation
│   ├── design.md            Mathematical basis for each mode
│   └── visuals.md           Visual description of each rendering mode
├── README.md
└── info.yaml
```

## License

MIT
