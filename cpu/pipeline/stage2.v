`include "cpu/pipeline/bench.v"

module stage2 (
    input         n_rst,
    input         clk,

    input         i__clear,
    input         up_valid,
    input         dw_ready,
    output        dw_valid,
    output        up_ready,

    input [31:0]  i__pc,
    input [31:0]  i__inst,

    output        o__alu_en,
    output        o__mem_en,
    output        o__bru_en,
    output [ 3:0] o__op,
    output [31:0] o__op_a,
    output [31:0] o__op_b,

    output [ 4:0] o__rf_addr_out,
    output [ 4:0] o__rf_addr_a,
    input  [31:0] i__rf_a,
    output [ 4:0] o__rf_addr_b,
    input  [31:0] i__rf_b

    `BENCH_STAGE_INOUT
);

    `BENCH_STAGE_LOGIC

    decoder decoder (
        .clk(clk),
        .n_rst(n_rst),

        .up_clear(i__clear),

        .up_valid(up_valid),
        .up_ready(up_ready),
        .up_pc(i__pc),
        .up_inst(i__inst),

        .dw_valid(dw_valid),
        .dw_ready(dw_ready),

        .alu_en(o__alu_en),
        .mem_en(o__mem_en),
        .bru_en(o__bru_en),

        .op(o__op),
        .op_a(o__op_a),
        .op_b(o__op_b),

        .rf_addr_out(o__rf_addr_out),
        .rf_addr_a(o__rf_addr_a),
        .rf_a(i__rf_a),
        .rf_addr_b(o__rf_addr_b),
        .rf_b(i__rf_b)
    );

endmodule
