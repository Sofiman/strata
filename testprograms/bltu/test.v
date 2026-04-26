localparam ROM_BASE_ADDR = 'h40000000;

localparam FIRST_ADDR  = ROM_BASE_ADDR + 5 /* instructions */ * 4 /* 32-bit each */;
localparam SECOND_ADDR = ROM_BASE_ADDR + 7 /* instructions */ * 4 /* 32-bit each */;
localparam THIRD_ADDR  = ROM_BASE_ADDR + 9 /* instructions */ * 4 /* 32-bit each */;

initial begin
    /* li t0, -1 */
    wait_for_execute();
    `assert_eq(uut.rf.wr__addr, REG_T0);
    `assert_eq(uut.rf.wr__data, 'hffffffff);

    /* li t1, -1 */
    wait_for_execute();
    `assert_eq(uut.rf.wr__addr, REG_T1);
    `assert_eq(uut.rf.wr__data, 'hffffffff);

    /* li t2, -2 */
    wait_for_execute();
    `assert_eq(uut.rf.wr__addr, REG_T2);
    `assert_eq(uut.rf.wr__data, 'hfffffffe);

    /* li t3, 0 */
    wait_for_execute();
    `assert_eq(uut.rf.wr__addr, REG_T3);
    `assert_eq(uut.rf.wr__data, 'h00000000);

    /* bltu t0, t3, first */
    wait_for_execute();

    /* or t3, t3, 1 */
    wait_for_execute();
    `assert_eq(uut.pc, FIRST_ADDR);
    `assert_eq(uut.rf.wr__addr, REG_T3);
    `assert_eq(uut.rf.wr__data, 'h00000001);

    /* bltu t0, t2, second */
    wait_for_execute();

    /* or t3, t3, 2 */
    wait_for_execute();
    `assert_eq(uut.pc, SECOND_ADDR);
    `assert_eq(uut.rf.wr__addr, REG_T3);
    `assert_eq(uut.rf.wr__data, 'h00000003);

    /* bltu t0, t1, third */
    wait_for_execute();

    /* or t3, t3, 4 */
    wait_for_execute();
    `assert_eq(uut.pc, THIRD_ADDR);
    `assert_eq(uut.rf.wr__addr, REG_T3);
    `assert_eq(uut.rf.wr__data, 'h00000007);

    /* li zero, 0 */
    wait_for_execute();
    `assert_eq(uut.rf.wr__addr, REG_ZERO);
    `assert_eq(uut.rf.wr__data, 'h00000000);

end
