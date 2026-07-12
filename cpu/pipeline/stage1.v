module stage1 (
    input         n_rst,
    input         clk,

    input         i__valid,
    input         i__busy,
    output        o__valid,
    output        o__busy,

    output [31:0] o__pc,
    output [31:0] o__inst
);

    wire [31:0] _b__o__inst = o__inst;

    ifetch u_ifetch (
        .n_rst(n_rst),
        .clk(clk),

        .addr_write_enable(1'b1),
        .addr(o__pc + 4),

        .pc(o__pc),
        .inst(o__inst),

        .i_busy(i__busy),
        .i_valid(i__valid),
        .o_busy(o__busy),
        .o_valid(o__valid)
    );

    // TODO: Hazard detection, RAW hanndling

endmodule
