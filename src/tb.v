`default_nettype none
`timescale 1ns/1ps

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module  tb (
    // testbench is controlled by test.py
    input        clk,
    input        rst,
    input        rate_ctrl,
    input        brightness_ctrl,
    output [7:0] leds
   );

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        #1;
    end

    // wire up the inputs and outputs
    wire [7:0] inputs = {4'b0, brightness_ctrl, rate_ctrl, rst, clk};
    wire [7:0] outputs;

    assign leds = outputs;

    // instantiate the DUT
    knight_rider_KolosKoblasz # (
        .OUT_WIDTH(8)
    )
    knight_rider_KolosKoblasz_inst_0
    (
        .io_in  (inputs),
        .io_out (outputs)
    );

endmodule
