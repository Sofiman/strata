module toplevel (
    input rst,
    input clk,

    input key,

    input uart_rx,
    output uart_tx,

    output [5:0] leds
);

    localparam CAPTURE_WIDTH = 128;
    localparam CAPTURE_SAMPLES = 512;

    wire [CAPTURE_WIDTH-1:0] snoop_data;
    wire [5:0] leds_n;
    assign leds = ~leds_n;

    rv32i cpu (
        .rst(rst),
        .clk(clk),

        .leds(leds_n),
        .snoop_data(snoop_data)
    );

    uartscope #(
        .INPUT_CLK_FREQ(27_000_000),

        .CAPTURE_WIDTH(CAPTURE_WIDTH),
        .CAPTURE_SAMPLES(CAPTURE_SAMPLES)
    ) scope (
        .clk(clk),
        .n_rst(!rst),

        .i_uart_rx(uart_rx),
        .o_uart_tx(uart_tx),

        .i_capture_data(snoop_data)
    );

endmodule
