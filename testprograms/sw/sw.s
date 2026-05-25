    lui t1, 0x87654
    addi t1, t1, 0x321
    lui t0, 0x80000
    sw t1, 0(t0)
