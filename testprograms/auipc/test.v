localparam ROM_BASE_ADDR = 'h40000000;
localparam FOO_ADDR = ROM_BASE_ADDR + 3 /* instructions */ * 4 /* 32-bit each */;

initial begin
    /* auipc a0, %pcrel_hi(foo) */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_A0);
    `assert_eq(uut.rf.wr__data, FOO_ADDR & ~('h00000FFF));

    /* addi a0, a0, %pcrel_lo(1b) */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_A0);
    `assert_eq(uut.rf.wr__data, FOO_ADDR);

    /* nop */
    ok = 1'b1;
end
