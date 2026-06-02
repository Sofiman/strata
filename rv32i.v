module rv32i (
    input rst,
    input clk,

    input key,
    output [5:0] leds
);

    wire n_rst = !rst;

    // Fetch
    reg [31:0]  pc_next;
    wire [31:0] pc;
    wire [31:0] inst;
    wire        ifetch_ready;

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

    // Load Store Unit
    wire [31:0] mem_out;
    wire mem_busy;
    wire mem_valid;

    localparam S_FETCH_DECODE = 0;
    localparam S_EXECUTE      = 1;
    localparam S_WRITEBACK    = 2;
    localparam STATE_BITS = $clog2(S_WRITEBACK + 1);
    reg [1:0] state;
    reg [1:0] state_next;

    wire execute_ready = 1'b1;
    wire alu_ready = 1'b1;
    wire writeback_ready = mem_en ? (!mem_busy & mem_valid) : alu_ready;

    wire pc_next_write_enable = (state == S_WRITEBACK) & writeback_ready;
    assign rf_wr_en           = (state == S_WRITEBACK) & writeback_ready;
    assign rf_wr_data        = alu_en ? alu_out : mem_out;

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
        .ready(ifetch_ready)
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

    load_store u_load_store (
        .n_rst(n_rst),
        .clk(clk),

        .addr(op_addr),
        .op(op),
        .data_in(rf_b),
        .data_out(mem_out),

        .i_valid(mem_en),
        .o_valid(mem_valid),
        .o_busy(mem_busy),

        .leds(leds)
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
    reg [191:0] _b__state_name;
    always @(*) begin
        case (state)
            S_FETCH_DECODE: _b__state_name <=    ifetch_ready ? "FETCH_DECODE" : "FETCH_DECODE (STALLING)";
            S_EXECUTE     : _b__state_name <=   execute_ready ? "EXECUTE"      : "EXECUTE (STALLING)";
            S_WRITEBACK   : _b__state_name <= writeback_ready ? "WRITEBACK"    : "WRITEBACK (STALLING)";
        endcase
    end
    `endif

    `include "cfg/rv_isa_opcode.v"

    (* always_comb *)
    reg branch_taken;
    always @(*) begin
        branch_taken <= 0;
        if (bru_en) begin
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

    (* always_comb *)
    always @(*) begin
        if (bru_en & (!op[3] | branch_taken)) begin
            pc_next <= op_addr;
        end else begin
            pc_next <= pc + 4;
        end
    end

    (* always_comb *)
    always @(*) begin
        state_next <= state;
        case (state)
            S_FETCH_DECODE: if (ifetch_ready)    state_next <= S_EXECUTE;
            S_EXECUTE:      if (execute_ready)   state_next <= S_WRITEBACK;
            S_WRITEBACK:    if (writeback_ready) state_next <= S_FETCH_DECODE;
        endcase
    end

    (* always_ff *)
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            state <= S_FETCH_DECODE;
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
