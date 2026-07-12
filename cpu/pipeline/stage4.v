`include "cpu/pipeline/bench.v"

module stage4 (
    input             n_rst,
    input             clk,

    input             i__valid,
    input             i__busy,
    output            o__busy,

    input      [ 4:0] i__rf_addr_out,
    output reg [ 4:0] o__rf_addr_out,
    output reg        o__rf_wr_en,
    input      [31:0] i__rf_wr_data,
    output reg [31:0] o__rf_wr_data

    `BENCH_STAGE_INOUT
);

    `BENCH_STAGE_LOGIC

    always @(posedge clk) if (i__valid && !i__busy) o__rf_addr_out <= i__rf_addr_out;
    always @(posedge clk) if (i__valid && !i__busy)  o__rf_wr_data <= i__rf_wr_data;
    always @(posedge clk) o__rf_wr_en   <= i__valid && !i__busy;
    assign o__busy       = i__busy;

endmodule
