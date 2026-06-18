`timescale 1 ns / 10 ps

`define CLK_HALF_PERIOD 18.518 // 27Mhz
`define CLK_PERIOD (`CLK_HALF_PERIOD * 2)

`define assert_eq(signal, value) \
    if (signal !== value) begin \
        $display("\033[4;31mASSERTION FAILED in %m:\033[24m signal != value  at line %0d\033[0m", `__LINE__); \
        $display("\t\033[35mactual:\033[0m    0x%h  \033[90m[signal]\033[0m", signal); \
        $display("\t\033[35mexpected:\033[0m  0x%h  \033[90m[value]\033[0m", value); \
        #(`CLK_HALF_PERIOD) \
        $finish; \
    end

module logic_analyzer_tb();

    localparam DURATION = 10_000;

    reg rst = 1'b0, clk = 1'b0, ok = 1'b0;

    always begin
        #(`CLK_HALF_PERIOD)
        clk = ~clk;
    end

    reg         capture_trigger = 0;
    reg [31:0]  capture = 0;
    wire        capture_finished;
    reg         read_en = 0;
    wire [31:0] read_data;
    wire        read_finished;

    logic_analyzer #(
        .CAPTURE_WIDTH(32),
        .CAPTURE_SAMPLES(4)
    ) uut (
        .n_rst(!rst),
        .clk(clk),

        .clock_enable(1'b1),

        .capture_trigger(capture_trigger),
        .capture(capture),
        .capture_finished(capture_finished),

        .read_en(read_en),
        .read_data(read_data),
        .read_finished(read_finished)
    );


    initial begin
        $display("\n--- RESET ---");
        #10
        rst = 1'b1;
        #1
        rst = 1'b0;
    end

    initial begin
        @(posedge clk);
        capture <= 32'haabbccdd;
        capture_trigger <= 1;

        @(posedge clk);

        capture_trigger <= 0;
        capture <= 32'heeff0011;

        @(posedge clk);

        capture <= 32'h22334455;
        `assert_eq(capture_finished, 0);

        @(posedge clk);

        capture <= 32'h66778899;
        `assert_eq(capture_finished, 0);

        @(posedge clk);

        capture <= 32'habcdef00;
        `assert_eq(capture_finished, 0);

        @(posedge clk);

        capture <= 32'hffffffff;

        @(posedge clk);

        `assert_eq(capture_finished, 1);

        @(posedge clk);

        read_en <= 1;

        @(posedge clk);

        #0.1 `assert_eq(read_finished, 0);

        @(posedge clk);

        `assert_eq(read_data, 32'heeff0011);
        `assert_eq(read_finished, 0);

        @(posedge clk);

        `assert_eq(read_data, 32'h22334455);
        `assert_eq(read_finished, 0);

        @(posedge clk);

        //read_en <= 0;
        `assert_eq(read_data, 32'h66778899);
        `assert_eq(read_finished, 0);

        @(posedge clk);
        `assert_eq(read_data, 32'habcdef00);
        `assert_eq(read_finished, 1);

        @(posedge clk);

        ok = 1'b1;
    end

    initial begin
        $dumpfile(`VCD_OUTPUT);
        $dumpvars(/* infinite depth */ 0, logic_analyzer_tb);
        #(DURATION)

        if (!ok) $display("\033[31mTEST TIMED OUT\033[0m");
        $finish;
    end


endmodule
