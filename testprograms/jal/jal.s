    li x10, 1
    jal x1, double  # Call double
    jal x1, double  # Call double
    addi x10, x10, 4

    # Double the value in x10
double:
    add x10, x10, x10
    jr x1           # Return
