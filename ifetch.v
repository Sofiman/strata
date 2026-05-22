module ifetch (
    input             n_rst,
    input             clk,
    input             addr_write_enable,
    input [31:0]      addr,

    output reg [31:0] pc,
    output     [31:0] inst,
    output reg        inst_valid
);

    reg [31:0] retired_inst_pc;

    rom inst_mem (
        .n_rst(n_rst),
        .clk(clk),
        .read_enable(!inst_valid),
        .addr(pc[10:2]),
        .data(inst)
    );

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            inst_valid <= 0;
            pc <= 32'h40000000;
            retired_inst_pc <= 0;
        end else begin
            if (addr_write_enable) begin
                pc <= addr;
                inst_valid <= 0;
            end else begin
                retired_inst_pc <= pc;
                inst_valid <= 1;
            end
        end
    end


endmodule
