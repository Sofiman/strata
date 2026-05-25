module ram #(
    parameter DEPTH = 1 * /* BSRAM cap */ 16384 / /* bithwidth */ 32, // 16Kb = 1 BRAM
    parameter XLEN = 32
) (
    input clk,
    input n_rst,
    input                     read_enable,
    input [3:0]               write_enable,
    input [XLEN-1:0]          wr_data,
    input [$clog2(DEPTH)-1:0] addr,

    output reg [XLEN-1:0] data
);

    (* ram_style = "block" *) reg [XLEN-1:0] mem [DEPTH-1:0];

    (* always_ff *)
    always @(posedge clk) begin
        if (write_enable[3]) mem[addr][31:24] <= wr_data[31:24];
        if (write_enable[2]) mem[addr][23:16] <= wr_data[23:16];
        if (write_enable[1]) mem[addr][15: 8] <= wr_data[15: 8];
        if (write_enable[0]) mem[addr][ 7: 0] <= wr_data[ 7: 0];

        if (read_enable) begin
            data <= write_enable ? wr_data : mem[addr];
        end
    end

endmodule
