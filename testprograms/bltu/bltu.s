    li t0, -1
    li t1, -1
    li t2, -2

    li t3, 0

    bltu t0, t3, first
    or t3, t3, 1
first:
    bltu t0, t2, second
    or t3, t3, 2
second:
    bltu t0, t1, third
    or t3, t3, 4
third:
    nop
