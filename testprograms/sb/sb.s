    lui t1, 0x87654
    addi t1, t1, 0x321
    lui t0, 0x80000
    sb t1, 0(t0)
    sb t1, 1(t0)
    sb t1, 2(t0)
    sb t1, 3(t0)
