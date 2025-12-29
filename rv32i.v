module rv32i (
    input rst,
    input clk,

    input key,
    output reg [5:0] leds
);

    // ROM
    wire data_valid_next;
    reg data_valid;

    // Fetch
    reg [31:0] pc;
    reg [31:0] pc_next;
    reg [31:0] pc_to_load;
    reg [31:0] inst;
    wire [31:0] inst_next;

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
    wire [31:0] i_imm;
    wire [31:0] sb_imm;
    wire [31:0] uj_imm;

    rom inst_mem (
        .rst(rst),
        .clk(clk),
        .addr(pc_to_load),
        .data(inst_next),
        .data_valid(data_valid_next)
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

        .i_imm(i_imm),
        .sb_imm(sb_imm),
        .uj_imm(uj_imm)
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
    localparam STATE_BITS = $clog2(S_EXECUTE + 1);
    reg [STATE_BITS-1:0] state;
    reg [STATE_BITS-1:0] state_next;

    `ifdef BENCH
    reg [127:0] _b__state_name;
    always @(*) begin
        case (state)
            S_FETCH_DECODE: _b__state_name <= "S_FETCH_DECODE";
            S_EXECUTE     : _b__state_name <= "S_EXECUTE";
        endcase
    end
    `endif

    `include "cfg/rv_isa_opcode.v"

    always @(*) begin
        pc_next <= pc;
        wr__en <= 0;

        alu_op <= funct3;
        alu_op_alt <= 0;
        alu_a <= rf_a;
        alu_b <= rf_b;
        case (opcode[6:2])
            OP: alu_op_alt <= funct7[5]; // 0x20 -- SUB/SRA
            OP_IMM: alu_op_alt <= funct3 == 0 ? 0 : i_imm[10]; // 0x20 -- SLLI/SRLI/SRAI
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
            default: begin
                // TODO
            end
        endcase

        case (inst_fmt)
            R_TYPE: alu_b <= rf_b;
            I_TYPE: alu_b <= i_imm;
            S_TYPE: alu_b <= sb_imm;
            U_TYPE: alu_b <= uj_imm;
            default: begin
                // TODO: B, J
            end
        endcase

        state_next <= state;
        pc_to_load <= pc;
        case (state)
            S_FETCH_DECODE: begin
                if (data_valid) begin
                    state_next <= S_EXECUTE;
                    pc_to_load <= pc + 1;
                end
            end
            S_EXECUTE: begin
                state_next <= S_FETCH_DECODE;
                pc_next <= pc + 1;
                pc_to_load <= pc + 1;

                case (inst_fmt)
                    R_TYPE, I_TYPE, U_TYPE: wr__en <= 1;
                    default: wr__en <= 0;
                endcase
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_FETCH_DECODE;
            pc <= 32'h40000000;
            leds <= 0;
            inst <= 'h13;
        end else begin
            state <= state_next;
            pc <= pc_next;
            inst <= inst_next;
            data_valid <= data_valid_next;

            leds[0] <= ^alu_out;
        end
    end

endmodule
