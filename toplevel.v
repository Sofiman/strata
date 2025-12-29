module toplevel (
    input rst,
    input clk,
    input key,
    output [5:0] leds
);

    /*
   reg wr__en;

   (* keep *) wire [31:0] data_a;
   (* keep *) wire [31:0] data_b;
   (* keep *) wire [4:0] addr_a;
   (* keep *) wire [4:0] addr_b;
   (* keep *) wire [4:0] addr_wr;
   (* keep *) wire [31:0] data_wr;

    register_file rf (
        .clk(clk),

        .wr__en(wr__en),
        .wr__data(data_wr),
        .wr__addr(addr_wr),

        .porta__addr(addr_a),
        .porta__read_data(data_a),

        .portb__addr(addr_b),
        .portb__read_data(data_b)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            leds <= 0;
            wr__en <= 0;
        end else begin
            wr__en <= key;
            leds[0] <= data_a;
            leds[1] <= data_b;
            leds[2] <= addr_a;
            leds[3] <= addr_b;
            leds[4] <= data_wr;
            leds[5] <= key;
        end
    end
    */

endmodule
