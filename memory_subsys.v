module memory_subsys (
    input n_rst,
    input clk,

    input  [31:0] porta_addr,
    input         porta_read_enable,
    output reg [31:0] porta_read_data,
    output reg    porta_read_valid,
    input         porta_write_enable,
    input  [31:0] porta_write_data,

    output reg       fault,

    output reg [5:0] leds
);

    wire [31:0] ram_data;

    wire ram_en = porta_addr[31]; // 0x80000000
    wire leds_en = porta_addr[30]; // 0x40000000

    always @(*) begin
        fault <= 1'b1;
        porta_read_valid <= 0;
        porta_read_data  <= 0;
        if (ram_en) begin
            fault <= 1'b0;
            porta_read_valid <= 1'b1;
            porta_read_data  <= ram_data;
        end
        if (leds_en) fault <= 1'b0;
    end

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            leds <= 0;
        end else begin
            if (leds_en & porta_write_enable)
                leds <= porta_write_data;
        end
    end

    ram ram (
        .n_rst(n_rst),
        .clk(clk),
        .read_enable(ram_en & porta_read_enable),
        .write_enable(ram_en & porta_write_enable),
        .wr_data(porta_write_data),
        .addr(porta_addr[10:2]),
        .data(ram_data)
    );

endmodule
