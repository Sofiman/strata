module ifetch (
    input             n_rst,
    input             clk,
    input             addr_write_enable,
    input [31:0]      addr,

    output reg [31:0] pc,
    output     [31:0] inst,
    output reg        ready
);

    reg [31:0] retired_inst_pc;

    rom inst_mem (
        .n_rst(n_rst),
        .clk(clk),
        .read_enable(!ready),
        .addr(pc[10:2]),
        .data(inst)
    );

    (* always_ff *)
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            ready <= 0;
            pc <= 32'h40000000;
            retired_inst_pc <= 0;
        end else begin
            if (addr_write_enable) begin
                pc <= addr;
                ready <= 0;
            end else begin
                retired_inst_pc <= pc;
                ready <= 1;
            end
        end
    end


endmodule
