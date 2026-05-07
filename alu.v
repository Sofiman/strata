module alu (
    input clk,
    input rst,
    input [2:0] op,
    input       op_alt,

    input [31:0] a,
    input [31:0] b,
    output reg [31:0] out
);

    localparam OP_ADD  = 0;
    localparam OP_SLL  = 1;
    localparam OP_SLT  = 2;
    localparam OP_SLTU = 3;
    localparam OP_XOR  = 4;
    localparam OP_SRL  = 5;
    localparam OP_OR   = 6;
    localparam OP_AND  = 7;

    `ifdef BENCH
    reg [31:0] _b__op_name;
    always @(*) begin
        case (op)
            OP_ADD : _b__op_name <= "OP_ADD ";
            OP_SLL : _b__op_name <= "OP_SLL ";
            OP_SLT : _b__op_name <= "OP_SLT ";
            OP_SLTU: _b__op_name <= "OP_SLTU";
            OP_XOR : _b__op_name <= "OP_XOR ";
            OP_SRL : _b__op_name <= "OP_SRL ";
            OP_OR  : _b__op_name <= "OP_OR  ";
            OP_AND : _b__op_name <= "OP_AND ";
        endcase
    end
    `endif

    reg [31:0] tmp_out;

    always @(*) begin
        case (op)
            OP_SLL: begin
                tmp_out <= a << b[4:0];
            end
            OP_SLTU: begin
                tmp_out <= a < b ? 1 : 0;
            end
            OP_SLT: begin
                tmp_out <= $signed(a) < $signed(b) ? 1 : 0;
            end
            OP_SRL: begin
                if (b[10]) begin
                    tmp_out <= $signed(a) >>> b[4:0];
                end else begin
                    tmp_out <= a >> b[4:0];
                end
            end
            OP_ADD: begin
                // TODO: This IF has a big impact on fmax
                if (op_alt) begin
                    tmp_out <= a - b;
                end else begin
                    tmp_out <= a + b;
                end
            end
            OP_XOR: begin
                tmp_out <= a ^ b;
            end
            OP_OR: begin
                tmp_out <= a | b;
            end
            OP_AND: begin
                tmp_out <= a & b;
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 0;
        end else begin
            out <= tmp_out;
        end
    end

endmodule
