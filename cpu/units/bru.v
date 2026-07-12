module bru (
    input n_rst,
    input clk,

    input i_valid,

    input [3:0] op,
    input [31:0] addr,
    input [31:0] rf_a,
    input [31:0] rf_b,
    input [31:0] pc,

    output [31:0] pc_next
);

    `include "cfg/rv_isa_opcode.v"

    reg branch_taken;

    (* always_comb *)
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            branch_taken <= 0;
        end else if (i_valid) begin
            branch_taken <= 0;
            case (op[2:0])
                BRANCH_FUNCT3_BEQ:  branch_taken <= rf_a == rf_b;
                BRANCH_FUNCT3_BNE:  branch_taken <= rf_a != rf_b;
                BRANCH_FUNCT3_BLT:  branch_taken <= $signed(rf_a) < $signed(rf_b);
                BRANCH_FUNCT3_BGE:  branch_taken <= $signed(rf_a) >= $signed(rf_b);
                BRANCH_FUNCT3_BLTU: branch_taken <= rf_a < rf_b;
                BRANCH_FUNCT3_BGEU: branch_taken <= rf_a >= rf_b;
                default: begin
                    // TODO: Illegal instruction
                end
            endcase
        end
    end

    assign pc_next = i_valid & (branch_taken | !op[3]) ? addr : (pc + 4);

endmodule
