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


	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	IMPORT 	System_Clock_Init
	IMPORT 	UART2_Init
	IMPORT	USART2_Write
	
	IMPORT doorOpen  ;Changed some code in callum's files
	IMPORT doorClose
	IMPORT MoveUp
	IMPORT MoveDown
	IMPORT MoveInit
	IMPORT KeypadInit

	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	;set a8, a9, a11, a12, a14, a15 as output
	;set b10, 5, 6 15 as output
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	ORR r1, #0x00000007			;set
	STR r1, [r0, #RCC_AHB2ENR]
	
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_MODER]
	ORR r1, #0x0000DB00	;set
	STR r1, [r0, #GPIO_MODER]
	
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_MODER]
	ORR r1, #0x00008460	;set
	STR r1, [r0, #GPIO_MODER]
	
	

	;initialize move process
	BL MoveInit
	BL KeypadInit
	;
	;Variables used by the rest of the program
	MOV r5, #0x00000000
	MOV r6, #0x00000000 

	;using r7 as my working register
	;r7 now stores the current floor
	
while AND r7, r5, #0x000F0000		;isolates for just current floor on 7
	; check if the current floor is a destination
	; or if it is called in the direction
	AND r8, r5, #0x00000001
	CMP r8, #0x1
	BNE downFlags
	B upFlags
midWhile
	;flags set onto r9
	LSR r7, #0x10
	AND r9, r9, r7
	CMP r9, r7
	BEQ openSesame

	AND r9, r5, #0x0000F000
	LSR r9, #0xC
	CMP r9, r7
	BEQ openSesame

	CMP r8, #0x1
	BNE downFloor
	B upFloor

	;Update LEDs and character display here
	;get floor and move onto the appropriate pins A8, A9, A11, A12
	;current floor is stored on r7
seven 
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	ORR r2, r7, #0x00000003	;store first two bits of interest
	LSL r2, #0x8			;move from bits 1,0 to bits 8,9
	ORR r1, r2				;store bits onto 8,9 of r1
	AND r2, #0x0			;reclear
	ORR r2, r7, #0x0000000C	;store second two bits of interest
	LSL r2, #0x9			;move bits 2,3 to 11,12
	ORR r1, r2				;store bits onto 11,12 of r1
	STR r1, [r0, #GPIO_ODR]	;store onto odr
	BX LR
	;this should update the seven segment display
	
direction
	;direction lights are a14, a15
	;r8 0x0 is down, r8 0x1 is up
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	CMP r8, #0x0
	BEQ downlight
	CMP r8, #0x1
	BEQ uplight
	
downlight
	ORR r1, #0x00008000
	STR r1, [r0, #GPIO_ODR]
	BX LR
	
uplight
	ORR r1, #0x00004000
	STR r1, [r0, #GPIO_ODR]
	BX LR
	
	
	
downFlags
	AND r9, #0x00000000
	AND r9, r6, #0xF0
	LSR r9, #0x4 
	B midWhile	
	
upFlags
	AND r9, #0x00000000
	AND r9, r6, #0xF
	B midWhile	

openSesame		;for when elevator lands on a floor
	BL seven
	BL doorOpen
	;BL keypad ;dont think this is necessary
	BL doorClose	;delay built in to doorClose, no need
	;update floor call lights
	BL callLights
	B while		;back to start
	
downFloor
	BL direction	;display direction
	BL MoveDown
	;updates current floor 
	AND r5, #0xFFF0FFFF
	LSL r7, #0x9
	ORR r5, r5, r7
	BL clearFloor
	;turn on next floor
	;turn off previous destination and previous calls
	
upFloor
	BL direction	;display direction
	BL MoveUp
	;updates current floor
	AND r5, #0xFFF0FFFF
	LSL r7, #0x11
	ORR r5, r5, r7
	BL clearFloor
	;turn on next floor
	;turn off previous destination and previous calls

clearFloor
	AND r2, r7, #0x0000000F	;isolate for just location bits
	CMP r2, #0x0000008
	BEQ clear4
	CMP r2, #0x0000004
	BEQ clear3
	CMP r2, #0x0000002
	BEQ clear2
	CMP r2, #0x0000001
	BEQ clear1
	BX LR
	
clear4
	AND r5, #0xFFF7FFFF
	BX LR

clear3
	AND r5, #0xFFFBFFFF
	BX LR

clear2
	AND r5, #0xFFFDFFFF
	BX LR

clear1
	AND r5, #0xFFFEFFFF
	BX LR
	

	
callLights
	MOV r3, #0x0
	AND r3, r6, #0x00000080	;check if fl4 is called
	LSL r3, #0x4
	AND r3, r6, #0x00000040	;check if fl3 called
	LSL r3, #0x3
	AND r3, r6, #0x00000020	;check if fl2 called
	LSL r3, #0x1
	AND r3, r6, #0x00000010	;check if fl1 called
	;all called floors stored on correct spot on r3 now
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	AND r1, #0x7B9F		;clears led bits from ODR
	ORR r1, r3			;enables bits that are called
	STR r1, [r0, #GPIO_ODR]		;turn them on
	BX LR
	
	
	
	ENDP		
		
	
	ALIGN			

	AREA myData, DATA, READWRITE
	ALIGN
; Replace ECE1770 with your last name
str DCB "Main",0
	END
