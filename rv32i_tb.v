`timescale 1 ns / 10 ps

`define CLK_HALF_PERIOD 18.518 // 27Mhz
`define CLK_PERIOD (`CLK_HALF_PERIOD * 2)

`define BENCH
`define assert_eq(signal, value) \
    if (signal !== value) begin \
        $display("\033[4;31mASSERTION FAILED in %m:\033[24m signal != value  at line %0d\033[0m", `__LINE__); \
        $display("\t\033[35mactual:\033[0m    0x%h  \033[90m[signal]\033[0m", signal); \
        $display("\t\033[35mexpected:\033[0m  0x%h  \033[90m[value]\033[0m", value); \
        @(posedge clk) \
        $finish; \
    end

module rv32i_tb();

    localparam DURATION = 10_000;

    reg rst = 1'b0, clk = 1'b0, ok = 1'b0;
    wire [5:0] leds;

    always begin
        #(`CLK_HALF_PERIOD)
        clk = ~clk;
    end

    `include "cfg/rv_isa_registers.v"

    wire mem_valid;
    wire mem_ready;
    wire [31:0] mem_addr;
    wire [3:0] mem_strobe;
    wire [31:0] mem_write_data;
    wire [31:0] mem_read_data;
    wire mem_fault;

    rv32i uut (
        .rst(rst),
        .clk(clk),

        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_strobe(mem_strobe),
        .mem_write_data(mem_write_data),
        .mem_read_data(mem_read_data),
        .mem_fault(mem_fault)
    );

    memory_subsys mss (
        .n_rst(!rst),
        .clk(clk),

        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_strobe(mem_strobe),
        .mem_write_data(mem_write_data),
        .mem_read_data(mem_read_data),
        .mem_fault(mem_fault),

        .leds(leds)
    );

`ifdef SEQ
    //task wait_inst_retire();
    //    begin
    //        wait(uut.state !== uut.S_WRITEBACK);
    //        wait(uut.state === uut.S_WRITEBACK && uut.writeback_ready);
    //        #(`CLK_HALF_PERIOD/16);
    //    end
    //endtask

    //wire [31:0] pc = uut.u_ifetch.retired_inst_pc;
`endif

    task wait_inst_retire();
        uut.wait_inst_retire();
    endtask

    initial begin
        $display("\n--- RESET ---");
        #10
        rst = 1'b1;
        #1
        rst = 1'b0;
    end

    `include `TEST_SCRIPT

    initial begin
        $dumpfile(`VCD_OUTPUT);
        $dumpvars(/* infinite depth */ 0, rv32i_tb);
        #(DURATION)

        if (!ok) $display("\033[31mTEST TIMED OUT\033[0m");
        $finish;
    end


endmodule
