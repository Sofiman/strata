module load_store (
    input n_rst,
    input clk,

    input [31:0] addr,
    input [3:0]  op,
    input [31:0] data_in,
    output reg [31:0] data_out,

    input i_valid,
    output o_valid,
    output o_busy,

    output [5:0] leds
);

    // Memory Subsystem
    wire [31:0] mss_read_data;
    reg   [3:0] mss_write_strobe;
    reg  [31:0] mss_write_data;

    wire [31:0] mss_read_data_aligned = mss_read_data >> {addr[2:0], 3'b0};

    memory_subsys memory_subsys (
        .n_rst(n_rst),
        .clk(clk),

        .addr(addr),
        .read_data(mss_read_data),
        .write_enable(mss_write_strobe),
        .write_data(mss_write_data),

        .i_valid(i_valid),
        .i_busy(/* TODO */ 1'b0),
        .o_valid(o_valid),
        .o_busy(o_busy),

        .fault(),

        .leds(leds)
    );

    (* always_comb *)
    always @(*) begin
        case (op[1:0])
            2'b00: data_out <= {{24{mss_read_data_aligned[7] & !op[2]}}, mss_read_data_aligned[7:0]};
            2'b01: data_out <= {{16{mss_read_data_aligned[15] & !op[2]}}, mss_read_data_aligned[15:0]};
            2'b10, 2'b11: data_out <= mss_read_data_aligned;
            // TODO: Illegal instruction: 2'b11
        endcase
    end

    (* always_comb *)
    always @(*) begin
        mss_write_data <= data_in << {addr[1:0], 3'b0};
        if (op[3]) begin
            mss_write_strobe <= {op[1], op[1:0], 1'b1} << addr[1:0];
        end else begin
            mss_write_strobe <= 4'b0;
        end
    end

endmodule
