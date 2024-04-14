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
		
	;enable clocks for C (door motor)
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	AND r1, #0xFFFFFFFB			;clear
	ORR r1, #0x00000004			;set
	STR r1, [r0, #RCC_AHB2ENR]
	
	;configure c to digital out for motor control, pins c5, 6, 8, 9 
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_MODER]
	AND r1, #0x00000000		;clear
	ORR r1, #0x00000005		;r1 = 0005	;this is all due to size constraints on immediates
	LSL r1, #4				;r1 = 0050
	ORR r1, #0x00000001		;r1 = 0051
	LSL r1, #4		;r1 = 00510
	ORR r1, #00000004	;r1 = 00514
	LSL r1, #8		;r1 = 51400
	;pins 5, 6, 8, 9
	STR r1, [r0, #GPIO_MODER]
	
	;delay loop, holds for some amount of time
		MOV r1, #0x9999				;??
		;this line would compare for the close button and branch straight to motor
hold	CMP r1, #0
		BEQ close
		;if hold has been pressed r5, bit 0x00000010
		ORR r1, r5, #0x00000010		;isolate for just desired pin
		CMP r1, #0x00000010
		BEQ holdB
		SUB r1, #1
		B hold
	
close	MOV r2, #255		
comp1	CMP r2, #0
		BEQ stop

holdB		ORR r1, r5, #0x00000010		;isolate for desired pin
		CMP r1, #0x00000010
		BNE motor			;button is pressed
		CMP r2, #255	
		BEQ holdB		;door is already open, just check again
		B	comp2		;door is partially open, needs to be fully opened

motor		;branch to teraterm somehwere here?
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

delay	MOV r2, #0x999
ds		SUB r3, #1
		CMP r3, #0x0
		BNE ds
		BX LR
	
comp2	CMP r2, #0
		BEQ close			;door fully open, reload the number and check if button is still held
		
reverse		;branch to teraterm here
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


		

		SUB r2, #1			;decrement counter
		B comp2

	
	
stop 	B 		stop     		; dead loop

	ENDP
								

	AREA myData, DATA, READWRITE
	ALIGN

	END
