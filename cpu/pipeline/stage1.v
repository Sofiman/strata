module stage1 (
    input         n_rst,
    input         clk,

    input         up_valid,
    input         dw_ready,
    output        dw_valid,
    output        up_ready,

    output [31:0] o__pc,
    output [31:0] o__inst,

    input         i__pc_write_en,
    input  [31:0] i__pc_next
);

    wire [31:0] _b__o__inst = o__inst;

    ifetch u_ifetch (
        .n_rst(n_rst),
        .clk(clk),

        .up_addr_write_enable(i__pc_write_en),
        .up_addr(i__pc_next),
        .up_ready(up_ready),
        .up_valid(up_valid),

        .dw_valid(dw_valid),
        .dw_ready(dw_ready),
        .dw_pc(o__pc),
        .dw_inst(o__inst)
    );

endmodule
