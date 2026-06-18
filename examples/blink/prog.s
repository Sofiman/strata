_boot:
    li t0, 0          ; prescaler counter value
    lui t1, 79        ; prescaler counter target, 79 << 12
    li t2, 0x40000000 ; LED output register address
    li t3, 0          ; LED output register value
loop:
    addi t0, t0, 1
    bne t0, t1, loop
    add t0, zero, zero
    xori t3, t3, 1
    sw t3, 0(t2)
    jal zero, loop
