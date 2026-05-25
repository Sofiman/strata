module register_file #(
    parameter XLEN = 32 // bitwidth (32 or 64 bits)
) (
    input             clk,

    input             wr__en,
    input [4:0]       wr__addr,
    input [XLEN-1:0]  wr__data,

    input  [4:0]      porta__addr,
    output [XLEN-1:0] porta__read_data,

    input [4:0]       portb__addr,
    output [XLEN-1:0] portb__read_data
);

    localparam ZERO_REG_ADDR = 0;

    (* ram_style = "distributed" *) reg [XLEN-1:0] mem [31:0];

    assign porta__read_data = mem[porta__addr];
    assign portb__read_data = mem[portb__addr];

    integer i;
    initial begin
        for (i = 0; i < 32; i++) begin
            mem[i] = 0;
        end
    end

    (* always_ff *)
    always @(posedge clk) begin
        if (wr__addr != ZERO_REG_ADDR && wr__en) begin
            mem[wr__addr] <= wr__data;
        end
    end

    `ifdef BENCH
    function [79:0] reg_name (input [4:0] reg_addr);
        begin
            case (reg_addr)
                5'b00000: reg_name = "zero (x0)";
                5'b00001: reg_name = "ra (x1)";
                5'b00010: reg_name = "sp (x2)";
                5'b00011: reg_name = "gp (x3)";
                5'b00100: reg_name = "tp (x4)";
                5'b00101: reg_name = "t0 (x5)";
                5'b00110: reg_name = "t1 (x6)";
                5'b00111: reg_name = "t2 (x7)";
                5'b01000: reg_name = "s0 (x8)";
                5'b01001: reg_name = "s1 (x9)";
                5'b01010: reg_name = "a0 (x10)";
                5'b01011: reg_name = "a1 (x11)";
                5'b01100: reg_name = "a2 (x12)";
                5'b01101: reg_name = "a3 (x13)";
                5'b01110: reg_name = "a4 (x14)";
                5'b01111: reg_name = "a5 (x15)";
                5'b10000: reg_name = "a6 (x16)";
                5'b10001: reg_name = "a7 (x17)";
                5'b10010: reg_name = "s2 (x18)";
                5'b10011: reg_name = "s3 (x19)";
                5'b10100: reg_name = "s4 (x20)";
                5'b10101: reg_name = "s5 (x21)";
                5'b10110: reg_name = "s6 (x22)";
                5'b10111: reg_name = "s7 (x23)";
                5'b11000: reg_name = "s8 (x24)";
                5'b11001: reg_name = "s9 (x25)";
                5'b11010: reg_name = "s10 (x26)";
                5'b11011: reg_name = "s11 (x27)";
                5'b11100: reg_name = "t3 (x28)";
                5'b11101: reg_name = "t4 (x29)";
                5'b11110: reg_name = "t5 (x30)";
                5'b11111: reg_name = "t6 (x31)";
            endcase
        end
    endfunction

    wire [79:0] _b__porta_name;
    wire [79:0] _b__portb_name;
    wire [79:0] _b__wr_name;

    assign _b__porta_name = reg_name(porta__addr);
    assign _b__portb_name = reg_name(portb__addr);
    assign _b__wr_name = reg_name(wr__addr);
    `endif

endmodule

/* 
* === register_file ===

   Number of wires:                115
   Number of wire bits:            419
   Number of public wires:         115
   Number of public wire bits:     419
   Number of ports:                  7
   Number of port bits:            112
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                211
     GND                             1
     IBUF                           48
     LUT2                            2
     LUT3                           64
     OBUF                           64
     RAM16SDP4                      32

=== register_file ===

   Number of wires:                115
   Number of wire bits:            422
   Number of public wires:         115
   Number of public wire bits:     422
   Number of ports:                  7
   Number of port bits:            112
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                209
     GND                             1
     IBUF                           48
     LUT3                           64
     OBUF                           64
     RAM16SDP4                      32
=== register_file ===

   Number of wires:                 83
   Number of wire bits:            421
   Number of public wires:          83
   Number of public wire bits:     421
   Number of ports:                  9
   Number of port bits:            114
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                211
     GND                             1
     IBUF                           50
     LUT3                           64
     OBUF                           64
     RAM16SDP4                      32

     === register_file ===

   Number of wires:                 83
   Number of wire bits:            421
   Number of public wires:          83
   Number of public wire bits:     421
   Number of ports:                  9
   Number of port bits:            114
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                211
     GND                             1
     IBUF                           50
     LUT3                           64
     OBUF                           64
     RAM16SDP4                      32

     === register_file ===

   Number of wires:                 49
   Number of wire bits:           1189
   Number of public wires:          49
   Number of public wire bits:    1189
   Number of ports:                  9
   Number of port bits:            114
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                115
     GND                             1
     IBUF                           50
     OBUF                           64

---------------------- FINAL
    === register_file ===

   Number of wires:                117
   Number of wire bits:            455
   Number of public wires:         117
   Number of public wire bits:     455
   Number of ports:                  8
   Number of port bits:            113
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                210
     GND                             1
     IBUF                           49
     LUT3                           64
     OBUF                           64
     RAM16SDP4                      32

*/
