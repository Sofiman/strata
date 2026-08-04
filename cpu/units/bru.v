module bru (
    input             n_rst,
    input             clk,

    input             up_valid,
    output            up_ready,
    output reg        dw_valid,
    input             dw_ready,

    input      [ 3:0] up_op,
    input      [31:0] up_addr,
    input      [31:0] up_rf_a,
    input      [31:0] up_rf_b,

    output            dw_pc_write_en,
    output     [31:0] dw_pc_next
);

    `include "cfg/rv_isa_opcode.v"

    (* always_ff *)
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            dw_valid <= 1'b0;
        end else if (dw_ready)
            dw_valid <= up_valid;
    end

    reg branch_taken;

    always @(posedge clk) begin
        if (up_valid & dw_ready) begin
            branch_taken <= 1'b0;
            case (up_op[2:0])
                BRANCH_FUNCT3_BEQ:  branch_taken <= up_rf_a == up_rf_b;
                BRANCH_FUNCT3_BNE:  branch_taken <= up_rf_a != up_rf_b;
                BRANCH_FUNCT3_BLT:  branch_taken <= $signed(up_rf_a) < $signed(up_rf_b);
                BRANCH_FUNCT3_BGE:  branch_taken <= $signed(up_rf_a) >= $signed(up_rf_b);
                BRANCH_FUNCT3_BLTU: branch_taken <= up_rf_a < up_rf_b;
                BRANCH_FUNCT3_BGEU: branch_taken <= up_rf_a >= up_rf_b;
                default: begin
                    // TODO: Illegal instruction
                end
            endcase
        end
    end

    assign up_ready = dw_ready;
    assign dw_pc_next = up_addr;
    assign dw_pc_write_en = dw_valid & branch_taken;

endmodule
