module decoder (
    input [31:0] inst,

    output reg [2:0] fmt,

    output [6:0] funct7,
    output [4:0] rs2,
    output [4:0] rs1,
    output [2:0] funct3,
    output [4:0] rd,
    output [6:0] opcode,

    output reg [31:0] i_imm,
    output reg [31:0] sb_imm,
    output reg [31:0] uj_imm
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
            OP      : fmt = R_TYPE;
            /*
            AMO     : fmt = R_TYPE;
            OP_FP   : fmt = R_TYPE;
            FMADD   : fmt = R_TYPE;
            FMSUB   : fmt = R_TYPE;
            FNMSUB  : fmt = R_TYPE;
            FNMADD  : fmt = R_TYPE;
            */

            OP_IMM  : fmt = I_TYPE;
            JALR    : fmt = I_TYPE;
            LOAD    : fmt = I_TYPE;
            MISC_MEM: fmt = I_TYPE;
            SYSTEM  : fmt = I_TYPE;
            //LOAD_FP : fmt = I_TYPE;

            STORE   : fmt = S_TYPE;
            //STORE_FP: fmt = S_TYPE;

            BRANCH  : fmt = B_TYPE;

            AUIPC   : fmt = U_TYPE;
            LUI     : fmt = U_TYPE;

            JAL     : fmt = J_TYPE;
            default : fmt = R_TYPE;
        endcase

        /*
        * === decoder ===

            Number of wires:                119
            Number of wire bits:            378
            Number of public wires:         119
            Number of public wire bits:     378
            Number of ports:                 11
            Number of port bits:            166
            Number of memories:               0
            Number of memory bits:            0
            Number of processes:              0
            Number of cells:                273
            GND                             1
            IBUF                           32
            LUT1                           38
            LUT3                            1
            LUT4                           22
            MUX2_LUT5                      30
            MUX2_LUT6                      14
            MUX2_LUT7                       1
            OBUF                          134

        */
        sb_imm[31:11] <= {21{inst[31]}};
        sb_imm[10:5]  <= inst[30:25];
        sb_imm[4:1]   <= inst[11:8];
        if (fmt == B_TYPE) begin
            sb_imm[0] <= 0;
            sb_imm[11] <= inst[7];
        end else begin
            sb_imm[0] <= inst[7];
        end

        i_imm[31:11] <= {21{inst[31]}};
        i_imm[10:5]  <= inst[30:25];
        i_imm[4:1]   <= inst[24:21];
        i_imm[0]     <= inst[20];

        uj_imm[31] <= inst[31];
        uj_imm[19:12] <= inst[19:12];
        uj_imm[0] <= 0;
        if (fmt == U_TYPE) begin
            uj_imm[30:20] <= inst[30:20];
            uj_imm[11:1] <= 0;
        end else begin
            uj_imm[30:20] <= {12{inst[31]}};
            uj_imm[11] <= inst[20];
            uj_imm[10:5] <= inst[30:25];
            uj_imm[4:1] <= inst[24:21];
        end

        /* See `Chapter 35. RV32/64G Instruction Set Listings` (pages 608 to 619) */
        /* 
         === decoder ===

       Number of wires:                420
       Number of wire bits:            708
       Number of public wires:         420
       Number of public wire bits:     708
       Number of ports:                  9
       Number of port bits:            102
       Number of memories:               0
       Number of memory bits:            0
       Number of processes:              0
       Number of cells:                519
         GND                             1
         IBUF                           32
         LUT1                           94
         LUT2                           13
         LUT3                           42
         LUT4                           76
         MUX2_LUT5                     112
         MUX2_LUT6                      52
         MUX2_LUT7                      26
         MUX2_LUT8                       1
         OBUF                           70
        */
       /*
        imm[10:5] <= inst[30:25];
        imm[19:12] <= inst[19:12];
        imm[31] <= inst[31];
        case (fmt)
            I_TYPE: begin
                imm[0] <= inst[20];
                imm[4:1] <= inst[24:21];
                imm[30:11] <= {19{inst[31]}};
            end
            S_TYPE: begin
                imm[0] <= inst[7];
                imm[4:1] <= inst[11:8];
                imm[30:11] <= {19{inst[31]}};
            end
            B_TYPE: begin
                imm[0] <= 0;
                imm[4:1] <= inst[11:8];
                imm[11] <= inst[7];
                imm[30:12] <= {18{inst[31]}};
            end
            U_TYPE: begin
                imm[11:0] <= {12{0}};
                imm[30:20] <= inst[30:20];
            end
            J_TYPE: begin
                imm[0] <= 0;
                imm[4:1] <= inst[24:21];
                imm[11] <= inst[20];
                imm[30:20] <= {11{inst[31]}};
            end
            default: begin
                imm[0] <= 0;
                imm[4:1] <= 0;
                imm[11] <= 0;
                imm[30:20] <= 0;
            end
        endcase
        */
    end

endmodule
