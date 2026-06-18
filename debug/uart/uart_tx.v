module uart_tx #(
    parameter INPUT_CLK_FREQ = 0,
    parameter BAUD_RATE = 115200,

    parameter DATA_BITS = 8, // 5 to 9 bits + (optional) parity bit
    parameter STOP_BITS = 1 // 1 or 2
) (
    input n_rst,
    input clk,
    input tx_ready,
    input [DATA_BITS-1:0] tx_data,

    output reg tx_busy,
    output reg tx
);

    /* Baud Clock generation */
    localparam CLK_DIV = INPUT_CLK_FREQ/BAUD_RATE;
    localparam CLK_HALF_DIV = (INPUT_CLK_FREQ/(2*BAUD_RATE));
    localparam CLK_DIV_BITS = $clog2(CLK_DIV);
    reg [CLK_DIV_BITS-1:0] clk_div;
    reg baud_clk;

    /* State Machine */
    localparam S_IDLE      = 0;
    localparam S_DATA_BITS = 1;
    localparam S_STOP_BITS = 2;
    localparam STATE_BITS = $clog2(S_STOP_BITS+1);

    reg [STATE_BITS-1:0] state;
    reg [STATE_BITS-1:0] state_next;
    reg [3:0] tx_count;
    reg [3:0] tx_count_next;
    reg [DATA_BITS-1:0] tx_data_to_send;
    reg tx_latch_data;
    reg tx_reset_baud_clk;
    reg tx_val;
    reg tx_busy_next;

    always @(*) begin
        state_next <= state;
        tx_count_next <= tx_count;
        tx_latch_data <= 0;
        tx_reset_baud_clk <= 0;
        tx_busy_next <= tx_busy;
        tx_val <= tx;

        case (state)
            S_IDLE: begin
                if (tx_ready) begin
                    state_next <= S_DATA_BITS;
                    tx_reset_baud_clk <= 1;
                    tx_count_next <= DATA_BITS-1;
                    tx_busy_next <= 1;

                    tx_val <= 0; /* START BIT */
                end
            end
            S_DATA_BITS: begin
                if (baud_clk) begin
                    tx_latch_data <= 1;
                    tx_val <= tx_data_to_send[0];
                    if (tx_count == 0) begin
                        state_next <= S_STOP_BITS;
                        tx_count_next <= STOP_BITS - 1 + /* TX must hold stop bit for one additional baud clk before setting busy=0 */ 1;
                    end else begin
                        tx_count_next <= tx_count - 1;
                    end
                end
            end
            S_STOP_BITS: begin
                if (baud_clk) begin
                    tx_val <= 1; /* STOP BIT(S) */

                    if (tx_count == 0) begin
                        state_next <= S_IDLE;
                        tx_busy_next <= 0;
                    end else begin
                        tx_count_next <= tx_count - 1;
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
            tx_count <= 0;
            tx_data_to_send <= 0;

            clk_div <= CLK_DIV-1;
            baud_clk <= 0;
            tx <= 1;
            tx_busy <= 0;
        end else begin
            baud_clk <= 0;

            if (tx_reset_baud_clk) begin
                clk_div <= CLK_DIV-1;
                tx_data_to_send <= tx_data;
            end else if (clk_div == 0) begin
                clk_div <= CLK_DIV-1;
                baud_clk <= 1;
            end else begin
                clk_div <= clk_div - 1;
            end

            if (tx_latch_data) begin
                tx_data_to_send[6:0] <= tx_data_to_send[7:1];
            end

            state <= state_next;
            tx_count <= tx_count_next;
            tx_busy <= tx_busy_next;
            tx <= tx_val;
        end
    end

endmodule
