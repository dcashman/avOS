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
        push { setVal }
        waitTime .req r0
        @ldr waitTime, =0x100000
        ldr waitTime, =100000
        bl Wait
        pop { setVal }

        @ switch setVal and set pin based on it
        eor setVal, setVal, #1
        pinNum .req r0
        pinVal .req r1
        mov pinNum, #16
        mov pinVal, setVal
        push {setVal}
        bl SetGpio
        pop {setVal}
        .unreq pinNum
        .unreq pinVal
        b delay_start
