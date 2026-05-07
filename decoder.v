module decoder (
    input [31:0] inst,

    output reg [2:0] fmt,

    output [6:0] funct7,
    output [4:0] rs2,
    output [4:0] rs1,
    output [2:0] funct3,
    output [4:0] rd,
    output [6:0] opcode,

    output reg [31:0] is_imm,
    output reg [31:0] bj_imm,
    output reg [31:0] u_imm
);

    assign funct7 = inst[31:25];
    assign rs2    = inst[24:20];
    assign rs1    = inst[19:15];
    assign funct3 = inst[14:12];
    assign rd     = inst[11:7];
    assign opcode = inst[6:0];

    `include "cfg/rv_isa_opcode.v"

    `ifdef BENCH
    reg [47:0] _b__fmt_name;
    reg [63:0] _b__opcode_name;
    always @(*) begin
        case (fmt)
            R_TYPE: _b__fmt_name <= "R_TYPE";
            I_TYPE: _b__fmt_name <= "I_TYPE";
            S_TYPE: _b__fmt_name <= "S_TYPE";
            B_TYPE: _b__fmt_name <= "B_TYPE";
            U_TYPE: _b__fmt_name <= "U_TYPE";
            J_TYPE: _b__fmt_name <= "J_TYPE";
        endcase

        case (opcode[6:2])
            OP      : _b__opcode_name <= "OP      ";
            AMO     : _b__opcode_name <= "AMO     ";
            OP_FP   : _b__opcode_name <= "OP_FP   ";
            FMADD   : _b__opcode_name <= "FMADD   ";
            FMSUB   : _b__opcode_name <= "FMSUB   ";
            FNMSUB  : _b__opcode_name <= "FNMSUB  ";
            FNMADD  : _b__opcode_name <= "FNMADD  ";
            OP_IMM  : _b__opcode_name <= "OP_IMM  ";
            JALR    : _b__opcode_name <= "JALR    ";
            LOAD    : _b__opcode_name <= "LOAD    ";
            MISC_MEM: _b__opcode_name <= "MISC_MEM";
            SYSTEM  : _b__opcode_name <= "SYSTEM  ";
            LOAD_FP : _b__opcode_name <= "LOAD_FP ";
            STORE   : _b__opcode_name <= "STORE   ";
            STORE_FP: _b__opcode_name <= "STORE_FP";
            BRANCH  : _b__opcode_name <= "BRANCH  ";
            AUIPC   : _b__opcode_name <= "AUIPC   ";
            LUI     : _b__opcode_name <= "LUI     ";
            JAL     : _b__opcode_name <= "JAL     ";
        endcase
    end
    `endif

    always @(*) begin
        case (opcode[6:2])
            OP      : fmt <= R_TYPE;
            AMO     : fmt <= R_TYPE;
            OP_FP   : fmt <= R_TYPE;
            FMADD   : fmt <= R_TYPE;
            FMSUB   : fmt <= R_TYPE;
            FNMSUB  : fmt <= R_TYPE;
            FNMADD  : fmt <= R_TYPE;

            OP_IMM  : fmt <= I_TYPE;
            JALR    : fmt <= I_TYPE;
            LOAD    : fmt <= I_TYPE;
            MISC_MEM: fmt <= I_TYPE;
            SYSTEM  : fmt <= I_TYPE;
            LOAD_FP : fmt <= I_TYPE;

            STORE   : fmt <= S_TYPE;
            STORE_FP: fmt <= S_TYPE;

            BRANCH  : fmt <= B_TYPE;

            AUIPC   : fmt <= U_TYPE;
            LUI     : fmt <= U_TYPE;

            JAL     : fmt <= J_TYPE;
            default : fmt <= R_TYPE;
        endcase

    end

    always @(*) begin
        is_imm <= {{20{inst[31]}}, inst[31:25], fmt == I_TYPE ? inst[24:20] : inst[11:7]};
        u_imm <= {inst[31:12], 12'b0};

        if (fmt == B_TYPE) begin
            bj_imm <= {{19{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        end else begin
            bj_imm <= {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
        end
    end

endmodule
