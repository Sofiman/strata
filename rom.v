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
        `ifdef ROM_FILE
        $readmemh(`ROM_FILE, mem, 0, DEPTH-1);
        `else
        //$readmemh("testprograms/test_i_type.hex", mem, 0, 3);
        //$readmemh("testprograms/test_ir_type.hex", mem, 0, 4);
        //$readmemh("testprograms/test2_ir_type.hex", mem, 0, 5);
        $readmemh("testprograms/ir_type_test2/rom.hex", mem, 0, 6);
        //$readmemh("testprograms/auipc.hex", mem, 0, 2);
        $readmemh("testprograms/jal/rom.hex", mem, 0+7, 5+7);
        $readmemh("testprograms/bne/rom.hex", mem, 5+7, 5+7+10);
        $readmemh("testprograms/bge/rom.hex", mem, 20, 20+10);
        `endif
    end

    always @(negedge clk) begin
        if (rst) begin
            data <= 0;
            data_valid <= 0;
        end else begin
            data <= mem[addr];
            data_valid <= 1;
        end
    end

endmodule
