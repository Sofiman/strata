`ifdef BENCH
`define BENCH_STAGE_BOND(PrevStage) , ._b__i__inst(PrevStage._b__o__inst)
`define BENCH_STAGE_INOUT , input [31:0] _b__i__inst, \
                          output reg [31:0] _b__o__inst
`define BENCH_STAGE_LOGIC always @(posedge clk) if (i__valid && !o__busy) _b__o__inst <= _b__i__inst;
`else
`define BENCH_STAGE_BOND(PrevStage)
`define BENCH_STAGE_INOUT
`define BENCH_STAGE_LOGIC
`endif
