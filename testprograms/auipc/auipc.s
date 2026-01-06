1:
    auipc a0, %pcrel_hi(foo)
    addi a0, a0, %pcrel_lo(1b)
    nop

foo:
    .word 0x12345
