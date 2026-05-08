initial begin
    #(`CLK_PERIOD) /* instruction loading stall */

    /* addi x10, x0, 0x5a1 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_X10);
    `assert_eq(uut.rf.wr__data, 'h000005a1);

    /* xori x11, x10, -1 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_X11);
    `assert_eq(uut.rf.wr__data, 'hfffffa5e);

    /* or x12, x10, x11 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_X12);
    `assert_eq(uut.rf.wr__data, 'hffffffff);

    /* add x13, x10, x11 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_X13);
    `assert_eq(uut.rf.wr__data, 'hffffffff);

    /* sub x14, x11, x10 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_X14);
    `assert_eq(uut.rf.wr__data, 'hfffff4bd);

    /* nop */
end
