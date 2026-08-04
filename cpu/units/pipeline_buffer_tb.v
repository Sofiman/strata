`timescale 1 ns / 10 ps

`define CLK_HALF_PERIOD 18.518 // 27Mhz
`define CLK_PERIOD (`CLK_HALF_PERIOD * 2)

`define BENCH
`ifdef werugferuhg
`define assert_eq(signal, value) \
    if (signal !== value) begin \
        $display("\033[4;31mASSERTION FAILED in %m:\033[24m signal != value  at line %0d\033[0m", `__LINE__); \
        $display("\t\033[35mactual:\033[0m    0x%h  \033[90m[signal]\033[0m", signal); \
        $display("\t\033[35mexpected:\033[0m  0x%h  \033[90m[value]\033[0m", value); \
        //@(posedge clk) \
        #20 \
        $finish; \
    end
`else
`define assert_eq(signal, value)
`endif

module pipeline_buffer_tb();

    localparam DURATION = 10_000;

    reg rst = 1'b0, clk = 1'b0, ok = 1'b0;
    wire [5:0] leds;

    always begin
        #(`CLK_HALF_PERIOD)
        clk = ~clk;
    end

    `include "cfg/rv_isa_registers.v"

    reg  [7:0] stage1__up_data = 0;
    reg        stage1__up_valid = 0;
    wire       stage1__up_ready;
    wire [7:0] stage1__dw_data;
    wire       stage1__dw_valid;
    wire       stage1__dw_ready;
    reg        dw_ready = 0;

    pipeline_buffer #(
        .DATA_WIDTH(8)
    ) uut (
        .clk(clk),
        .n_rst(!rst),

        .up_data (stage1__up_data ),
        .up_valid(stage1__up_valid),
        .up_ready(stage1__up_ready),
        .dw_data (stage1__dw_data ),
        .dw_valid(stage1__dw_valid),
        .dw_ready(stage1__dw_ready)
    );

    initial begin
        $display("\n--- RESET ---");
        #10
        rst = 1'b1;
        #1
        rst = 1'b0;

        @(posedge clk);

        `assert_eq(stage1__up_ready, 1'b0);
        `assert_eq(stage1__dw_valid, 1'b0);

        stage1__up_data = 8'h42;
        stage1__up_valid = 1'b1;

        @(posedge clk);

        `assert_eq(stage1__up_ready, 1'b0);
        `assert_eq(stage1__dw_valid, 1'b0);

        dw_ready <= 1'b1;

        @(posedge clk);

        #0.1

        `assert_eq(stage1__up_ready, 1'b1);
        `assert_eq(stage1__dw_valid, 1'b1);
        `assert_eq(stage1__dw_data,  8'h42);

        stage1__up_data = 8'hff;

        @(posedge clk);

        #0.1

        //`assert_eq(stage1__up_ready, 1'b1);
        `assert_eq(stage1__dw_valid, 1'b1);
        `assert_eq(stage1__dw_data,  8'hff);

        stage1__up_data = 8'haa;

        @(posedge clk);

        #0.1

        `assert_eq(stage1__up_ready, 1'b1);
        `assert_eq(stage1__dw_valid, 1'b1);
        `assert_eq(stage1__dw_data,  8'haa);

        stage1__up_valid = 1'b0;

        @(posedge clk);
        #0.1

        `assert_eq(stage1__up_ready, 1'b1);
        `assert_eq(stage1__dw_valid, 1'b0);

        stage1__up_data = 8'hdd;
        stage1__up_valid = 1'b1;
        dw_ready = 1'b0;

        @(posedge clk);

        `assert_eq(stage1__up_ready, 1'b0);
        `assert_eq(stage1__dw_valid, 1'b0);

        dw_ready = 1'b1;

        @(posedge clk);
        #0.1

        `assert_eq(stage1__up_ready, 1'b1);
        `assert_eq(stage1__dw_valid, 1'b1);
        `assert_eq(stage1__dw_data,  8'hdd);

        stage1__up_data = 8'hee;
        stage1__up_valid = 1'b0;

        @(posedge clk);

        stage1__up_valid = 1'b1;


        @(posedge clk);
        #0.1
        stage1__up_data = 8'h33;

        `assert_eq(stage1__dw_data,  8'hee);

        ok = 1'b1;
    end

   /*
    initial begin
        $display("\n--- RESET ---");
        #10
        rst = 1'b1;
        #1
        rst = 1'b0;

        @(posedge clk);

        up_valid = 1'b1;
        up_data = 8'hAA;
        dw_ready = 1'b1;

        @(posedge clk);

        #0.1

        `assert_eq(up_ready, 1'b1);
        `assert_eq(dw_valid, 1'b1);
        `assert_eq(dw_data,  8'hAA);

        up_valid = 1'b1;
        up_data = 8'hBB;
        dw_ready = 1'b0;

        @(posedge clk);
        @(posedge clk);

        #0.1

        up_valid = 1'b1;
        up_data = 8'hBB;
        dw_ready = 1'b0;

        @(posedge clk);

        dw_ready = 1'b1;

        @(posedge clk);

        ok = 1'b1;
    end*/

    wire [7:0] stage2__up_data = stage1__dw_data;
    wire       stage2__up_valid = stage1__dw_valid;
    wire       stage2__up_ready;
    wire [7:0] stage2__dw_data;
    wire       stage2__dw_valid;
    wire       stage2__dw_ready = dw_ready;

    pipeline_buffer_delay #(
        .DATA_WIDTH(8)
    ) stage2 (
        .clk(clk),
        .n_rst(!rst),

        .up_data (stage2__up_data ),
        .up_valid(stage2__up_valid),
        .up_ready(stage2__up_ready),
        .dw_data (stage2__dw_data ),
        .dw_valid(stage2__dw_valid),
        .dw_ready(stage2__dw_ready)
    );

    assign stage1__dw_ready = stage2__up_ready;

    initial begin
        $dumpfile(`VCD_OUTPUT);
        $dumpvars(/* infinite depth */ 0, pipeline_buffer_tb);
        #(DURATION)

        if (!ok) $display("\033[31mTEST TIMED OUT\033[0m");
        $finish;
    end


endmodule
