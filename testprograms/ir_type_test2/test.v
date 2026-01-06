initial begin
    #(`CLK_PERIOD) /* instruction loading stall */

    /* li x10, -3 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_X10);
    `assert_eq(uut.rf.wr__data, 'hfffffffd);

    /* srai x11, x10, 16 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_X11);
    `assert_eq(uut.rf.wr__data, 'hffffffff);

    /* srli x12, x10, 16 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_X12);
    `assert_eq(uut.rf.wr__data, 'h0000ffff);

    /* li x10, 0x5 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_X10);
    `assert_eq(uut.rf.wr__data, 'h00000005);

    /* slli x11, x10, 1 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_X11);
    `assert_eq(uut.rf.wr__data, 'h0000000a);

    /* slli x12, x10, 3 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_X12);
    `assert_eq(uut.rf.wr__data, 'h00000028);

    /* add x11, x11, x12 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_X11);
    `assert_eq(uut.rf.wr__data, 'h00000032);

    /* nop */
end
