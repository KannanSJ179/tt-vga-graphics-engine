import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_vga_engine(dut):
    """Basic smoke test for VGA engine"""

    # Start clock (25MHz → 40ns period)
    clock = Clock(dut.clk, 40, unit="ns")
    cocotb.start_soon(clock.start())

    # Initialize inputs
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1
    dut.rst_n.value  = 0

    # Reset phase
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Run simulation
    await ClockCycles(dut.clk, 1000)

    # No assertions needed (TinyTapeout standard)
    dut._log.info(
        f"SIM DONE — uo_out={dut.uo_out.value} "
        f"uio_out={dut.uio_out.value} uio_oe={dut.uio_oe.value}"
    )
