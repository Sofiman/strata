`timescale 1 ns / 10 ps
`define BENCH

module rv32i_tb();

    localparam DURATION = 10_000;

    reg rst = 0, clk = 0;
    wire [5:0] leds;

    always begin
        #18.518
        clk = ~clk;
    end

    rv32i uut (
        .rst(rst),
        .clk(clk),
        .leds(leds)
    );

    initial begin
        #10
        rst = 1'b1;
        #1
        rst = 1'b0;
    end

    initial begin
        $dumpfile("rv32i_tb.vcd");
        $dumpvars(/* infinite depth */ 0, rv32i_tb);
        #(DURATION)
        $finish;
    end


endmodule
