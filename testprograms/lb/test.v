localparam ROM_BASE_ADDR = 'h40000000;

localparam TEST_VALUE = 32'h72d456a8;

initial begin
    uut.memory_subsys.ram.mem[0] = TEST_VALUE;

    /* lui t0, 0x80000 */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T0);
    `assert_eq(uut.rf.wr__data, 'h80000000);

    /* lb t1, 0(t0) */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T1);
    `assert_eq(uut.rf.wr__data, 32'hffffffa8);

    /* lb t2, 1(t0) */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T2);
    `assert_eq(uut.rf.wr__data, 32'h00000056);

    /* lh t3, 2(t0) */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T3);
    `assert_eq(uut.rf.wr__data, 32'hffffffd4);

    /* lh t4, 3(t0) */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T4);
    `assert_eq(uut.rf.wr__data, 32'h00000072);
end
