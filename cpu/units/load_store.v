module load_store (
    input n_rst,
    input clk,

    input             up_valid,
    output            up_ready,

    output            dw_valid,
    input             dw_ready,

    input      [31:0] up_addr,
    input      [3:0]  up_op,
    input      [31:0] up_data_in,
    output reg [31:0] dw_data_out,

    output reg        mem_valid,
    input             mem_ready,
    output     [31:0] mem_addr,
    output reg [ 3:0] mem_strobe,
    output reg [31:0] mem_write_data,
    input      [31:0] mem_read_data,
    input             mem_fault
);

    assign mem_addr = up_addr;
    assign dw_valid = mem_valid & mem_ready;
    assign up_ready = dw_ready & (/* mem is busy */ (!mem_valid | mem_ready) | /* mem will become busy */ (up_valid & !mem_valid));

    (* always_ff *)
    always @(posedge clk or negedge n_rst) begin
         if (!n_rst) begin
             mem_valid <= 1'b0;
         end else begin
             if (up_valid & up_ready) begin
                 mem_valid <= 1'b1;
             end else if (dw_valid) begin
                 mem_valid <= 1'b0;
             end
         end
    end

    reg [3:0] r_up_op;
    (* always_ff *)
    always @(posedge clk) if (up_valid & up_ready) r_up_op <= up_op;

    (* always_comb *)
    always @(*) mem_write_data <= up_data_in << {up_addr[1:0], 3'b0};

    wire [31:0] read_data_aligned = mem_read_data >> {up_addr[2:0], 3'b0};

    (* always_comb *)
    always @(*) mem_strobe <= r_up_op[3] ? ({r_up_op[1], r_up_op[1:0], 1'b1} << up_addr[1:0]) : 4'b0;

    (* always_comb *)
    always @(*) begin
        case (r_up_op[1:0])
            2'b00: dw_data_out <= {{24{read_data_aligned[ 7] & !r_up_op[2]}}, read_data_aligned[ 7:0]};
            2'b01: dw_data_out <= {{16{read_data_aligned[15] & !r_up_op[2]}}, read_data_aligned[15:0]};
            2'b10: dw_data_out <= read_data_aligned;
            2'b11: dw_data_out <= {32{1'bx}};
            // TODO: Illegal instruction: 2'b11
        endcase
    end

endmodule
