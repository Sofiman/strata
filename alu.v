module alu (
    input clk,
    input n_rst,

    input [2:0]  op,
    input        op_alt,
    input [31:0] a,
    input [31:0] b,

    output reg [31:0] out
);

    `include "cfg/rv_isa_opcode.v"

    `ifdef BENCH
    reg [31:0] _b__op_name;
    always @(*) begin
        case (op)
            INT_FUNC3_ADD  : _b__op_name <= op_alt ? "SUB " : "ADD ";
            INT_FUNC3_SLL  : _b__op_name <= "SLL ";
            INT_FUNC3_SLT  : _b__op_name <= "SLT ";
            INT_FUNC3_SLTU : _b__op_name <= "SLTU";
            INT_FUNC3_XOR  : _b__op_name <= "XOR ";
            INT_FUNC3_SRX  : _b__op_name <= b[10] ? "SRA " : "SRL ";
            INT_FUNC3_OR   : _b__op_name <= "OR  ";
            INT_FUNC3_AND  : _b__op_name <= "AND ";
        endcase
    end
    `endif

    always @(posedge clk) begin
        if (!n_rst) begin
            out <= 0;
        end else begin
            case (op)
                INT_FUNC3_ADD:  out <= a + (op_alt ? -b : b);
                INT_FUNC3_SLL:  out <= a << b[4:0];
                INT_FUNC3_SLT:  out <= $signed(a) < $signed(b) ? 1 : 0;
                INT_FUNC3_SLTU: out <= a < b ? 1 : 0;
                INT_FUNC3_XOR:  out <= a ^ b;
                INT_FUNC3_SRX: begin
                    if (b[10]) begin
                        out <= $signed(a) >>> b[4:0];
                    end else begin
                        out <= a >> b[4:0];
                    end
                end
                INT_FUNC3_OR:   out <= a | b;
                INT_FUNC3_AND:  out <= a & b;
            endcase
        end
    end

endmodule
