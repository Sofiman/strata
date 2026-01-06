initial begin
    #(`CLK_PERIOD) /* instruction loading stall */

    /* addi x10, x0, 0x123 */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_X10);
    `assert_eq(uut.rf.wr__data, 'h00000123);

    /* andi x10, x10, 0xf */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_X10);
    `assert_eq(uut.rf.wr__data, 'h00000003);

    /* nop */
end
