localparam LOAD     = 5'b00_000;
localparam STORE    = 5'b01_000;
localparam FMADD    = 5'b10_000;
localparam BRANCH   = 5'b11_000;

localparam LOAD_FP  = 5'b00_001;
localparam STORE_FP = 5'b01_001;
localparam FMSUB    = 5'b10_001;
localparam JALR     = 5'b11_001;

localparam FNMSUB   = 5'b10_010;

localparam MISC_MEM = 5'b00_011;
localparam AMO      = 5'b01_011;
localparam FNMADD   = 5'b10_011;
localparam JAL      = 5'b11_011;

localparam OP_IMM   = 5'b00_100;
localparam OP       = 5'b01_100;
localparam OP_FP    = 5'b10_100;
localparam SYSTEM   = 5'b11_100;

localparam AUIPC    = 5'b00_101;
localparam LUI      = 5'b01_101;

// Custom
localparam R_TYPE = 0;
localparam I_TYPE = 1;
localparam S_TYPE = 2;
localparam B_TYPE = 3;
localparam U_TYPE = 4;
localparam J_TYPE = 5;
