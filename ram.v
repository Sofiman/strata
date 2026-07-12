module ram #(
    parameter DEPTH = 1 * /* BSRAM cap */ 16384 / /* bithwidth */ 32, // 16Kb = 1 BRAM
    parameter XLEN = 32
) (
    input                          n_rst,
    input                          clk,

    input      [$clog2(DEPTH)-1:0] addr,
    input      [3:0]               write_enable,
    input      [XLEN-1:0]          write_data,
    output reg [XLEN-1:0]          read_data,

    input      i_busy,
    input      i_valid,
    output     o_busy,
    output reg o_valid
);

    (* ram_style = "block" *) reg [XLEN-1:0] mem [DEPTH-1:0];

    reg r_busy;
    assign o_busy = (r_busy) && (!o_valid || i_busy);

    reg clk_enable;
    reg [1:0] timeout;

    (* always_ff *)
    always @(posedge clk or negedge n_rst)  begin
        if (!n_rst) begin
            r_busy  <= 1'b0;
            o_valid <= 1'b0;
            clk_enable <= 1'b0;
        end else if (!o_busy) begin
            o_valid <= 1'b0;
            if (i_valid) begin // An incoming transaction has just taken place
                r_busy <= 1'b1;
                // begin your logic here ...
                clk_enable <= 1'b1;
                timeout <= 2'b01; // 3 cycles
            end
        end else if (o_valid && !i_busy) begin
            // Data was consumed and no new data is available
            r_busy <= 1'b0;
            o_valid  <= 1'b0;
        end else if (!o_valid) begin
            // o_busy is true, so you can perform any necessary logic here
            if (clk_enable) begin
                if (timeout == 2'b00) begin
                    o_valid <= 1'b1;
                    clk_enable <= 1'b0;
                    r_busy <= 1'b0;
                end else
                    timeout <= timeout - 1;
            end
        end
    end

    (* always_ff *)
    always @(negedge clk) begin
        if (clk_enable) begin
            if (write_enable[3]) mem[addr][31:24] <= write_data[31:24];
            if (write_enable[2]) mem[addr][23:16] <= write_data[23:16];
            if (write_enable[1]) mem[addr][15: 8] <= write_data[15: 8];
            if (write_enable[0]) mem[addr][ 7: 0] <= write_data[ 7: 0];
        end
    end

    (* always_ff *)
    always @(negedge clk) begin
        if (clk_enable && (write_enable == 'b0))
            read_data <= mem[addr];
    end

endmodule
