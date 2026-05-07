module rv32i (
    input rst,
    input clk,

    input key,
    output reg [5:0] leds
);

    // ROM
    wire data_valid;

    // Fetch
    reg [31:0] pc;
    reg [31:0] pc_next;
    reg [31:0] pc_to_load;
    reg [31:0] pc_to_load_next;
    wire [31:0] inst;

    // ALU
    reg [2:0] alu_op;
    reg alu_op_alt;
    reg [31:0] alu_a;
    reg [31:0] alu_b;
    (* keep *) wire [31:0] alu_out;

    // Register File
    reg wr__en;
    wire [31:0] rf_a;
    wire [31:0] rf_b;

    // Decode
    wire [2:0] inst_fmt;
    wire [6:0] funct7;
    wire [4:0] rs2;
    wire [4:0] rs1;
    wire [2:0] funct3;
    wire [4:0] rd;
    wire [6:0] opcode;
    wire [31:0] is_imm;
    wire [31:0] bj_imm;
    wire [31:0] u_imm;

    rom inst_mem (
        .rst(rst),
        .clk(clk),
        .addr(pc_to_load[10:2]),
        .data(inst),
        .data_valid(data_valid)
    );

    register_file rf (
        .clk(clk),

        .wr__en(wr__en),
        .wr__data(alu_out),
        .wr__addr(rd),

        .porta__addr(rs1),
        .porta__read_data(rf_a),

        .portb__addr(rs2),
        .portb__read_data(rf_b)
    );

    decoder dec (
        .inst(inst),

        .fmt(inst_fmt),

        .funct7(funct7),
        .rs2(rs2),
        .rs1(rs1),
        .funct3(funct3),
        .rd(rd),
        .opcode(opcode),

        .is_imm(is_imm),
        .bj_imm(bj_imm),
        .u_imm(u_imm)
    );

    alu alu (
        .clk(clk),
        .rst(rst),
        .op(alu_op),
        .op_alt(alu_op_alt),

        .a(alu_a),
        .b(alu_b),
        .out(alu_out)
    );

    localparam S_FETCH_DECODE = 0;
    localparam S_EXECUTE      = 1;
    localparam S_FETCH_STALL  = 2;
    localparam STATE_BITS = $clog2(S_FETCH_STALL + 1);
    reg [1:0] state;
    reg [1:0] state_next;

    `ifdef BENCH
    reg [127:0] _b__state_name;
    always @(*) begin
        case (state)
            S_FETCH_DECODE: _b__state_name <= "FETCH_DECODE";
            S_EXECUTE     : _b__state_name <= "EXECUTE";
            S_FETCH_STALL : _b__state_name <= "FETCH_STALL";
        endcase
    end
    `endif

    `include "cfg/rv_isa_opcode.v"

    reg branch_taken;
    always @(posedge clk) begin
        branch_taken <= 0;
        case (funct3)
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

    always @(*) begin
        pc_to_load_next <= pc + 4;
        pc_next <= pc;

        wr__en <= 0;

        alu_op <= funct3;
        alu_op_alt <= 0;
        alu_a <= rf_a;
        alu_b <= rf_b;

        case (inst_fmt)
            R_TYPE: alu_b <= rf_b;
            I_TYPE: alu_b <= is_imm;
            S_TYPE: alu_b <= is_imm;
            U_TYPE: alu_b <= u_imm;
            J_TYPE: alu_b <= 4;
            default: begin
                // TODO: B
            end
        endcase

        case (opcode[6:2])
            OP: alu_op_alt <= funct7[5]; // 0x20 -- SUB/SRA
            OP_IMM: alu_op_alt <= funct3 == 0 ? 0 : is_imm[10]; // 0x20 -- SLLI/SRLI/SRAI
            LUI: begin
                // rd =  0 + (imm << 12)
                alu_op <= /* ADD */ 0;
                alu_a <= 0;
            end
            AUIPC: begin
                // rd = PC + (imm << 12)
                alu_op <= /* ADD */ 0;
                alu_a <= pc;
            end
            JAL: begin
                // rd = PC + 4;
                alu_op <= /* ADD */ 0;
                alu_a <= pc;
                alu_b <= 4;
                pc_to_load_next <= pc + bj_imm;
            end
            JALR: begin
                // rd = PC + 4;
                alu_op <= /* ADD */ 0;
                alu_a <= pc;
                alu_b <= 4;
                pc_to_load_next <= rf_a + is_imm; // TODO: Set the LSB to 0 (page 31)
            end
            BRANCH: begin
                if (branch_taken) begin
                    pc_to_load_next <= pc + $signed(bj_imm);
                end
            end
            default: begin
                // TODO
            end
        endcase

        state_next <= state;
        case (state)
            S_FETCH_DECODE: begin
                state_next <= S_EXECUTE;
            end
            S_EXECUTE: begin
                state_next <= S_FETCH_DECODE;
                pc_next <= pc_to_load;

                case (inst_fmt)
                    R_TYPE, I_TYPE, U_TYPE, J_TYPE: wr__en <= 1;
                    B_TYPE: begin
                        state_next <= S_FETCH_STALL;
                    end
                    default: wr__en <= 0;
                endcase
            end
            S_FETCH_STALL: begin
                pc_to_load_next <= pc_to_load;
                pc_next <= pc_to_load;
                if (data_valid) begin
                    state_next <= S_FETCH_DECODE;
                end
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_FETCH_STALL;
            pc <= 32'h40000000;
            pc_to_load <= 32'h40000000;
            leds <= 0;
        end else begin
            state <= state_next;

            pc <= pc_next;
            pc_to_load <= pc_to_load_next;

            leds[0] <= ^alu_out;
        end
    end

endmodule

// TODO: Validation testbenches for regression testing
// TODO: Load/Store unit
// TODO: Attach MMIO UART
// TODO: Interrupt unit
// TODO: Multiply extension
// TODO: Pipelining
// TODO: Simple branch predictor (same-as-before, two-mispredictions-in-a-row) -- Source: https://www.youtube.com/watch?v=mGCClZpjX0g
