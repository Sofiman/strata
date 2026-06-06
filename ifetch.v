module ifetch (
    input             n_rst,
    input             clk,

    input             addr_write_enable,
    input [31:0]      addr,

    output reg [31:0] pc,
    output reg [31:0] inst,

    input      i_busy,
    input      i_valid,
    output     o_busy,
    output reg o_valid
);

    reg [31:0] retired_inst_pc;

    reg clk_enable;
    reg [1:0] timeout;

    wire [31:0] inst_next;

    rom inst_mem (
        .n_rst(n_rst),
        .clk(clk),
        .read_enable(clk_enable),
        .addr(pc[10:2]),
        .data(inst_next)
    );

    reg r_busy;
    assign o_busy = (r_busy) && (!o_valid || i_busy);

    (* always_ff *)
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            r_busy  <= 1'b0;
            o_valid <= 1'b0;
            clk_enable <= 1'b0;

            pc <= 32'h40000000;
            inst <= 32'h0;
            retired_inst_pc <= 0;
        end else if (!o_busy) begin
            o_valid <= 1'b0;
            if (i_valid) begin // An incoming transaction has just taken place
                r_busy <= 1'b1;
                // begin your logic here ...
                if (addr_write_enable)
                    pc <= addr;
                clk_enable <= 1'b1;
                timeout <= 2'b01; // 3 cycles
            end
        end else if (o_valid && !i_busy) begin
            // Data was consumed and no new data is available
            r_busy <= 1'b0;
            o_valid  <= 1'b0;
        end else if (!o_valid) begin
            // o_busy is true, so you can perform any necessary logic here
            if (clk_enable) begin
                if (timeout == 2'b00) begin
            r_busy <= 1'b0;
                    o_valid <= 1'b1;
                    clk_enable <= 1'b0;
                    retired_inst_pc <= pc;
                    inst <= inst_next;
                end else
                    timeout <= timeout - 1;
            end
        end
    end

endmodule
