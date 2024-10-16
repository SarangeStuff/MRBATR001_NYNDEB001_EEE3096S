/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns

main_loop:

    @load the default delay value
    LDR R6, LONG_DELAY_CNT
    LDR R0, GPIOA_BASE @loading the address of GPIOA

	@loading the input value from the GPIO
    LDR R1, [R0, #0x10]

	@check if the sw0 is pressed
    MOVS R3, #0x01
    ANDS R3, R1
    BEQ increment_by_2 @then increments by positioning of 2

	@check if the sw1 is pressed
    MOVS R3, #0x02
    ANDS R3, R1
    BEQ change_delay   @then increments by timing of 0.3s

	@check if the sw2 is pressed
    MOVS R3, #0x04
    ANDS R3, R1
    BEQ set_pattern_AA

	@check if the sw3 is pressed
    MOVS R3, #0x08
    ANDS R3, R1
    BEQ freeze

    B default_mode

increment_by_2:
    LSRS R2, R2, #2 @increments LED by 2.
    CMP R2, #0
    BNE write_leds
    MOVS R2, #0x80
    B write_leds

change_delay:
    LDR R6, SHORT_DELAY_CNT    @increments the timing to 0.3s
    B default_mode

set_pattern_AA:
    MOVS R2, #0xAA @if switch 2 is pressed,LED pattern is 0xAA
    B write_leds   @updating the LED patterm

freeze:
    LDR R1, [R0, #0x10]
    MOVS R3, #0x08
    ANDS R3, R1     @ When sw3 is pressed, the current pattern freezes
    BEQ freeze
    B main_loop

default_mode:
    LSRS R2, R2, #1 @this is where the default increment by one is happening every 0.7s
    CMP R2, #0
    BNE write_leds
    MOVS R2, #0x80  @ If all bits shifted out, reset to leftmost LED

write_leds:
    LDR R1, GPIOB_BASE
    STR R2, [R1, #0x14]

delay:
    SUBS R6, #1
    BNE delay
    B main_loop


@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
@ Updated delay values (for 48 MHz clock)
LONG_DELAY_CNT: 	.word 1400000  @ 0.7 seconds
SHORT_DELAY_CNT: 	.word 600000  @ 0.3 seconds
