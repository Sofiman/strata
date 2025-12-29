module sign_ext (
    input [11:0] imm,
    output [31:0] out
);

    assign out = {{20{imm[11]}},imm};

endmodule
