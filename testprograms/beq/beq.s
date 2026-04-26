    li t0, -1
    li t1, -1
    li t2, -2

    li t3, 0

    beq t0, t1, first
    or t3, t3, 1
first:
    beq t0, t2, second
    or t3, t3, 2
second:
    nop
