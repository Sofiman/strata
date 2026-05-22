module memory_subsys (
    input rst,
    input clk,

    input  [31:0] porta_addr,
    input         porta_read_enable,
    output reg [31:0] porta_read_data,
    output reg    porta_read_valid,
    input         porta_write_enable,
    input  [31:0] porta_write_data,

    output reg       fault
);

    wire ram_en;
    wire [31:0] ram_data;

    wire rom_en;
    wire [31:0] rom_data;

    assign ram_en = porta_addr[31]; // 0x80000000
    assign rom_en = porta_addr[30]; // 0x40000000

    always @(*) begin
        fault <= 'b1;
        if (rom_en) begin
            fault <= porta_write_enable;
            porta_read_valid <= 'b1;
            porta_read_data  <= rom_data;
        end
        if (ram_en) begin
            fault <= 'b0;
            porta_read_valid <= 'b1;
            porta_read_data  <= ram_data;
        end
    end

    ram ram (
        .rst(rst),
        .clk(clk),
        .read_enable(ram_en & porta_read_enable),
        .write_enable(ram_en & porta_write_enable),
        .wr_data(porta_write_data),
        .addr(porta_addr[10:2]),
        .data(ram_data)
    );

    rom inst_mem (
        .rst(rst),
        .clk(clk),
        .read_enable(rom_en & porta_read_enable),
        .addr(porta_addr[10:2]),
        .data(rom_data)
    );

endmodule
