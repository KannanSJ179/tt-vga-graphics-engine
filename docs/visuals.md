# Visual Description

## Display Behavior

At power-on, the design begins in Mode 0. Modes advance automatically every
256 frames. At 60 fps, each mode is active for approximately 4.3 seconds
before transitioning to the next. The cycle repeats indefinitely.

---

## Mode 0: Radial Energy Field

### Appearance

A series of concentric rings centered on the screen midpoint (320, 240).
The rings are colored using the 8-bit pattern sliced into R, G, B channels,
producing a rainbow-banded effect. A slow vortex-like angular distortion is
visible, causing the rings to appear slightly twisted rather than perfectly
circular. The rings drift outward continuously as frames advance.

### Computation Summary

The primary field is `(r << 2) + (t << 1)`, which maps radial distance to
ring phase and adds a linear time drift. A secondary low-frequency ripple
field modulates the boundary sharpness at 1/4 amplitude via XOR.

---

## Mode 1: Plasma

### Appearance

A full-screen diagonal color gradient that travels across the display. The
colors cycle smoothly through all RGB combinations at a rate determined by
the frame counter. There are no sharp boundaries; the transition is continuous
and wave-like. The diagonal orientation shifts slowly over time.

### Computation Summary

The pattern is a sum of linearly scaled horizontal and vertical coordinates
with two time terms at different rates. The asymmetry between the time rates
causes the gradient direction to rotate slowly.

---

## Mode 2: Interference

### Appearance

A grid of rectangular cells produced by the XOR of coarsely scaled X and Y
coordinates. The cells are overlaid with a slowly drifting diagonal band,
giving the impression of two wave systems interfering. Color cycling from the
global time offset adds hue variation across the grid.

### Computation Summary

`cx[9:3] XOR cy[9:3]` produces a regular 8-pixel-wide cell grid.
`cx[9:4] + cy[9:4]` is a lower-spatial-frequency additive term that creates
the diagonal band modulation.

---

## Mode 3: Chaos

### Appearance

A rapidly varying bitwise texture with localized darker regions. Unlike pure
random noise, the pattern has visible diagonal streaks and a rough large-scale
structure produced by the AND envelope. The temporal evolution is fast relative
to other modes, so individual features change significantly from frame to frame.
Color cycling is still visible because the global `+ t` offset applies uniformly.

### Computation Summary

`cx XOR (cy + t)` produces the primary turbulent field. `(cx AND cy) >> 2`
introduces a spatially correlated envelope that suppresses intensity in regions
where both coordinates share bit patterns, creating non-uniform density.
