@ BattleshipFinaltest2.s
@ Battle Ship lame edition. Guess where ship is to win.
@ 2020-12-10: Nicholas Garcia

@ Define my Raspberry Pi
        .cpu    cortex-a53
        .fpu    neon-fp-armv8
        .syntax unified         @ modern syntax
@ Constant program data
        .section        .rodata
        .align  2
hintMsg:
        .asciz  "%d %d\000"

promptMsg:
        .asciz  "\nWHERE DO YOU WANT TO HIT\n"

columnResponse:
        .asciz  "Pick a column (char A-J): \000"

errorMsg:
        .asciz  "\nPosition not on the board.\n"

rowResponse:
        .asciz  "\nPick a row (int 1-10): \000 "

userAnswer:
        .asciz  "%d\000"

hitMsg:
        .asciz  "\nHit\n"

missMsg:
        .asciz  "\nMiss \n"
@ Program code
        .text
        .align  2
        .global main
        .type   main, %function
main:
@ Prologue
        push    {fp, lr}
        add     fp, sp, #4      @ Establish frame pointer
        sub     sp, sp, #432

        mov     r0, #0          @ return 0
        bl      time
        mov     r3, r0		@ move 0 in to r3

        mov     r0, r3          @ return values go in r0
        bl      srand 		@ branch link
        bl      nsew		@ branch link to nsew

        str     r0, [fp, #-8]	@ store register with frame pointer and memory for word
        ldr     r0, [fp, #-8]	@ load register
        bl      placementC	@ branch link to placementC

        str     r0, [fp, #-12]	@ move frame ptr stack
        ldr     r0, [fp, #-8]	@ load register
        bl      placementR	@ branch link placementR

        str     r0, [fp, #-16]	@ store register with word
        ldr     r2, [fp, #-16] 	@ load register 2
        ldr     r1, [fp, #-12]	@ load register 1
        ldr     r0, strAddr     @ address of text string
        bl      printf		@ branch link to printf

        mov     r3, #0		@ move 0 into register 3
        str     r3, [fp, #-20]	@ store in word in register 3
        b       compareAndTry	@ branch to compareAndTry
whileLoop:
        ldr     r0, strAddr+4	 @prints string that prompt user
        bl      puts
        ldr     r0, strAddr+8	 @print string to ask for column input
        bl      puts
        bl      getchar		@ branch link to get user input of a letter A-J
        mov     r3, r0		@ store letter
        strb    r3, [fp, #-21] 	@ store register 3 with byte
        ldrb    r3, [fp, #-21]	@ load register with byte
        mov     r0, r3		@ move value in r3 to r0
        bl      toupper		@makes letter upper for handling
        mov     r3, r0		@ store upper letter
        strb    r3, [fp, #-21]
        ldrb    r3, [fp, #-21]
        cmp     r3, #64		@ checks if column is < 65 or A
        bls     inputError	@ if less or more than range branch to error message
        ldrb    r3, [fp, #-21]
        cmp     r3, #74		@ checks if column is > 74 or J
        bls     rowEntry	@ if in range branches to row entry
inputError:
        ldr     r0, strAddr+12  @ prints error message and then breaks
        bl      puts
        b       break		@ branch to break
rowEntry:			@ gets players input for row
        ldrb    r3, [fp, #-21]
        sub     r3, r3, #65	@ subtracts 65 from value in r3 to get position
        str     r3, [fp, #-28]
				@ prints string that prompts user for row input
        ldr     r0, strAddr+16
        bl      puts
        sub     r3, fp, #436
        mov     r1, r3

 	ldr     r0, strAddr+20	@ prints user answer
	bl      __isoc99_scanf
        ldr     r3, [fp, #-436]

        cmp     r3, #0		@ checks if input is less than one
        ble     inputError2	@ branches to print error string if true
        ldr     r3, [fp, #-436]
        cmp     r3, #10		@ checks if input is greater than 10
        ble     checkIfShipHitNS @ if between range branch to check
inputError2:
        ldr     r0, strAddr+12	@ prints error message and then breaks
        bl      puts
        b       break
checkIfShipHitNS:			@ checks to see if ship is East or West then branch to hitShip
        ldr     r3, [fp, #-436]
        sub     r3, r3, #1
        str     r3, [fp, #-436]
        ldr     r3, [fp, #-8]
        cmp     r3, #0			@ check if ship is oriented to north south
        bne     checkIfShipHitEW	@ other wise branch to check if ship is east west
        ldr     r1, [fp, #-436]		@ load with word
        ldr     r2, [fp, #-28]		@ load register 2 with word
        mov     r3, r2			@ move value to r3
        lsl     r3, r3, #2		@ shift left 2 so boat is longer
        add     r3, r3, r2		@ add so boat in longer
        lsl     r3, r3, #1		@ shift left 1 so boat is longer
        add     r3, r3, r1		@ add so boat is longer
        lsl     r3, r3, #2		@ shift left 2
        sub     r2, fp, #4		@ fp pointer value - 4
        add     r3, r2, r3		@ add the registers
        ldr     r1, [r3, #-428]		@ load register 1
        ldr     r2, [fp, #-12]		@ load register 2
        mov     r3, r2			@ move value in r2 to value in r3
        lsl     r3, r3, #2		@ left shift 2
        add     r3, r3, r2		@ add so boat longer
        lsl     r3, r3, #1		@ left shift 1 so boat longer
        ldr     r2, [fp, #-16]		@ load register so boat is now longer
        add     r3, r3, r2
        lsl     r3, r3, #2
        sub     r2, fp, #4
        add     r3, r2, r3
        ldr     r3, [r3, #-428]
        cmp     r1, r3			@ if input column and row equal random column and row
        beq     hitShip			@ then branch to hitShip
        ldr     r1, [fp, #-436]
        ldr     r2, [fp, #-28]
        mov     r3, r2
        lsl     r3, r3, #2
        add     r3, r3, r2
        lsl     r3, r3, #1
        add     r3, r3, r1
        lsl     r3, r3, #2
        sub     r2, fp, #4
        add     r3, r2, r3
        ldr     r1, [r3, #-428]
        ldr     r3, [fp, #-16]
        add     r0, r3, #1
        ldr     r2, [fp, #-12]
        mov     r3, r2
        lsl     r3, r3, #2
        add     r3, r3, r2
        lsl     r3, r3, #1
        add     r3, r3, r0
        lsl     r3, r3, #2
        sub     r2, fp, #4
        add     r3, r2, r3
        ldr     r3, [r3, #-428]
        cmp     r1, r3
        beq     hitShip
        ldr     r1, [fp, #-436]
        ldr     r2, [fp, #-28]
        mov     r3, r2
        lsl     r3, r3, #2
        add     r3, r3, r2
        lsl     r3, r3, #1
        add     r3, r3, r1
        lsl     r3, r3, #2
        sub     r2, fp, #4
        add     r3, r2, r3
        ldr     r1, [r3, #-428]
        ldr     r3, [fp, #-16]
        add     r0, r3, #3
        ldr     r2, [fp, #-12]
        mov     r3, r2
        lsl     r3, r3, #2
        add     r3, r3, r2
        lsl     r3, r3, #1
        add     r3, r3, r0
        lsl     r3, r3, #2
        sub     r2, fp, #4
        add     r3, r2, r3
        ldr     r3, [r3, #-428]
        cmp     r1, r3
        bne     missed
hitShip:
@ print hit ship message then branch to break which ends program
        ldr     r0, strAddr+24	@ loads string hit
        bl      printf
        b       break 		@ branch to break
checkIfShipHitEW:
@ checks to see if ship is East or West
@ if input column and row equal random column and row
@ then branch to hitShip
        ldr     r1, [fp, #-436]
        ldr     r2, [fp, #-28]
        mov     r3, r2
        lsl     r3, r3, #2	@ shift left 2
        add     r3, r3, r2	@ add the values
        lsl     r3, r3, #1	@shift left 1
        add     r3, r3, r1	@ add values
        lsl     r3, r3, #2	@ shift left 2
        sub     r2, fp, #4	@ this will cause the boat to be 4 long
        add     r3, r2, r3	@ boat will be store and 4 long

        ldr     r1, [r3, #-428]	@ load size and location in to r1
        ldr     r2, [fp, #-12]	@ load fp to r2 with some fixed bits
        mov     r3, r2
        lsl     r3, r3, #2
        add     r3, r3, r2
        lsl     r3, r3, #1
        ldr     r2, [fp, #-16]
        add     r3, r3, r2
        lsl     r3, r3, #2
        sub     r2, fp, #4
        add     r3, r2, r3
        ldr     r3, [r3, #-428]
        cmp     r1, r3		@ if r1 == r2 comapres the two values random and users
        beq     userInput	@ if r1 == r3 then  branch to userInput

        ldr     r1, [fp, #-436]
        ldr     r2, [fp, #-28]
        mov     r3, r2
        lsl     r3, r3, #2
        add     r3, r3, r2
        lsl     r3, r3, #1
        add     r3, r3, r1
        lsl     r3, r3, #2
        sub     r2, fp, #4
        add     r3, r2, r3

        ldr     r1, [r3, #-428]
        ldr     r3, [fp, #-12]
        add     r2, r3, #1
        mov     r3, r2
        lsl     r3, r3, #2
        add     r3, r3, r2
        lsl     r3, r3, #1
        ldr     r2, [fp, #-16]
        add     r3, r3, r2
        lsl     r3, r3, #2
        sub     r2, fp, #4
        add     r3, r2, r3
        ldr     r3, [r3, #-428]
        cmp     r1, r3		@ compare the two values random and user value
        beq     userInput	@if they are equal then branch to userInput
        ldr     r1, [fp, #-436]
        ldr     r2, [fp, #-28]
        mov     r3, r2
        lsl     r3, r3, #2
        add     r3, r3, r2
        lsl     r3, r3, #1
        ldr     r2, [fp, #-16]
        add     r3, r3, r2
        lsl     r3, r3, #2
        sub     r2, fp, #4
        add     r3, r2, r3
        ldr     r3, [r3, #-428]
        cmp     r1, r3		@ compares the two values random and user
        beq     userInput	@ if equal then branch to userInput

        ldr     r1, [fp, #-436]
        ldr     r2, [fp, #-28]
        mov     r3, r2
        lsl     r3, r3, #2
        add     r3, r3, r2
        lsl     r3, r3, #1
        add     r3, r3, r1
        lsl     r3, r3, #2
        sub     r2, fp, #4
        add     r3, r2, r3
        ldr     r1, [r3, #-428]
        ldr     r3, [fp, #-12]
        add     r2, r3, #3
        mov     r3, r2
        lsl     r3, r3, #2
        add     r3, r3, r2
        lsl     r3, r3, #1
        ldr     r2, [fp, #-16]
        add     r3, r3, r2
        lsl     r3, r3, #2
        sub     r2, fp, #4
        add     r3, r2, r3
        ldr     r3, [r3, #-428]
        cmp     r1, r3		@compare last comaprison to see if random+4 = user #
        bne     missed		@branch if not equal to missed
userInput:
@ print hit and then breaks and branches to break
        ldr     r0, strAddr+24
        bl      printf
        b       break
missed:
@ goes to print miss message and then ask prompy again
        ldr     r0, strAddr+28
        bl      puts
        nop
tryAgain:
@ since missed will let you try again until a hit
        bl      getchar
        mov     r3, r0
        cmp     r3, #10
        beq     resetNum
        mov     r3, #1
        b       compare
resetNum:
	mov	r3, #0
compare:
@ compare getchar() and eof with ch
        strb    r3, [fp, #-29]
        ldrb    r3, [fp, #-29]
        cmp     r3, #0
        bne     tryAgain
compareAndTry:
@ Compare input with random placement
        ldr     r3, [fp, #-20]
        cmp     r3, #0
        beq     whileLoop
break:
@epilogue
        mov     r3, #0
        mov     r0, r3
        sub     sp, fp, #4
        pop     {fp, pc}
@ Addresses of messages
        .align  2
strAddr:
        .word   hintMsg		@ prints string
        .word   promptMsg	@ prints string
        .word   columnResponse	@ prints string
        .word   errorMsg	@ prints string
        .word   rowResponse	@ prints string
        .word   userAnswer	@ prints string
        .word   hitMsg		@ prints string
        .word   missMsg		@ prints string
@Program Code
	.size   main, .-main
        .align  2
        .global nsew
        .syntax unified
        .arm
        .fpu vfp
        .type   nsew, %function
nsew:
@ Orientates the ship at random ethier north and south or east and west
        push    {fp, lr}	@push on to stack
        add     fp, sp, #4	@ establish sp
        sub     sp, sp, #8	@ use sp to navigate
        bl      rand		@ branch link to rand
        str     r0, [fp, #-8]	@ store in r0
        ldr     r3, [fp, #-8]	@ load register 3
        cmp     r3, #0		@ compare and if 0 then orientation is ns
        and     r3, r3, #1	@ and if one then orientation ew
        rsblt   r3, r3, #0	@ not really sure how this works
        str     r3, [fp, #-12]
        ldr     r3, [fp, #-12]
        mov     r0, r3		@ whatever the orientation is move in to r0
        sub     sp, fp, #4
        pop     {fp, pc}
@Program Code
	.size   nsew, .-nsew
        .align  2
        .global placementC
        .syntax unified
        .arm
        .fpu vfp
        .type   placementC, %function
placementC:
@ defines function of placing boat on random column
        push    {fp, lr}	@ push on
        add     fp, sp, #4	@ est. sp and amount of memory
        sub     sp, sp, #16	@ sp is at 16
        str     r0, [fp, #-16]
        ldr     r3, [fp, #-16]
        cmp     r3, #0
        bne     randomC
        bl      rand
        mov     r2, r0
        ldr     r3, randomRangeC
        smull   r1, r3, r3, r2
        asr     r1, r3, #2
        asr     r3, r2, #31
        sub     r1, r1, r3
        mov     r3, r1
        lsl     r3, r3, #2
        add     r3, r3, r1
        lsl     r3, r3, #1
        sub     r3, r2, r3
        str     r3, [fp, #-8]
        b       foundNumC
randomC:
@ defines random statments to find column
        bl      rand
        mov     r2, r0
        ldr     r3, randomRangeC+4
        smull   r3, r1, r3, r2
        asr     r3, r2, #31
        sub     r1, r1, r3
        mov     r3, r1
        lsl     r3, r3, #1
        add     r3, r3, r1
        lsl     r3, r3, #1
        sub     r3, r2, r3
        str     r3, [fp, #-8]
foundNumC:
@ find random column and assign
        ldr     r3, [fp, #-8]
        mov     r0, r3
        sub     sp, fp, #4
        pop     {fp, pc}
randomRangeC:
@ range of random column
        .word   1717986919
        .word   715827883
@ Program code
	.size   placementC, .-placementC
        .align  2
        .global placementR
        .syntax unified
        .arm
        .fpu vfp
        .type   placementR, %function
placementR:
@ defines function to place boat on a random
        push    {fp, lr}
        add     fp, sp, #4
        sub     sp, sp, #16
        str     r0, [fp, #-16]
        ldr     r3, [fp, #-16]
        cmp     r3, #0
        bne     randomR
        bl      rand
        mov     r2, r0
        ldr     r3, randomRangeR
        smull   r3, r1, r3, r2
        asr     r3, r2, #31
        sub     r1, r1, r3
        mov     r3, r1
        lsl     r3, r3, #1
        add     r3, r3, r1
        lsl     r3, r3, #1
        sub     r3, r2, r3
        str     r3, [fp, #-8]
        b       foundNumR
randomR:
@ defines random statements to find row
        bl      rand
        mov     r2, r0
        ldr     r3, randomRangeR+4
        smull   r1, r3, r3, r2
        asr     r1, r3, #2
        asr     r3, r2, #31
        sub     r1, r1, r3
        mov     r3, r1
        lsl     r3, r3, #2
        add     r3, r3, r1
        lsl     r3, r3, #1
        sub     r3, r2, r3
        str     r3, [fp, #-8]
foundNumR:
@ Find Random Row and assign
        ldr     r3, [fp, #-8]
        mov     r0, r3
        sub     sp, fp, #4
        pop     {fp, pc}

	.align  2
randomRangeR:
@ random range row
        .word   715827883
        .word   1717986919
	.size   placementR, .-placementR
