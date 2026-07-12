`include "cpu/pipeline/bench.v"

module stage3 (
    input             n_rst,
    input             clk,

    input             i__valid,
    input             i__busy,
    output            o__valid,
    output            o__busy,

    input             i__alu_en,
    input             i__mem_en,
    input             i__bru_en,
    input      [ 3:0] i__op,
    input      [31:0] i__op_a,
    input      [31:0] i__op_b,

    input      [ 4:0] i__rf_addr_out,
    output reg [ 4:0] o__rf_addr_out,
    output     [31:0] o__rf_wr_data,

    output      [5:0] leds

    `BENCH_STAGE_INOUT
);

    `BENCH_STAGE_LOGIC

    always @(posedge clk) if (i__valid & !o__busy) o__rf_addr_out <= i__rf_addr_out;

    wire [31:0] alu_out;
    wire [31:0] mem_out;
    wire        mem_busy;
    wire        mem_valid;

    reg alu_valid;
    always @(posedge clk) if (i__valid) alu_valid <= i__alu_en;

    alu alu (
        .clk    (clk),
        .n_rst  (n_rst),

        .op     (i__op[2:0]),
        .op_alt (i__op[3]),

        .a      (i__op_a),
        .b      (i__op_b),
        .out    (alu_out)
    );


    wire [31:0] op_addr = i__op_a + $signed(i__op_b);
    load_store u_load_store (
        .n_rst(n_rst),
        .clk(clk),

        .addr(op_addr),
        .op(i__op),
        .data_in('h66666666),
        .data_out(mem_out),

        .i_valid(i__valid & !i__busy & i__mem_en),
        .o_valid(mem_valid),
        .o_busy(mem_busy),

        .leds(leds)
    );

    /*
    bru bru (
        .clk(clk),
        .n_rst(n_rst),

        .i_valid(bru_en),

        .op(op),
        .addr(op_addr),
        .rf_a(rf_a),
        .rf_b(rf_b),
        .pc(pc),

        .pc_next(pc_next)
    );*/


    assign o__rf_wr_data = alu_valid ? alu_out : mem_out;
    assign o__valid      = alu_valid ? 1'b1 : (mem_valid & !mem_busy);
    assign o__busy       = i__busy | mem_busy;

endmodule
