module ram #(
    parameter DEPTH = 1 * /* BSRAM cap */ 16384 / /* bithwidth */ 32, // 16Kb = 1 BRAM
    parameter XLEN = 32
) (
    input clk,
    input rst,
    input                     read_enable,
    input                     write_enable,
    input [XLEN-1:0]          wr_data,
    input [$clog2(DEPTH)-1:0] addr,

    output reg [XLEN-1:0] data
);

    (* ram_style = "block" *) reg [XLEN-1:0] mem [DEPTH-1:0];

    always @(posedge clk) begin
        if (write_enable) begin
            mem[addr] <= wr_data;
        end

        if (read_enable) begin
            data <= write_enable ? wr_data : mem[addr];
        end
    end

endmodule
