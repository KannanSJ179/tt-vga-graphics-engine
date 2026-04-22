# Multi-Mode Procedural VGA Graphics Engine

## Demo

![VGA Output](output.gif)

---

## Concept

This project implements a real-time procedural graphics engine entirely in hardware.

Instead of using framebuffers or memory, every pixel is computed mathematically
from its coordinates and time. This enables complex animated visuals using only
arithmetic and bitwise logic, making the design highly efficient and suitable
for ASIC implementation.

---

## Features

- Four distinct procedural rendering modes
- Automatic mode switching driven by a frame counter
- Real-time animation without memory or lookup tables
- Radial distance approximation using octagonal norm (no sqrt/division)
- Full 640×480 VGA output (RGB222)
- Fully synthesizable Verilog (TinyTapeout compatible)

---

## How It Works

Each pixel is generated on-the-fly using a combinational pipeline:
hpos, vpos
↓
Centered coordinates (cx, cy)
↓
Absolute values (ax, ay)
↓
Scaled coordinates
↓
Radial approximation (r = max + min/2)
↓
Mode-based pattern generation
↓
Color mapping (RGB222)

A frame counter updates once per screen refresh and drives:
- Animation
- Automatic mode switching

---

## Rendering Modes

| Mode | Name              | Description                          |
|------|------------------|--------------------------------------|
| 0    | Radial Energy    | Expanding concentric rings with twist |
| 1    | Plasma           | Smooth diagonal color gradients       |
| 2    | Interference     | Cross-wave grid patterns              |
| 3    | Chaos            | Nonlinear dynamic bitwise textures    |

Each mode runs for ~256 frames before switching automatically.

---

## TinyTapeout Compatibility

- Fully synthesizable (no delays, no `initial`)
- No memory usage (pure combinational rendering)
- Optimized arithmetic operations
- Meets TinyTapeout constraints

---

## Simulation

Run locally:

cd test
make sim
Expected output:
PASS: hsync toggled
PASS: vsync toggled
PASS: uio_oe is zero

Pin Mapping
Signal	uo_out
R[1]	0
G[1]	1
B[1]	2
VSYNC	3
R[0]	4
G[0]	5
B[0]	6
HSYNC	7

Repository Structure
src/    → Verilog design
test/   → Testbench and simulation
docs/   → Architecture and design docs

ASIC Status
This design has successfully passed the TinyTapeout flow, including synthesis,
placement, routing, and GDS generation.

Author
Kannan S J

License
MIT
