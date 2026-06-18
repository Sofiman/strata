module uart #(
    parameter INPUT_CLK_FREQ = 0,
    parameter BAUD_RATE = 115200,

    parameter DATA_BITS = 8, // 5 to 9 bits
    parameter PARITY = 0, // TODO
    parameter STOP_BITS = 1 // 1 or 2
) (
    input n_rst,
    input clk,

    input rx,
    output rx_err,
    output rx_ready,
    output [DATA_BITS-1:0] rx_data,

    input tx_ready,
    input [DATA_BITS-1:0] tx_data,
    output tx_busy,
    output tx
);

    uart_rx #(
        .INPUT_CLK_FREQ(INPUT_CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .STOP_BITS(STOP_BITS)
    ) uart_rx (
        .n_rst(n_rst),
        .clk(clk),
        .rx(rx),
        .rx_err(rx_err),
        .rx_ready(rx_ready),
        .rx_data(rx_data)
    );

    uart_tx #(
        .INPUT_CLK_FREQ(INPUT_CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .STOP_BITS(STOP_BITS)
    ) uart_tx (
        .n_rst(n_rst),
        .clk(clk),
        .tx_ready(tx_ready),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx(tx)
    );

endmodule
