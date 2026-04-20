localparam ROM_BASE_ADDR = 'h40000000;

localparam FIRST_TRUE_ADDR   = ROM_BASE_ADDR + 6 /* instructions */ * 4 /* 32-bit each */;
localparam SECOND_FALSE_ADDR = ROM_BASE_ADDR + 10 /* instructions */ * 4 /* 32-bit each */;

initial begin
    #(`CLK_PERIOD) /* instruction loading stall */

    /* li t0, 42 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_T0);
    `assert_eq(uut.rf.wr__data, 'd00000042);

    /* li t1, 42 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_T1);
    `assert_eq(uut.rf.wr__data, 'd00000042);

    /* li t2, 11 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_T2);
    `assert_eq(uut.rf.wr__data, 'd00000011);

    /* li t3, 0 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_T3);
    `assert_eq(uut.rf.wr__data, 'h00000000);

    /* li t4, 0 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_T4);
    `assert_eq(uut.rf.wr__data, 'h00000000);

    /* bne t0, t1, first_false */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.pc, FIRST_TRUE_ADDR);

    /* li t3, 1 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_T3);
    `assert_eq(uut.rf.wr__data, 'h00000001);

    /* bne t0, t2, second_false */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.pc, SECOND_FALSE_ADDR);

    /* li zero, 0 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_ZERO);
    `assert_eq(uut.rf.wr__data, 'h00000000);

end
