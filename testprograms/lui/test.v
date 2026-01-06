initial begin
    #(`CLK_PERIOD) /* instruction loading stall */

    /* lui x10, %hi(0x12345) */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_A0);
    `assert_eq(uut.rf.wr__data, 'h00012000);

    /* addi x10, x10, %lo(0x12345) */
    #(`CLK_PERIOD) /* fetch */
    #(`CLK_PERIOD) /* execute */
    `assert_eq(uut.rf.wr__addr, REG_A0);
    `assert_eq(uut.rf.wr__data, 'h00012345);

    /* nop */
end
