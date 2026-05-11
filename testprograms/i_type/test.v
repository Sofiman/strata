initial begin
    /* addi x10, x0, 0x123 */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_X10);
    `assert_eq(uut.rf.wr__data, 'h00000123);

    /* andi x10, x10, 0xf */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_X10);
    `assert_eq(uut.rf.wr__data, 'h00000003);

    /* nop */
end
