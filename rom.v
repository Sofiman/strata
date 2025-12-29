module rom #(
    parameter DEPTH = 1 * /* BSRAM cap */ 16384 / /* bithwidth */ 32, // 16Kb = 1 BRAM
    parameter XLEN = 32
) (
    input clk,
    input rst,
    input [$clog2(DEPTH)-1:0] addr,
    output reg data_valid,
    output reg [XLEN-1:0] data
);

    (* ram_style = "block" *) reg [XLEN-1:0] mem [DEPTH-1:0];

    integer i;
    initial begin
        for (i = 0; i < DEPTH; i++) begin
            mem[i] = 'h13;// nop aka addi x0, x0, 0
        end
        //$readmemh("testprograms/test_i_type.hex", mem, 0, 3);
        //$readmemh("testprograms/test_ir_type.hex", mem, 0, 4);
        //$readmemh("testprograms/test2_ir_type.hex", mem, 0, 5);
        $readmemh("testprograms/test3_ir_type.hex", mem, 0, 6);
        //$readmemh("testprograms/auipc.hex", mem, 0, 2);
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data <= 'h13;
            data_valid <= 0;
        end else begin
            data <= mem[addr];
            data_valid <= 1;
        end
    end

endmodule
