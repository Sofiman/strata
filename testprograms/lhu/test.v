localparam ROM_BASE_ADDR = 'h40000000;

localparam TEST_VALUE = 32'habcdef01;

initial begin
    uut.memory_subsys.ram.mem[0] = TEST_VALUE;

    /* lui t0, 0x80000 */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T0);
    `assert_eq(uut.rf.wr__data, 'h80000000);

    /* lhu t1, 0(t0) */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T1);
    `assert_eq(uut.rf.wr__data, 32'h0000ef01);

    /* lhu t2, 2(t0) */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T2);
    `assert_eq(uut.rf.wr__data, 32'h0000abcd);
end
