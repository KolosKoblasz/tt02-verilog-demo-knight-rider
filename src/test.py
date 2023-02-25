import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from random import randrange

#rate_ctrl = [ 63, 6, 91, 79, 102, 109, 124, 7, 127, 103 ]

@cocotb.test()
async def test_knight_rider(dut):
    dut._log.info("start simulation")
    clock = Clock(dut.clk, 167, units="us")
    cocotb.start_soon(clock.start())

    dut._log.info("reset")
    dut.rst.value = 1
    dut.rate_ctrl.value = 0
    dut.brightness_ctrl.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst.value = 0
    dut._log.info("reset deasserted")

    for brightness in range(5):
        for speed in range(10):
            await ClockCycles(dut.clk, 7000*6)
            #change_rate(dut, i)
            dut._log.info("Change rate no.: {}".format(speed))
            dut.rate_ctrl.value = 1
            await ClockCycles(dut.clk, randrange(1,10))
            dut.rate_ctrl.value = 0
            await ClockCycles(dut.clk, 3)

        dut._log.info("Change brightness no.: {}".format(brightness))
        dut.brightness_ctrl.value = 1
        await ClockCycles(dut.clk, randrange(1,10))
        dut.brightness_ctrl.value = 0
        await ClockCycles(dut.clk, 3)

#        assert int(dut.segments.value) == segments[i]

async def change_rate (dut, change_id) :
    dut._log.info("Change rate {}".format(change_id))
    dut.rate_ctrl.value = 1
    await Timer(randrange(167,167*9), units="us")
    dut.rate_ctrl.value = 0
    await ClockCycles(dut.clk, 3)