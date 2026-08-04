module ifetch (
    input             n_rst,
    input             clk,

    input             up_addr_write_enable,
    input [31:0]      up_addr,
    output            up_ready,
    input             up_valid,

    output reg        dw_valid,
    input             dw_ready,
    output reg [31:0] dw_pc,
    output reg [31:0] dw_inst
);

    wire [31:0] inst_next;
    //reg  [31:0] retired_inst_pc;
`ifdef DELAYED_FETCH
    reg         clk_enable;
`else
    wire        clk_enable;
`endif

    rom inst_mem (
        .n_rst(n_rst),
        .clk(clk),
        .read_enable(clk_enable),
        .addr(dw_pc[10:2]),
        .data(inst_next)
    );

   localparam RV32_NOP = 32'h13;

`ifdef DELAYED_FETCH
    reg  [1:0]  timeout;
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            dw_valid <= 1'b0;
            clk_enable <= 1'b0;

            dw_pc <= 32'h40000000;
            dw_inst <= 'h0 /* RV32_NOP */;
        end else if (clk_enable) begin
            if (timeout == 2'b00) begin
                // begin of Compute
                retired_inst_pc <= dw_pc;
                dw_inst         <= inst_next;
                // end of Compute

                // begin of Control flow
                dw_valid   <= 1'b1;
                clk_enable <= 1'b0;
                // end of Control flow
            end else begin
                timeout <= timeout - 1;
            end
        end else if (dw_ready) begin
             dw_valid <= 1'b0;
             if (up_valid) begin
                 clk_enable <= 1'b1;

                 // Init compute
                 if (up_addr_write_enable) dw_pc <= up_addr;
                 timeout <= 2'b01; // 3 cycles
             end
        end
    end

    assign up_ready = dw_ready & !clk_enable;
`else
    assign clk_enable = 1'b1;

    reg dw_valid_delay;
    reg  [1:0]  timeout;
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            dw_valid <= 1'b0;
            dw_valid_delay <= 1'b0;

            dw_pc <= 32'h40000000;
            dw_inst <= 'h0 /* RV32_NOP */;
        end else if (dw_ready) begin
             dw_valid <= 1'b0;
             dw_valid_delay <= 1'b0;
             if (up_valid) begin
                 dw_valid_delay <= 1'b1;

                 //retired_inst_pc <= dw_pc;
                 dw_inst         <= inst_next;
                 dw_valid        <= dw_valid_delay;

                 if (up_addr_write_enable) begin
                     dw_pc <= up_addr - 4;
                     //dw_valid_delay <= 1'b0;
                     dw_valid <= 1'b0;
                 end else if (dw_valid_delay) begin
                     dw_pc <= dw_pc + 4;
                 end
             end
        end
    end

    assign up_ready = dw_ready;
`endif

endmodule
