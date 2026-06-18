module logic_analyzer #(
    parameter CAPTURE_WIDTH = 128,
    parameter CAPTURE_SAMPLES = 512
) (
    input n_rst,
    input clk,

    input clock_enable,

    input capture_trigger,
    input [CAPTURE_WIDTH-1:0] capture,
    output capture_finished,

    input read_en,
    output reg [CAPTURE_WIDTH-1:0] read_data,
    output reg read_finished
);

    (* ram_style = "block" *) reg [CAPTURE_WIDTH-1:0] mem [CAPTURE_SAMPLES-1:0];

    reg [$clog2(CAPTURE_SAMPLES)-1:0] read_addr;
    reg [$clog2(CAPTURE_SAMPLES)-1:0] wr_addr;

    reg capture_en;
    assign capture_finished = !capture_en;

    (* always_ff *)
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            capture_en <= 0;
        end else if (!capture_en) begin
            capture_en <= capture_trigger;
        end else begin
            capture_en <= !(&wr_addr);
        end
    end

    /* WRITING */

    (* always_ff *)
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            wr_addr <= 'b0;
        end else if (clock_enable & capture_en) begin
            // TODO: assert CAPTURE_SAMPLES is a power of two so it cleanly wraps here
            wr_addr <= wr_addr + 1'b1;
        end
    end

    /* READING */

    (* always_ff *)
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            read_addr <= 'b0;
            read_finished <= 'b1;
        end else if (clock_enable & read_en) begin
            // TODO: assert CAPTURE_SAMPLES is a power of two so it cleanly wraps here
            read_addr <= read_addr + 1'b1;
            read_finished <= (&read_addr);
        end
    end

    (* always_ff *)
    always @(posedge clk) begin
        if (clock_enable & (capture_en | read_en)) begin
            if (capture_en) mem[wr_addr] <= capture;
            else            read_data <= mem[read_addr];
        end
    end

endmodule
