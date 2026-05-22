localparam ROM_BASE_ADDR = 'h40000000;

localparam TEST_VALUE = 32'h12345678;

initial begin
    uut.memory_subsys.ram.mem[0] = TEST_VALUE;

    /* lui t0, 0x80000 */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T0);
    `assert_eq(uut.rf.wr__data, 'h80000000);

    /* lw t1, 0(t0) */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T1);
    `assert_eq(uut.rf.wr__data, TEST_VALUE);
end
