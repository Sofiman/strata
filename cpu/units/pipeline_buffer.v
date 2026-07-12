module pipeline_buffer #(
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

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            dw_valid <= 1'b0;
        end else begin
            if (dw_ready) dw_valid <= up_valid;
        end
    end

    always @(posedge clk) begin
        if (up_valid & dw_ready)
            dw_data  <= up_data;
    end

    assign up_ready = dw_ready;

endmodule
