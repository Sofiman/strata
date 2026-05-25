localparam OPCODE_LOAD     = 5'b00_000;
localparam OPCODE_STORE    = 5'b01_000;
localparam OPCODE_FMADD    = 5'b10_000;
localparam OPCODE_BRANCH   = 5'b11_000;

localparam OPCODE_LOAD_FP  = 5'b00_001;
localparam OPCODE_STORE_FP = 5'b01_001;
localparam OPCODE_FMSUB    = 5'b10_001;
localparam OPCODE_JALR     = 5'b11_001;

localparam OPCODE_FNMSUB   = 5'b10_010;

localparam OPCODE_MISC_MEM = 5'b00_011;
localparam OPCODE_AMO      = 5'b01_011;
localparam OPCODE_FNMADD   = 5'b10_011;
localparam OPCODE_JAL      = 5'b11_011;

localparam OPCODE_OP_IMM   = 5'b00_100;
localparam OPCODE_OP       = 5'b01_100;
localparam OPCODE_OP_FP    = 5'b10_100;
localparam OPCODE_SYSTEM   = 5'b11_100;

localparam OPCODE_AUIPC    = 5'b00_101;
localparam OPCODE_LUI      = 5'b01_101;

// Custom
localparam R_TYPE = 0;
localparam I_TYPE = 1;
localparam S_TYPE = 2;
localparam B_TYPE = 3;
localparam U_TYPE = 4;
localparam J_TYPE = 5;

localparam INT_FUNC3_ADD  = 3'b000;
localparam INT_FUNC3_SLL  = 3'b001;
localparam INT_FUNC3_SLT  = 3'b010;
localparam INT_FUNC3_SLTU = 3'b011;
localparam INT_FUNC3_XOR  = 3'b100;
localparam INT_FUNC3_SRX  = 3'b101;
localparam INT_FUNC3_OR   = 3'b110;
localparam INT_FUNC3_AND  = 3'b111;

localparam BRANCH_FUNCT3_BEQ  = 3'b000;
localparam BRANCH_FUNCT3_BNE  = 3'b001;
localparam BRANCH_FUNCT3_BLT  = 3'b100;
localparam BRANCH_FUNCT3_BGE  = 3'b101;
localparam BRANCH_FUNCT3_BLTU = 3'b110;
localparam BRANCH_FUNCT3_BGEU = 3'b111;

localparam LOAD_BYTE              = 3'b000;
localparam LOAD_HALFWORD          = 3'b001;
localparam LOAD_WORD              = 3'b010;
localparam LOAD_BYTE_UNSIGNED     = 3'b100;
localparam LOAD_HALFWORD_UNSIGNED = 3'b101;
