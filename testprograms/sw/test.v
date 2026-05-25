localparam ROM_BASE_ADDR = 'h40000000;

localparam TEST_VALUE = 32'h87654321;

initial begin
    uut.memory_subsys.ram.mem[0] = 'hfefefefe;

    /* lui t1, 0x87654 */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T1);

    /* addi t1, t1, 0x321 */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T1);
    `assert_eq(uut.rf.wr__data, TEST_VALUE);

    /* lui t0, 0x80000 */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T0);
    `assert_eq(uut.rf.wr__data, 'h80000000);

    /* sw t0, 0(t0) */
    wait_inst_retire();
    `assert_eq(uut.memory_subsys.ram.mem[0], TEST_VALUE);

    ok = 1'b1;
end
