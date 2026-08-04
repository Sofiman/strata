localparam TEST_VALUE = 32'h12345678;

initial begin
    mss.ram.mem[0] = TEST_VALUE;
    wait(uut.stage1__o__pc > 'h4000001c + 16);

    `assert_eq(uut.rf.mem[REG_T0], 32'd129);

    ok = 1'b1;
end
