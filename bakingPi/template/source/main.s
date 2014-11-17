.section .init
.globl _start
_start:
        b main

        .section .text
main:
        @set stack base to 0x8000, default load address (OK3)
        mov sp, #0x8000

        @ enable output on pin 16
        pinNum .req r0
        pinFunc .req r1
        mov pinNum, #16
        mov pinFunc, #1
        bl SetGpioFunction
        .unreq pinNum
        .unreq pinFunc

        @begin timer
        ptrn .req r2
        ldr ptrn, =sos_pattern
        ldr ptrn, [ptrn]
        seq .req r3
        mov seq, #0
delay_start:
        push { ptrn }
        push { seq }
        waitTime .req r0
        ldr waitTime, =250000
        bl Wait
        .unreq waitTime
        pop { seq }
        pop { ptrn }


        pinNum .req r0
        pinVal .req r1
        @ get bit from sequence num and set pin 16 to that value
        mov pinVal, #1
        lsl pinVal, seq
        ands pinVal, ptrn
        push { ptrn }
        push { seq }
        movne pinVal, #1
        mov pinNum, #16
        bl SetGpio
        pop { seq }
        pop { ptrn }
        .unreq pinNum
        .unreq pinVal
        add seq, #1
        and seq, #0b11111
        b delay_start

        .section .data
        .align 2
sos_pattern:
        .int 0b11111111101010100010001000101010
