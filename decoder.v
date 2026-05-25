module decoder (
    input clk,
    input n_rst,

    input [31:0]   pc,
    input [31:0] inst,

    output reg        fault,

    output reg        alu_en,
    output reg        mem_en,
    output reg        bru_en,
    output reg [ 3:0] op,
    output reg [31:0] op_a,
    output reg [31:0] op_b,

    output     [ 4:0] rf_addr_out,
    output     [ 4:0] rf_addr_a,
    input      [31:0] rf_a,
    output     [ 4:0] rf_addr_b,
    input      [31:0] rf_b
);

    `include "cfg/rv_isa_opcode.v"

    wire [6:0] funct7 = inst[31:25];
    wire [4:0] rs2    = inst[24:20];
    wire [4:0] rs1    = inst[19:15];
    wire [2:0] funct3 = inst[14:12];
    wire [4:0] rd     = inst[11:7];
    wire [6:0] opcode = inst[6:0];

    assign rf_addr_a   = rs1;
    assign rf_addr_b   = rs2;
    assign rf_addr_out = rd;

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
`define BRANCH(B)     {3'b001, pc, {             1'b1,        funct3}, B}
`define JMP(A, B)     {3'b101,  A, {/* bypass */ 1'b0, INT_FUNC3_ADD}, B}
`define NO_OP         'b0

    (* always_ff *)
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            {alu_en, mem_en, bru_en, op_a, op, op_b} <= 0;
            fault <= 0;
        end else begin
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
                OPCODE_AUIPC   : {alu_en, mem_en, bru_en, op_a, op, op_b} <= `ALU(   pc, {    1'b0, INT_FUNC3_ADD}, u_imm);
                OPCODE_LUI     : {alu_en, mem_en, bru_en, op_a, op, op_b} <= `ALU(32'h0, {    1'b0, INT_FUNC3_ADD}, u_imm);

                // J_TYPE
                OPCODE_JAL     : {alu_en, mem_en, bru_en, op_a, op, op_b} <= `JMP(pc, j_imm);

                default        : begin
                    // NOTE: ebreak and ecall will end up in this block
                    {alu_en, mem_en, bru_en, op_a, op, op_b} <= {3'b000, 68'bx};
                    fault <= 1;
                end
            endcase
        end
    end

endmodule
