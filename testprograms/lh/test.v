localparam ROM_BASE_ADDR = 'h40000000;

localparam TEST_VALUE = 32'hf234a678;

initial begin
    uut.memory_subsys.ram.mem[0] = TEST_VALUE;

    /* lui t0, 0x80000 */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T0);
    `assert_eq(uut.rf.wr__data, 'h80000000);

    /* lh t1, 0(t0) */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T1);
    `assert_eq(uut.rf.wr__data, 32'hffffa678);

    /* lh t2, 2(t0) */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T2);
    `assert_eq(uut.rf.wr__data, 32'hfffff234);
end
