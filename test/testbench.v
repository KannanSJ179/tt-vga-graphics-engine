`timescale 1ns/1ps

module testbench;

    reg clk;
    reg rst_n;

    wire [7:0] uo_out;

    // Dummy signals
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    tt_um_vga_example uut (
        .ui_in(8'b0),
        .uo_out(uo_out),
        .uio_in(8'b0),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(1'b1),
        .clk(clk),
        .rst_n(rst_n)
    );


    always #20 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;


        #100;
        rst_n = 1;


        #100000;

        $finish;
    end

endmodule
