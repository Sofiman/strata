localparam ROM_BASE_ADDR = 'h40000000;
localparam RET_ADDR_1 = ROM_BASE_ADDR + 2 /* instructions */ * 4 /* 32-bit each */;
localparam RET_ADDR_2 = ROM_BASE_ADDR + 3 /* instructions */ * 4 /* 32-bit each */;
localparam DOUBLE_FUNC_BEGIN_ADDR = ROM_BASE_ADDR + 4 /* instructions */ * 4 /* 32-bit each */;
localparam DOUBLE_FUNC_END_ADDR = ROM_BASE_ADDR + 6 /* instructions */ * 4 /* 32-bit each */;

initial begin
    /* li x10, 1 */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_X10);
    `assert_eq(uut.rf.wr__data, 'h00000001);

    /* jal x1, double */
    wait_inst_retire();
    `assert_eq(uut.rf.wr__addr, REG_X1);
    `assert_eq(uut.rf.wr__data, RET_ADDR_1);

    /* double: */
        /* add x10, x10, x10 */
        wait_inst_retire();
        `assert_eq(pc, DOUBLE_FUNC_BEGIN_ADDR);
        `assert_eq(uut.rf.wr__addr, REG_X10);
        `assert_eq(uut.rf.wr__data, 'h00000002);

        /* jr x1 */
        wait_inst_retire();
        `assert_eq(uut.rf.wr__addr, REG_X0);
        `assert_eq(uut.rf.wr__data, DOUBLE_FUNC_END_ADDR);


    /* jal x1, double */
    wait_inst_retire();
    `assert_eq(pc, RET_ADDR_1);
    `assert_eq(uut.rf.wr__addr, REG_X1);
    `assert_eq(uut.rf.wr__data, RET_ADDR_2);

    /* double: */
        /* add x10, x10, x10 */
        wait_inst_retire();
        `assert_eq(pc, DOUBLE_FUNC_BEGIN_ADDR);
        `assert_eq(uut.rf.wr__addr, REG_X10);
        `assert_eq(uut.rf.wr__data, 'h00000004);

        /* jr x1 */
        wait_inst_retire();
        `assert_eq(uut.rf.wr__addr, REG_X0);
        `assert_eq(uut.rf.wr__data, DOUBLE_FUNC_END_ADDR);

    /* addi x10, x10, 4 */
    wait_inst_retire();
    `assert_eq(pc, RET_ADDR_2);
    `assert_eq(uut.rf.wr__addr, REG_X10);
    `assert_eq(uut.rf.wr__data, 'h00000008);
end
