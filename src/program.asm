.data
.code
    ldi 0 0x0000
    ldi 1 0x0000
    ldi 2 0x0001

loop
    ldi 3 0x904
    ld 3 3
    and 3 3 2
    jz check_dip1

    ldi 0 0x0000
    ldi 1 0x0000
    jmp check_dip4

check_dip1
    ldi 3 0x902
    ld 3 3
    and 3 3 2
    jz check_dip2

    add 0 0 2

check_dip2
    ldi 3 0x903
    ld 3 3
    and 3 3 2
    jz check_dip4

    add 1 1 2

check_dip4
    ldi 3 0x905
    ld 3 3
    and 3 3 2
    jz display_count1

    ldi 7 0x906
    st 7 1
    jmp loop

display_count1
    ldi 7 0x906
    st 7 0
    jmp loop
