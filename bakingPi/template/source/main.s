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
        setVal .req r3
        mov setVal, #0
delay_start:
        mov r2, #0x3F0000
sub_loop:
        sub r2, r2, #1
        cmp r2, #0
        bne sub_loop

        @ switch setVal and set pin based on it
        @eor setVal, setVal, #1
        pinNum .req r0
        pinVal .req r1
        mov pinNum, #16
        mov pinVal, setVal
        bl SetGpio
        .unreq pinNum
        .unreq pinVal
        b delay_start
