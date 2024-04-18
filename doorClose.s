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

;this program is called when the elevator arrives at the floor and after it is ready to leave
	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      


	IMPORT 	System_Clock_Init
	IMPORT 	UART2_Init
	IMPORT	USART2_Write
	
	AREA    doorClose, CODE, READONLY
	EXPORT	doorClose				; make __main visible to linker
	ENTRY			
				
doorclose	PROC
	PUSH {LR}
	;enable clocks for C (door motor)
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
	
	;delay loop, holds for some amount of time
		MOV r2, #0x80       ; range of motor
		MOV r1, #0x1000000	; delay before door closes
		BIC r5, #0x20       ; disable close door
		;this line would compare for the close button and branch straight to motor
hold	CMP r1, #0
		BEQ close
		;if hold has been pressed r5, bit 0x00000010
		AND r0, r5, #0x20 ;check close door
		CMP r0, #0x20
		MOVEQ r1, #0x10000
		BIC r5, #0x20
		
		AND r0, r5, #0x00000010		;mask hold door pin
		CMP r0, #0x00000010
		BEQ holdB
		SUB r1, #1
		B hold
	
close	MOV r2, #0x80
comp1	CMP r2, #0
		POPMI {LR} ; return
		BXMI LR

holdB		AND r1, r5, #0x00000010		;isolate for desired pin
		CMP r1, #0x00000010
		BNE motor			;button is pressed
		CMP r2, #0x80	; if door closed
		BICEQ r5, 0x10	; clear hold door
		MOVEQ r1, #0x2000000 ; load longer wait
		BEQ hold		;door is already open, just check again
		B	comp2		;door is partially open, needs to be fully opened

motor		
		;BL display
		LDR r0, =GPIOC_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000220	;first step, AB'
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]
		
		LDR r0, =GPIOC_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000060	;second step, AB
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]

		
		LDR r0, =GPIOC_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000140	;third step, A'B
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]


		
		LDR r0, =GPIOC_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000300	;third step, A'B'
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]


		
		SUB r2, #1			;decrement counter
		B comp1				;see if done yet

delay	MOV r3, #0x10000    ; general delay between motor ticks
ds		SUB r3, #1
		CMP r3, #0x0
		BNE ds
		BX LR
	
comp2	CMP r2, #0x80         ; if door is fully open
		MOVPL r1, #0x2000000  ; load longer wait
		BICPL r5, #0x10       ; clear hold request
		BPL hold			; proceed to close, else reopen door
		
reverse		
		;BL display ;opening ;branch to teraterm here
		LDR r0, =GPIOC_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000140	;first step, A'B
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]


		
		LDR r0, =GPIOC_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000060	;second step, AB
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]


		
		LDR r0, =GPIOC_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000220	;third step, AB'
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]


		
		LDR r0, =GPIOC_BASE
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, #0x00000300	;third step, A'B'
		STR r1, [r0, #GPIO_ODR]
		BL delay
		AND r1, #0x00000000	;reset
		STR r1, [r0, #GPIO_ODR]


		

		ADD r2, #1			;decrement counter
		B comp2
		
display
	LDR r0, =str   ; First argument
	MOV r1, #9    ; Second argument
	PUSH {LR}
	BL USART2_Write
	POP {LR}
	BX LR

	ENDP
								

	AREA myData, DATA, READWRITE
	ALIGN
str DCB	"Closing\r\n", 0

	END
