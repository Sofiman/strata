   li x10, 0x5

   slli x11, x10, 1
   slli x12, x10, 3
   add x11, x11, x12 # a * 10 can be rewritten as (a << 1) + (a << 3)
