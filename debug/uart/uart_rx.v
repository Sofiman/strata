module uart_rx #(
    parameter INPUT_CLK_FREQ = 0,
    parameter BAUD_RATE = 115200,

    parameter DATA_BITS = 8, // 5 to 9 bits + (optional) parity bit
    parameter STOP_BITS = 1 // 1 or 2
) (
    input n_rst,
    input clk,
    input rx,

    output reg rx_err,
    output reg rx_ready,
    output reg [DATA_BITS-1:0] rx_data
);

    /* Control signals */
    reg rx_err_next;
    reg rx_ready_next;
    reg rx_reset_baud_clk_to_half_tick;
    reg rx_latch_data;

    reg rx_sync_1;
    reg rx_sync_2;

    /* Baud Clock generation */
    localparam CLK_DIV = INPUT_CLK_FREQ/BAUD_RATE;
    localparam CLK_HALF_DIV = (INPUT_CLK_FREQ/(2*BAUD_RATE));
    localparam CLK_DIV_BITS = $clog2(CLK_DIV);
    reg [CLK_DIV_BITS-1:0] clk_div;
    reg baud_clk;

    /* State Machine */
    localparam S_IDLE      = 0;
    localparam S_START_BIT = 1;
    localparam S_DATA_BITS = 2;
    localparam S_STOP_BITS = 3;
    localparam STATE_BITS = $clog2(S_STOP_BITS+1);

    reg [STATE_BITS-1:0] state;
    reg [STATE_BITS-1:0] state_next;
    reg [DATA_BITS-1:0] rx_data_tmp;
    reg [3:0] rx_count;
    reg [3:0] rx_count_next;

    always @(*) begin
        state_next <= state;
        rx_count_next <= rx_count;
        rx_err_next <= rx_err;
        rx_ready_next <= rx_ready;
        rx_reset_baud_clk_to_half_tick <= 0;
        rx_latch_data <= 0;

        case (state)
            S_IDLE: begin
                if (!rx_sync_2) begin
                    state_next <= S_START_BIT;
                    rx_reset_baud_clk_to_half_tick <= 1;
                    rx_err_next <= 0;
                    rx_ready_next <= 0;
                    rx_count_next <= DATA_BITS-1;
                end
            end
            S_START_BIT: begin
                if (baud_clk) begin
                    state_next <= S_DATA_BITS;
                    if (rx_sync_2) begin
                        rx_err_next <= 1;
                    end
                end
            end
            S_DATA_BITS: begin
                if (baud_clk) begin
                    rx_latch_data <= 1;
                    if (rx_count == 0) begin
                        rx_count_next <= STOP_BITS-1;
                        state_next <= S_STOP_BITS;
                    end else begin
                        rx_count_next <= rx_count - 1;
                    end
                end
            end
            S_STOP_BITS: begin
                if (baud_clk) begin

                    if (!rx_sync_2) begin
                        rx_err_next <= 1;
                    end
                    if (rx_count == 0) begin
                        state_next <= S_IDLE;
                        rx_ready_next <= 1;
                    end else begin
                        rx_count_next <= rx_count - 1;
                    end
                end
            end
            default: begin
                state_next <= S_IDLE;
            end
        endcase
    end

    always @ (posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            state <= S_IDLE;
            rx_count <= 0;

            rx_err <= 0;
            rx_ready <= 0;

            clk_div <= CLK_DIV-1;
            baud_clk <= 0;
            rx_data <= 0;
            rx_data_tmp <= 0;

            rx_sync_1 <= 1;
            rx_sync_2 <= 1;
        end else begin
            rx_sync_1 <= rx;
            rx_sync_2 <= rx_sync_1;

            baud_clk <= 0;
            if (rx_reset_baud_clk_to_half_tick) begin
                clk_div <= CLK_HALF_DIV;
            end else if (clk_div == 0) begin
                clk_div <= CLK_DIV-1;
                baud_clk <= 1;
            end else begin
                clk_div <= clk_div - 1;
            end

            if (rx_latch_data) begin
                rx_data_tmp <= {rx_sync_2, rx_data_tmp[7:1]}; // Shift bits
            end

            state <= state_next;
            rx_count <= rx_count_next;

            rx_err <= rx_err_next;
            rx_ready <= rx_ready_next;
            if (rx_ready_next) begin
                rx_data <= rx_data_tmp;
            end
        end
    end

endmodule
