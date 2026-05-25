module rv32i (
    input rst,
    input clk,

    input key,
    output [5:0] leds
);

    wire n_rst = !rst;

    // Memory Subsystem
    wire [31:0] mss_read_data;
    wire mss_read_valid;

    // Fetch
    reg [31:0]  pc_next;
    wire [31:0] pc;
    wire [31:0] inst;
    wire        inst_valid;

    // ALU
    (* keep *) wire [31:0] alu_out;

    // Register File
    wire       rf_wr_en;
    wire [4:0] rf_addr_a;
    wire [4:0] rf_addr_b;
    wire [4:0] rf_addr_out;
    wire [31:0] rf_a;
    wire [31:0] rf_b;
    wire [31:0] rf_wr_data;

    // Decoder
    wire alu_en;
    wire mem_en;
    wire bru_en;
    wire [3:0]  op;
    wire [31:0] op_a;
    wire [31:0] op_b;
    wire [31:0] op_addr = op_a + $signed(op_b);

    localparam S_FETCH_STALL  = 0;
    localparam S_FETCH_DECODE = 1;
    localparam S_EXECUTE      = 2;
    localparam S_WRITEBACK    = 3;
    localparam STATE_BITS = $clog2(S_WRITEBACK + 1);
    reg [1:0] state;
    reg [1:0] state_next;
    wire pc_next_write_enable = state_next == S_WRITEBACK;

    decoder decoder (
        .clk(clk),
        .n_rst(n_rst),

        .pc(pc),
        .inst(inst),

        .fault(),

        .alu_en(alu_en),
        .mem_en(mem_en),
        .bru_en(bru_en),

        .op(op),
        .op_a(op_a),
        .op_b(op_b),

        .rf_addr_out(rf_addr_out),
        .rf_addr_a(rf_addr_a),
        .rf_a(rf_a),
        .rf_addr_b(rf_addr_b),
        .rf_b(rf_b)
    );

    ifetch u_ifetch (
        .n_rst(n_rst),
        .clk(clk),
        .addr_write_enable(pc_next_write_enable),
        .addr(pc_next),
        .pc(pc),
        .inst(inst),
        .inst_valid(inst_valid)
    );

    memory_subsys memory_subsys (
        .n_rst(n_rst),
        .clk(clk),

        .porta_addr(op_addr),
        .porta_read_enable(mem_en & !op[3]),
        .porta_read_data(mss_read_data),
        .porta_read_valid(mss_read_valid),
        .porta_write_enable(mem_en & op[3]),
        .porta_write_data(0),

        .fault(),

        .leds(leds)
    );

    register_file rf (
        .clk(clk),

        .wr__en(rf_wr_en),
        .wr__data(rf_wr_data),
        .wr__addr(rf_addr_out),

        .porta__addr(rf_addr_a),
        .porta__read_data(rf_a),

        .portb__addr(rf_addr_b),
        .portb__read_data(rf_b)
    );

    alu alu (
        .clk(clk),
        .n_rst(n_rst),
        .op(op[2:0]),
        .op_alt(op[3]),

        .a(bru_en ? pc : op_a),
        .b(bru_en ? 32'h4 : op_b),
        .out(alu_out)
    );

    `ifdef BENCH
    reg [127:0] _b__state_name;
    always @(*) begin
        case (state)
            S_FETCH_STALL : _b__state_name <= "FETCH_STALL";
            S_FETCH_DECODE: _b__state_name <= "FETCH_DECODE";
            S_EXECUTE     : _b__state_name <= "EXECUTE";
            S_WRITEBACK   : _b__state_name <= "WRITEBACK";
        endcase
    end
    `endif

    `include "cfg/rv_isa_opcode.v"

    reg branch_taken;
    always @(posedge clk) begin
        if (bru_en) begin
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

    always @(*) begin
        if (bru_en & (!op[3] | branch_taken)) begin
            pc_next <= op_addr;
        end else begin
            pc_next <= pc + 4;
        end
    end

    wire [31:0] mss_read_data_aligned = mss_read_data >> {op_addr[2:0], 3'b0};
    reg [31:0] mss_data_out;

    always @(*) begin
        case (op[1:0])
            2'b00: mss_data_out <= {{24{mss_read_data_aligned[7] & !op[2]}}, mss_read_data_aligned[7:0]};
            2'b01: mss_data_out <= {{16{mss_read_data_aligned[15] & !op[2]}}, mss_read_data_aligned[15:0]};
            2'b10, 2'b11: mss_data_out <= mss_read_data_aligned;
            // TODO: Illegal instruction: 2'b11
        endcase
    end

    assign rf_wr_en = (state == S_WRITEBACK) & (alu_en | (mem_en & mss_read_valid));
    assign rf_wr_data = alu_en ? alu_out : mss_data_out;

    always @(*) begin
        state_next <= state;
        case (state)
            S_FETCH_DECODE: state_next <= S_EXECUTE;
            S_EXECUTE:      state_next <= S_WRITEBACK;
            S_WRITEBACK:    state_next <= bru_en ? S_FETCH_STALL : S_FETCH_DECODE;
            S_FETCH_STALL:  if (inst_valid) state_next <= S_FETCH_DECODE;
        endcase
    end

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            state <= S_FETCH_STALL;
        end else begin
            state <= state_next;
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
