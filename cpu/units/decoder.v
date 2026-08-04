module decoder (
    input clk,
    input n_rst,

    input        up_clear,
    input        up_valid,
    output       up_ready,
    input [31:0] up_pc,
    input [31:0] up_inst,

    // Downstream
    output reg        dw_valid,
    input             dw_ready,

    output reg        alu_en,
    output reg        mem_en,
    output reg        bru_en,
    output reg [ 3:0] op,
    output reg [31:0] op_a,
    output reg [31:0] op_b,

    output reg [ 4:0] rf_addr_out,
    output     [ 4:0] rf_addr_a,
    input      [31:0] rf_a,
    output     [ 4:0] rf_addr_b,
    input      [31:0] rf_b
);

    `include "cfg/rv_isa_opcode.v"

    reg fault;
    wire [31:0] inst = up_inst;

    wire [6:0] funct7 = inst[31:25];
    wire [4:0] rs2    = inst[24:20];
    wire [4:0] rs1    = inst[19:15];
    wire [2:0] funct3 = inst[14:12];
    wire [4:0] rd     = inst[11:7];
    wire [6:0] opcode = inst[6:0];

    assign rf_addr_a   = rs1;
    assign rf_addr_b   = rs2;

    reg [31:0] i_imm;
    reg [31:0] s_imm;
    reg [31:0] b_imm;
    reg [31:0] j_imm;
    reg [31:0] u_imm;

    (* always_comb *)
    always @(*) begin
        i_imm <= {{20{inst[31]}}, inst[31:25], inst[24:20]};
        s_imm <= {{20{inst[31]}}, inst[31:25], inst[11:7]};
        u_imm <= {inst[31:12], 12'b0};
        b_imm <= {{19{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        j_imm <= {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
    end

`define ALU(A, OP, B) {3'b100,  A,                                 OP, B}
`define LOAD(A, B)    {3'b010,  A, {  /* load */ 1'b0,        funct3}, B}
`define STORE(A, B)   {3'b010,  A, {             1'b1,        funct3}, B}
`define BRANCH(B)     {3'b001, up_pc, {             1'b1,        funct3}, B}
`define JMP(A, B)     {3'b101,  A, {/* bypass */ 1'b0, INT_FUNC3_ADD}, B}
`define NO_OP         'b0

    reg [4:0] prev_rd;
    (* always_ff *)
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst | up_clear) begin
            prev_rd <= 5'b0;
        end else if (up_valid & dw_ready)
            prev_rd <= rd;
    end

    wire raw = prev_rd != 5'b0 && (prev_rd == rs1 || prev_rd == rs2);

    reg [1:0] raw_stall;

    (* always_ff *)
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst | up_clear) begin
            dw_valid <= 1'b0;
        end else if (up_ready) begin
            dw_valid <= up_valid;
        end else if (raw || raw_stall != 2'b0) begin
            dw_valid <= 1'b0;
        end
    end

    (* always_ff *)
    always @(posedge clk) begin
        if (up_valid & up_ready) begin
            fault <= 0;
            rf_addr_out <= rd;
            case (opcode[6:2])
                // R_TYPE
                OPCODE_OP      : {alu_en, mem_en, bru_en, op_a, op, op_b} <= `ALU(rf_a, {funct7[5],        funct3},  rf_b);
                OPCODE_MISC_MEM: begin
                    // TODO: memory ordering
                    {alu_en, mem_en, bru_en, op_a, op, op_b} <= `NO_OP;
                    fault <= funct3 != /* fence */ 3'b0;
                end

                // I_TYPE
                OPCODE_OP_IMM  : {alu_en, mem_en, bru_en, op_a, op, op_b} <= `ALU(rf_a, {     1'b0,        funct3}, i_imm);
                OPCODE_JALR    : {alu_en, mem_en, bru_en, op_a, op, op_b} <= `JMP(rf_a, i_imm);
                OPCODE_LOAD    : {alu_en, mem_en, bru_en, op_a, op, op_b} <= `LOAD(rf_a, i_imm);

                // S_TYPE
                OPCODE_STORE   : {alu_en, mem_en, bru_en, op_a, op, op_b} <= `STORE(rf_a, s_imm);

                // B_TYPE
                OPCODE_BRANCH  : {alu_en, mem_en, bru_en, op_a, op, op_b} <= `BRANCH(b_imm);

                // U_TYPE
                OPCODE_AUIPC   : {alu_en, mem_en, bru_en, op_a, op, op_b} <= `ALU(up_pc, {    1'b0, INT_FUNC3_ADD}, u_imm);
                OPCODE_LUI     : {alu_en, mem_en, bru_en, op_a, op, op_b} <= `ALU(32'h0, {    1'b0, INT_FUNC3_ADD}, u_imm);

                // J_TYPE
                OPCODE_JAL     : {alu_en, mem_en, bru_en, op_a, op, op_b} <= `JMP(up_pc, j_imm);

                default        : begin
                    // NOTE: ebreak and ecall will end up in this block
                    {alu_en, mem_en, bru_en, op_a, op, op_b} <= {3'b000, 68'bx};
                    fault <= 1;
                end
            endcase
        end
    end

    (* always_ff *)
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst | up_clear) begin
            raw_stall <= 2'b0;
        end else if (up_valid & dw_ready) begin
            if (raw_stall == 2'b0) begin
                if (raw) begin
                    raw_stall <= 2'b10;
                end
            end else begin
                raw_stall <= raw_stall - 1;
            end
        end
    end

    assign up_ready = dw_ready & !(dw_valid & raw & !up_clear) & raw_stall == 2'b0;

endmodule
