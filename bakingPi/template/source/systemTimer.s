@ Functions for dealing with the system timer.
@ Author: dcashman.

@ GetTimerAddress - returns the base mem address for the timer.
        .globl GetSystemTimerAddress
GetTimerAddress:
        ldr r0, =0x20003000
        mov pc, lr

@
@ GetTimeStamp - ret low timer in r0 and high in r1
@
.globl GetTimeStamp
GetTimeStamp:
        push {lr}
        bl GetTimerAddress
        ldrd r0,r1,[r0,#4]
        pop {pc}

        @ copied
        .globl Wait3

@ Wait - function which busy-waits until the indicated number of microseconds
@   has passed.
@ params:
@   r0 - Number of microseconds which to wait. 32 bit-only
        .globl Wait

Wait:
        numMicroSec .req r1
        mov numMicroSec, r0
        timerAddr .req r0
        push {lr}
        bl GetTimerAddress
        currentMicroSecLow .req r2
        currentMicroSecHigh .req r3

        @ save and use reg 4 and 5
        push { r4 }
        push { r5 }
        stopLow .req r4
        stopHigh .req r5

        @ load timer counter (8 bytes) into 2 registers
        @ we could also have used arm block transfer instr.
        ldrd currentMicroSecLow, currentMicroSecHigh, [timerAddr,#4]

        @ TODO: would be nice to have a general BigNum arithmetic function.
        @ For now we'll just check the corner-cases in-line
        @ if currentLow + num to wait has overflow, increment high by 1 and
        @ record the new low.  We don't deal with overflow of high register as
        @ 2^64 microseconds is equivalent to 584+ years.
        mov stopHigh, currentMicroSecHigh
        adds stopLow, currentMicroSecLow, numMicroSec
        addcs stopHigh, currentMicroSecHigh, #1 @carry-bit set

        @ Now that we have our stopping counts, branch until we exceed.
.LcompTime:
        ldrd currentMicroSecLow, currentMicroSecHigh, [timerAddr,#4]
        cmp currentMicroSecHigh, stopHigh

        @ if high > targ-high, we're done (shouldn't ever happen)
        bhi .Lexit

        @ if high == targ-high, check lower
        beq .LcmpLower
        @b .LcmpLower

        @ else we're lower than targ-high, so keep going
        b .LcompTime

        @ compare lower register to desired value, loop back if its lower
.LcmpLower:
        cmp currentMicroSecLow, stopLow
        bhi .Lexit
        beq .Lexit
        b   .LcompTime

.Lexit:
        .unreq timerAddr
        .unreq numMicroSec
        .unreq currentMicroSecLow
        .unreq currentMicroSecHigh
        .unreq stopLow
        .unreq stopHigh
        pop { r5 }
        pop { r4 }
        pop { pc }
