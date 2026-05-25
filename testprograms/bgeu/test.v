localparam ROM_BASE_ADDR = 'h40000000;

localparam FIRST_ADDR  = ROM_BASE_ADDR + 6 /* instructions */ * 4 /* 32-bit each */;
localparam SECOND_ADDR = ROM_BASE_ADDR + 8 /* instructions */ * 4 /* 32-bit each */;

initial begin
    /* li t0, -1 */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T0);
    `assert_eq(uut.rf.wr__data, 'hffffffff);

    /* li t1, -1 */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T1);
    `assert_eq(uut.rf.wr__data, 'hffffffff);

    /* li t2, -2 */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T2);
    `assert_eq(uut.rf.wr__data, 'hfffffffe);

    /* li t3, 0 */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_T3);
    `assert_eq(uut.rf.wr__data, 'h00000000);

    /* bgeu t0, t3, first */
    wait_inst_retire();

    /* bgeu t0, t2, second */
    wait_inst_retire();
    `assert_eq(pc, FIRST_ADDR);

    /* bgeu t0, t1, third */
    wait_inst_retire();
    `assert_eq(pc, SECOND_ADDR);

    /* li zero, 0 */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_ZERO);
    `assert_eq(uut.rf.wr__data, 'h00000000);

    ok = 1'b1;
end
