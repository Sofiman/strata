module memory_subsys (
    input n_rst,
    input clk,

    input      [31:0] addr,
    input      [3:0]  write_enable,
    input      [31:0] write_data,
    output reg [31:0] read_data,

    input            i_valid,
    input            i_busy,
    output reg       o_valid,
    output reg       o_busy,
    output reg       fault,

    output reg [5:0] leds
);

    wire [31:0] ram_data;
    wire        ram_o_valid;
    wire        ram_o_busy;

    wire leds_o_valid = i_valid;
    wire leds_o_busy = 1'b0;

    wire ram_sel = addr[31]; // 0x80000000
    wire leds_sel = addr[30]; // 0x40000000

    (* always_comb *)
    always @(*) begin
        // Arbitrer, priority encoder
        casez ({ram_sel, leds_sel})
            'b1?: {fault, o_valid, o_busy, read_data} <= {1'b0,  ram_o_valid,  ram_o_busy, ram_data};
            'b01: {fault, o_valid, o_busy, read_data} <= {1'b0, leds_o_valid, leds_o_busy, 32'bxxxxxxxx};
            default: begin
                o_valid <= 1'b0;
                o_busy  <= 1'b0;
                fault   <= 1'b1;
                read_data  <= 32'bxxxxxxxx;
            end
        endcase
    end

    wire leds_en = i_valid & leds_sel;

    (* always_ff *)
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            leds <= 0;
        end else begin
            if (leds_en & write_enable[0])
                leds <= write_data[7:0];
        end
    end

    wire ram_en = i_valid & ram_sel;

    ram ram (
        .n_rst(n_rst),
        .clk(clk),

        .addr(addr[10:2]),
        .write_enable(write_enable),
        .write_data(write_data),
        .read_data(ram_data),

        .i_busy(i_busy),
        .i_valid(ram_en),
        .o_busy(ram_o_busy),
        .o_valid(ram_o_valid)
    );

endmodule
