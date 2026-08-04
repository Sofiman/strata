`include "cpu/pipeline/bench.v"

module stage3 (
    input             n_rst,
    input             clk,

    input             i__clear,
    input             up_valid,
    input             dw_ready,
    output            dw_valid,
    output            up_ready,

    input             i__alu_en,
    input             i__mem_en,
    input             i__bru_en,
    input      [ 3:0] i__op,
    input      [31:0] i__op_a,
    input      [31:0] i__op_b,

    input      [ 4:0] i__rf_addr_out,
    output reg [ 4:0] o__rf_addr_out,
    output     [31:0] o__rf_wr_data,

    output            o__pc_write_en,
    output     [31:0] o__pc_next,

    output        mem_valid,
    input         mem_ready,
    output [31:0] mem_addr,
    output [ 3:0] mem_strobe,
    output [31:0] mem_write_data,
    input  [31:0] mem_read_data,
    input         mem_fault

    `BENCH_STAGE_INOUT
);

    `BENCH_STAGE_LOGIC

    (* always_ff *)
    always @(posedge clk) if (up_valid & up_ready) o__rf_addr_out <= i__rf_addr_out;

    reg r_alu_en;
    (* always_ff *)
    always @(posedge clk) if (up_valid & up_ready) r_alu_en <= i__alu_en;

    reg r_mem_en;
    (* always_ff *)
    always @(posedge clk) if (up_valid & up_ready) r_mem_en <= i__mem_en;

    reg r_bru_en;
    (* always_ff *)
    always @(posedge clk) if (up_valid & up_ready) r_bru_en <= i__bru_en;

    wire [31:0] alu_out;
    wire        alu_valid;
    wire        alu_ready;

    wire [31:0] lsu_out;
    wire        lsu_valid;
    wire        lsu_ready;

    wire        bru_valid;
    wire        bru_ready;

    alu alu (
        .clk    (clk),
        .n_rst  (n_rst),

        .up_valid(i__alu_en & up_valid),
        .up_ready(alu_ready),
        .dw_valid(alu_valid),
        .dw_ready(dw_ready),

        .op     (i__op[2:0]),
        .op_alt (i__op[3]),

        .a      (i__op_a),
        .b      (i__op_b),
        .out    (alu_out)
    );

    reg [31:0] op_addr;
    always @(posedge clk) if (up_valid & up_ready) op_addr <= i__op_a + $signed(i__op_b);

    load_store lsu (
        .n_rst(n_rst),
        .clk(clk),

        .up_valid(i__mem_en & up_valid),
        .up_ready(lsu_ready),

        .dw_valid(lsu_valid),
        .dw_ready(dw_ready),

        .up_addr(op_addr),
        .up_op(i__op),
        .up_data_in('h66666666),
        .dw_data_out(lsu_out),

        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_strobe(mem_strobe),
        .mem_write_data(mem_write_data),
        .mem_read_data(mem_read_data),
        .mem_fault(mem_fault)
    );

    bru bru (
        .clk(clk),
        .n_rst(n_rst),

        .up_valid(i__bru_en & up_valid),
        .up_ready(bru_ready),

        .dw_valid(bru_valid),
        .dw_ready(dw_ready),

        .up_op(i__op),
        .up_addr(op_addr),
        .up_rf_a(32'b0),
        .up_rf_b(32'b0),

        .dw_pc_write_en(o__pc_write_en),
        .dw_pc_next(o__pc_next)
    );

     assign o__rf_wr_data = //alu_out ?
           ({32{r_alu_en}} & alu_out)
         | ({32{r_mem_en}} & lsu_out);
     assign dw_valid = !i__clear &
        (  (r_alu_en & alu_valid)
         | (r_mem_en & lsu_valid)
         | (r_bru_en & bru_valid)
        );
     assign up_ready =
           (!r_alu_en | alu_ready)
         & (!r_mem_en | lsu_ready)
         & (!r_bru_en | bru_ready);

endmodule
