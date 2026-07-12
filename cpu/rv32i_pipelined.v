module rv32i (
    input rst,
    input clk,

    output [5:0] leds,
    output [127:0] snoop_data
);

    wire n_rst = !rst;

    wire        stage1__i__valid = 1'b1;
    wire        stage1__i__busy;
    wire        stage1__o__valid;
    wire        stage1__o__busy;
    wire [31:0] stage1__o__pc;
    wire [31:0] stage1__o__inst;

    stage1 s1 (
        .n_rst(n_rst),
        .clk(clk),

        .i__valid(stage1__i__valid),
        .i__busy (stage1__i__busy ),

        .o__valid(stage1__o__valid),
        .o__busy (stage1__o__busy ),
        .o__pc(stage1__o__pc),
        .o__inst(stage1__o__inst)
    );

    wire        stage2__o__valid;
    wire        stage2__i__busy;
    wire        stage2__o__alu_en;
    wire        stage2__o__mem_en;
    wire        stage2__o__bru_en;
    wire [ 3:0] stage2__o__op;
    wire [31:0] stage2__o__op_a;
    wire [31:0] stage2__o__op_b;
    wire [ 4:0] stage2__o__rf_addr_out;
    wire [ 4:0] stage2__o__rf_addr_a;
    wire [31:0] stage2__i__rf_data_a;
    wire [ 4:0] stage2__o__rf_addr_b;
    wire [31:0] stage2__i__rf_data_b;

    stage2 s2 (
        .n_rst          (n_rst),
        .clk            (clk),

        .i__valid       (stage1__o__valid),
        .i__busy        (stage2__i__busy ),
        .i__pc          (stage1__o__pc),
        .i__inst        (stage1__o__inst),

        .o__valid       (stage2__o__valid),
        .o__busy        (stage1__i__busy ),

        .o__alu_en      (stage2__o__alu_en),
        .o__mem_en      (stage2__o__mem_en),
        .o__bru_en      (stage2__o__bru_en),
        .o__op          (stage2__o__op),
        .o__op_a        (stage2__o__op_a),
        .o__op_b        (stage2__o__op_b),

        .o__rf_addr_out (stage2__o__rf_addr_out),
        .o__rf_addr_a   (stage2__o__rf_addr_a),
        .i__rf_a        (stage2__i__rf_data_a),
        .o__rf_addr_b   (stage2__o__rf_addr_b),
        .i__rf_b        (stage2__i__rf_data_b)

        `BENCH_STAGE_BOND(s1)
    );

    wire        stage3__o__valid;
    wire        stage3__i__busy;
    wire [ 4:0] stage3__o__rf_addr_out;
    wire [31:0] stage3__o__rf_wr_data;

    stage3 s3 (
        .n_rst          (n_rst),
        .clk            (clk),

        .i__valid       (stage2__o__valid),
        .i__busy        (stage3__i__busy ),
        .i__alu_en      (stage2__o__alu_en),
        .i__mem_en      (stage2__o__mem_en),
        .i__bru_en      (stage2__o__bru_en),
        .i__op          (stage2__o__op),
        .i__op_a        (stage2__o__op_a),
        .i__op_b        (stage2__o__op_b),
        .i__rf_addr_out (stage2__o__rf_addr_out),

        .o__valid       (stage3__o__valid),
        .o__busy        (stage2__i__busy ),
        .o__rf_addr_out (stage3__o__rf_addr_out),
        .o__rf_wr_data  (stage3__o__rf_wr_data),
        .leds           (leds)

        `BENCH_STAGE_BOND(s2)
    );

    wire [ 4:0] stage4__o__rf_addr_out;
    wire        stage4__o__rf_wr_en;
    wire [31:0] stage4__o__rf_wr_data;

    stage4 s4 (
        .n_rst          (n_rst),
        .clk            (clk),

        .i__valid       (stage3__o__valid),
        .i__busy        (1'b0),
        .o__busy        (stage3__i__busy ),
        .i__rf_addr_out (stage3__o__rf_addr_out),
        .i__rf_wr_data  (stage3__o__rf_wr_data),

        .o__rf_addr_out (stage4__o__rf_addr_out),
        .o__rf_wr_en    (stage4__o__rf_wr_en),
        .o__rf_wr_data  (stage4__o__rf_wr_data)

        `BENCH_STAGE_BOND(s3)
    );

    register_file rf (
        .clk              (clk),

        .wr__en           (stage4__o__rf_wr_en),
        .wr__addr         (stage4__o__rf_addr_out),
        .wr__data         (stage4__o__rf_wr_data),

        .porta__addr      (stage2__o__rf_addr_a),
        .porta__read_data (stage2__i__rf_data_a),

        .portb__addr      (stage2__o__rf_addr_b),
        .portb__read_data (stage2__i__rf_data_b)
    );

    assign snoop_data = {
        stage1__o__valid, stage1__i__busy,
        stage2__o__valid, stage2__i__busy,
        stage3__o__valid, stage3__i__busy
    };

endmodule

// TODO:
// - [X] Validation testbenches for regression testing
// - [X] Load/Store unit
// - [ ] Attach MMIO UART
// - [ ] Interrupt unit
// - [ ] Multiply extension
// - [ ] Divide extension
// - [.] Pipelining (https://zipcpu.com/blog/2017/08/14/strategies-for-pipelining.html, https://zipcpu.com/zipcpu/2017/08/23/cpu-pipeline.html)
// - [ ] Simpl branch predictor (same-as-before, two-mispredictions-in-a-row) -- Source: https://www.youtube.com/watch?v=mGCClZpjX0g, https://danluu.com/branch-prediction/
// - [ ] Zihintpause
// - [ ] Zicsr: CSRs
// - [ ] Zicntr: counters cycle, time, instret
// - [ ] Zicond
// - [ ] Compressed instructions
