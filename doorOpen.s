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

;this be the program that run when the elevator arriveth at a floor, pressing destination floor would cause an interupt that stores floor on stakc and then -after- this is done would go to said floor
;this section does nothing if the elevator is in motion
	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      


	IMPORT 	System_Clock_Init
	IMPORT 	UART2_Init
	IMPORT	USART2_Write
	
	AREA    doorOpen, CODE, READONLY
	EXPORT	doorOpen				; make __main visible to linker
	ENTRY		
				
dooropen	PROC
	PUSH {LR}
	BL UART2_Init
	BL display
	;terraterm here opening
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	AND r1, #0xFFFFFFFB			;clear
	ORR r1, #0x00000004			;set
	STR r1, [r0, #RCC_AHB2ENR]
	
	;configure c to digital out for motor control, pins c5, 6, 8, 9 
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_MODER]
	BIC r1, #0xF0000
	BIC r1, #0x3000
	BIC r1, #0xC00
	ORR r1, #0x50000
	ORR r1, #0x1000
	ORR r1, #0x400
	;pins 5, 6, 8, 9
	STR r1, [r0, #GPIO_MODER]	
	
	
close	MOV r2, #0x80		
comp1	CMP r2, #0
		POPEQ {LR}
		BXEQ LR
		
motor		;branch to teraterm somehwere here???
		;BL display
		LDR r0, =GPIOC_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000300	;first step, A'B'
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]
		
		LDR r0, =GPIOC_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000140	;second step, A'B
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]

		
		LDR r0, =GPIOC_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000060	;third step, AB
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]

		LDR r0, =GPIOC_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000220	;fourth step, AB'
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]
		
		SUB r2, #1			;decrement counter
		B comp1				;see if done yet
		
delay	MOV r3, #0x10000
ds		SUB r3, #1
		CMP r3, #0x0
		BNE ds
		BX LR

display
	LDR r0, =str   ; First argument
	MOV r1, #1    ; Second argument
	PUSH {LR}
	BL USART2_Write
	POP {LR}
	BX LR

	ENDP
								

	AREA myData, DATA, READWRITE
	ALIGN
str DCB	"Opening\r\n", 0

	END
