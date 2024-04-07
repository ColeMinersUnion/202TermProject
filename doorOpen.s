;******************** (C) Yifeng ZHU *******************************************
; @file    main.s
; @author  Yifeng Zhu
; @date    May-17-2015
; @note
;           This code is for the book "Embedded Systems with ARM Cortex-M 
;           Microcontrollers in Assembly Language and C, Yifeng Zhu, 
;           ISBN-13: 978-0982692639, ISBN-10: 0982692633
; @attension
;           This code is provided for education purpose. The author shall not be 
;           held liable for any direct, indirect or consequential damages, for any 
;           reason whatever. More information can be found from book website: 
;           http:;www.eece.maine.edu/~zhu/book
;*******************************************************************************

;this be the program that run when the elevator arriveth at a floor, pressing destination floor would cause an interupt that stores floor on stakc and then -after- this is done would go to said floor\
;this section does nothing if the elevator is in motion
	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      


	IMPORT 	System_Clock_Init
	IMPORT 	UART2_Init
	IMPORT	USART2_Write
	
	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	AND r1, #0xFFFFFFFA			;clear
	ORR r1, #0x00000006			;set
	STR r1, [r0, #RCC_AHB2ENR]
	
	;configure b to digital out for motor control
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_MODER]
	AND r1, #0x0000		;clear
	ORR r1, #0x00000005		;r1 = 0005	;this is all due to size constraints on immediates
	LSL r1, #8				;r1 = 0500
	ORR r1, #0x00000005		;r1 = 0505
	LSL r1, #4				;r1 = 5050
	;pins 7, 6, 3, 2
	
close	MOV r2, #255		
comp1	CMP r2, #0
		BEQ stop
		
motor	LDR r0, =GPIOB_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000048	;first step, AB'
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]
		
		LDR r0, =GPIOB_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000044	;second step, AB
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]

		
		LDR r0, =GPIOB_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000084	;third step, A'B
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]


		
		LDR r0, =GPIOB_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000088	;third step, A'B'
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]
		
		SUB r2, #1			;decrement counter
		B comp1				;see if done yet
		
delay	MOV r2, #0x999
ds		SUB r3, #1
		CMP r3, #0x0
		BNE ds
		BX LR
		
		
stop 	B 		stop     		; dead loop

	ENDP
								

	AREA myData, DATA, READWRITE
	ALIGN

	END
