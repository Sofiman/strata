module uartscope #(
    /* UART settings */
    parameter INPUT_CLK_FREQ  = 0,
    parameter BAUD_RATE       = 115200,

    /* Capture settings */
    parameter CAPTURE_WIDTH   = 128,
    parameter CAPTURE_SAMPLES = 512
) (
    input clk,
    input n_rst,

    input  i_uart_rx,
    output o_uart_tx,

    input [CAPTURE_WIDTH-1:0] i_capture_data
);

    wire       rx_ready;
    wire [7:0] rx_data;
    reg        tx_ready;
    wire       tx_busy;
    reg [7:0]  tx_data;

    uart #(
        .INPUT_CLK_FREQ(INPUT_CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uart (
        .n_rst(n_rst),
        .clk(clk),

        /* RX */
        .rx(i_uart_rx),
        .rx_err(/* rx_err */),
        .rx_ready(rx_ready),
        .rx_data(rx_data),

        /* TX */
        .tx_ready(tx_ready),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx(o_uart_tx)
    );

    reg                      capture_trigger__manual;
    wire                     capture_finished;
    reg                      read_en;
    wire                     read_finished;
    wire [CAPTURE_WIDTH-1:0] read_data;

    wire capture_trigger = capture_trigger__manual;

    logic_analyzer #(
        .CAPTURE_WIDTH(CAPTURE_WIDTH),
        .CAPTURE_SAMPLES(CAPTURE_SAMPLES)
    ) uanalyze (
        .n_rst(n_rst),
        .clk(clk),

        .clock_enable(1'b1),

        .capture_trigger(capture_trigger),
        .capture(i_capture_data),
        .capture_finished(capture_finished),

        .read_en(read_en),
        .read_data(read_data),
        .read_finished(read_finished)
    );

    function integer max(input integer a, input integer b);
        begin
            max = (a > b) ? a : b;
        end
    endfunction

    localparam TX_BUF_SIZE = max(CAPTURE_WIDTH, 32);
    localparam TX_BUF_WIDTH = $clog2(TX_BUF_SIZE);

    reg                    prev_rx_ready;
    reg [TX_BUF_WIDTH-1:0] tx_count;
    reg [TX_BUF_SIZE-1:0]  tx_buf;

    `include "uartscope.defs.v"

    wire [7:0] sample_size_bytes = CAPTURE_WIDTH / 8;

    (* always_ff *)
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            tx_ready <= 0;
            prev_rx_ready <= 0;
            tx_count <= 0;
            tx_buf <= 0;

            read_en <= 0;
            capture_trigger__manual <= 0;
        end else begin
            prev_rx_ready <= rx_ready;
            capture_trigger__manual <= 0;

            if (read_en & !read_finished) begin
                tx_count <= $bits(read_data) / 8;
                tx_buf <= read_data;
                read_en <= 0;
            end

            if (!tx_busy) begin
                tx_ready <= 0;
                if (tx_count != 'b0) begin
                    tx_count <= tx_count - 1;
                    tx_data <= tx_buf[7:0];
                    tx_buf <= tx_buf >> 8;
                    tx_ready <= 1;
                end else if (!read_finished) begin
                    read_en <= 1;
                end
            end

            if (rx_ready & !prev_rx_ready) begin
                case (rx_data)
                    UARTSCOPE_CMD_TRIGGER         : capture_trigger__manual <= 1;
                    UARTSCOPE_CMD_CAPTURE_FINISHED: begin tx_count <= 1; tx_buf <= capture_finished; end
                    UARTSCOPE_CMD_DUMP            : read_en <= 1;
                    UARTSCOPE_CMD_DUMP_FINISHED   : begin tx_count <= 1; tx_buf <= read_finished; end
                    UARTSCOPE_CMD_SAMPLE_SIZE     : begin tx_count <= 3; tx_buf <= { CAPTURE_SAMPLES & 16'hffff, sample_size_bytes }; end
                endcase
            end
        end
    end

endmodule
