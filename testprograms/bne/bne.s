    li t0, 42
    li t1, 42
    li t2, 11

    li t3, 0
    li t4, 0

    bne t0, t1, first_false
first_true:
    li t3, 1
first_false:
    bne t0, t2, second_false
second_true:
    li t4, 1
second_false:
    nop
