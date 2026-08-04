module pipeline_buffer_delay #(
    parameter DATA_WIDTH = 1'b1
) (
    input clk,
    input n_rst,

    input      [DATA_WIDTH-1:0] up_data,
    input                       up_valid,
    output                      up_ready,
    output reg [DATA_WIDTH-1:0] dw_data,
    output reg                  dw_valid,
    input                       dw_ready
);

    // ---[up_data ]-->|============|---[dw_data ]-->
    //                 |            |
    // ---[up_valid]-->|   buffer   |---[dw_valid]-->
    //                 |            |
    // <--[up_ready]---|============|<--[dw_ready]---

    reg clock_enable;
    reg [DATA_WIDTH-1:0] work;
    reg i;

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            dw_valid <= 1'b0;
            clock_enable <= 1'b0;
        end else if (clock_enable) begin

            // Actual compute
            dw_data <= work + 1;

            // When the compute is done
            clock_enable <= 1'b0;
            dw_valid <= 1'b1;
        end else if (dw_ready) begin
            dw_valid <= 1'b0;
            if (up_valid) begin
                // Init compute
                clock_enable <= 1'b1;
                work <= up_data;
            end
        end
    end

    assign up_ready = dw_ready & !clock_enable; // TODO

endmodule
