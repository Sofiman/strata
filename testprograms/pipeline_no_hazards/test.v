initial begin
    wait(uut.stage1__o__pc > 'h40000020);

    `assert_eq(uut.rf.mem[REG_T0], 32'd0);
    `assert_eq(uut.rf.mem[REG_T1], 32'd1);
    `assert_eq(uut.rf.mem[REG_T2], 32'd2);
    `assert_eq(uut.rf.mem[REG_T3], 32'd3);

    ok = 1'b1;
end
