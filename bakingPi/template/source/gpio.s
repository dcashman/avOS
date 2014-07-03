@ GPIO related functions
@

@ GetGpioAddress - returns the base mem address for the GPIO controller
        .globl GetGpioAddress
GetGpioAddress:
        ldr r0, =0x20200000
        mov pc, lr

@ SetGpioFunction -
@ params:
@   r0 - GPIO target pin, must be 0-53
@   r1 - GPIO target function, must be 0-7
        .globl SetGpioFunction
SetGpioFunction:

        @ input validation
        cmp r0, #53
        cmpls r1, #7
        movhi pc, lr

        push {lr}
        mov r2, r0
        bl GetGpioAddress
LGpioTenBlock:

        @ There are 4 bytes for every 10 GPIO pins (3 bits per pin).
        @ We need to find the right 4-byte block.
        cmp r2, #9
        subhi r2, #10
        addhi r0, #4
        bhi LGpioTenBlock
        add r2, r2, lsl #1 @ r2 = r2 x 3

        @r2 now holds the amount we must shift.
        @get the old value, clear the 3 bits for that pin,
        @ and then | the new ones with the old.
        ldr r3, [r0]
        mov r4, #7
        lsl r4, r2
        bic r3, r4
        lsl r1, r2
        orr r1, r3
        str r1, [r0]
        pop {pc}

        .globl SetGpio

@ SetGpio -
@ params:
@   r0 - GPIO target pin, must be 0-53
@   r1 - GPIO set value: 0 for off, 1 for on.
@        'off' turns the LED on, and 'on' turns it off.
        .globl SetGpio
SetGpio:

        @ [label] .req [reg #] - makes [label] an alias for [reg #]
        pinNum .req r0
        pinVal .req r1
        cmp pinNum, #53
        movhi pc, lr @invalid pin #
        push {lr}
        mov r2, pinNum
        .unreq pinNum
        pinNum .req r2
        bl GetGpioAddress @r0 now has address
        gpioAddr .req r0

        @The GPIO controller has two sets of 4 bytes each
        @for turning pins on and off
        @determine if this pin is in first or second set (i/32)
        @and add that to the gpioAddr
        pinBank .req r3
        lsr pinBank, pinNum, #5
        lsl pinBank, #2
        add gpioAddr, pinBank
        .unreq pinBank
        and pinNum, #31
        setBit .req r3
        mov setBit, #1
        lsl setBit, pinNum
        .unreq pinNum

        @if pinVal == 1, turn on the pin
        @turn on pins start at gpioAddr + #28, off is #40
        @TODO: what if both on and off are set simultaneously
        @TODO: do we need to worry about other values in this word?
        teq pinVal, #0
        .unreq pinVal
        strne setBit, [gpioAddr, #28]
        streq setBit, [gpioAddr, #40]
        .unreq setBit
        .unreq gpioAddr
        pop {pc}
