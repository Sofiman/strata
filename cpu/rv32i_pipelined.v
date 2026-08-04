module rv32i (
    input rst,
    input clk,

    output        mem_valid,
    input         mem_ready,
    output [31:0] mem_addr,
    output [ 3:0] mem_strobe,
    output [31:0] mem_write_data,
    input  [31:0] mem_read_data,
    input         mem_fault,

    output [127:0] snoop_data
);

    wire n_rst = !rst;

    wire        stage1__i__valid = 1'b1;
    wire        stage1__i__ready;
    wire        stage1__o__valid;
    wire        stage1__o__ready;
    wire [31:0] stage1__o__pc;
    wire [31:0] stage1__o__inst;

    wire        stage1__i__pc_write_en;
    wire [31:0] stage1__i__pc_next;

    stage1 s1 (
        .n_rst         (n_rst),
        .clk           (clk),

        .up_valid      (stage1__i__valid),
        .dw_ready      (stage1__i__ready ),

        .i__pc_write_en(stage1__i__pc_write_en),
        .i__pc_next    (stage1__i__pc_next),


        .dw_valid      (stage1__o__valid),
        .up_ready      (stage1__o__ready ),
        .o__pc         (stage1__o__pc),
        .o__inst       (stage1__o__inst)
    );

    wire        stage2__o__valid;
    wire        stage2__i__ready;
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

        .i__clear       (stage1__i__pc_write_en),
        .up_valid       (stage1__o__valid),
        .dw_ready       (stage2__i__ready ),
        .i__pc          (stage1__o__pc),
        .i__inst        (stage1__o__inst),

        .dw_valid       (stage2__o__valid),
        .up_ready       (stage1__i__ready ),

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
    wire        stage3__i__ready;
    wire [ 4:0] stage3__o__rf_addr_out;
    wire [31:0] stage3__o__rf_wr_data;

    stage3 s3 (
        .n_rst          (n_rst),
        .clk            (clk),

        .i__clear       (stage1__i__pc_write_en),
        .up_valid       (stage2__o__valid),
        .dw_ready       (stage3__i__ready ),
        .i__alu_en      (stage2__o__alu_en),
        .i__mem_en      (stage2__o__mem_en),
        .i__bru_en      (stage2__o__bru_en),
        .i__op          (stage2__o__op),
        .i__op_a        (stage2__o__op_a),
        .i__op_b        (stage2__o__op_b),
        .i__rf_addr_out (stage2__o__rf_addr_out),

        .dw_valid       (stage3__o__valid),
        .up_ready       (stage2__i__ready ),
        .o__rf_addr_out (stage3__o__rf_addr_out),
        .o__rf_wr_data  (stage3__o__rf_wr_data),

        .o__pc_write_en (stage1__i__pc_write_en),
        .o__pc_next     (stage1__i__pc_next),

        .mem_valid      (mem_valid),
        .mem_ready      (mem_ready),
        .mem_addr       (mem_addr),
        .mem_strobe     (mem_strobe),
        .mem_write_data (mem_write_data),
        .mem_read_data  (mem_read_data),
        .mem_fault      (mem_fault)

        `BENCH_STAGE_BOND(s2)
    );

    wire [ 4:0] stage4__o__rf_addr_out;
    wire        stage4__o__rf_wr_en;
    wire [31:0] stage4__o__rf_wr_data;

    stage4 s4 (
        .n_rst          (n_rst),
        .clk            (clk),

        .i__clear       (1'b0),
        .up_valid       (stage3__o__valid),
        .dw_ready       (1'b1),
        .up_ready       (stage3__i__ready ),
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
        stage1__o__valid, stage1__i__ready,
        stage2__o__valid, stage2__i__ready,
        stage3__o__valid, stage3__i__ready
    };

    task wait_inst_retire();
        begin
            wait(stage3__o__valid);
            @(posedge clk);
            #(`CLK_HALF_PERIOD/16);
        end
    endtask

endmodule

// TODO:
// - [X] Validation testbenches for regression testing
// - [X] Load/Store unit
// - [ ] Attach MMIO UART
// - [ ] Interrupt unit
// - [ ] Multiply extension
// - [ ] Divide extension
// - [.] Pipelining (https://zipcpu.com/blog/2017/08/14/strategies-for-pipelining.html, https://zipcpu.com/zipcpu/2017/08/23/cpu-pipeline.html)
//   - [.] RAW ready cycle insertion
//   - [ ] RAW forwarding in stage3 for 0 cycle wait
// - [ ] Simpl branch predictor (same-as-before, two-mispredictions-in-a-row) -- Source: https://www.youtube.com/watch?v=mGCClZpjX0g, https://danluu.com/branch-prediction/
// - [ ] Zihintpause
// - [ ] Zicsr: CSRs
// - [ ] Zicntr: counters cycle, time, instret
// - [ ] Zicond
// - [ ] Compressed instructions
