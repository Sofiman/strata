localparam TEST_VALUE = 32'h12345678;

initial begin
    mss.ram.mem[0] = TEST_VALUE;
    wait(uut.stage1__o__pc > 'h40000024);

    `assert_eq(uut.rf.mem[REG_T0], 32'h80000000);
    `assert_eq(uut.rf.mem[REG_T1], TEST_VALUE);
    `assert_eq(uut.rf.mem[REG_T2], 32'd2);
    `assert_eq(uut.rf.mem[REG_T3], 32'd3);

    ok = 1'b1;
end
