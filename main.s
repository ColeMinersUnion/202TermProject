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
	
	IMPORT 	EXTI_Init
	IMPORT 	System_Clock_Init
	IMPORT 	UART2_Init
	IMPORT	USART2_Write
	IMPORT  MoveInit
	IMPORT  MoveUp
	IMPORT  MoveDown
	IMPORT  KeypadInit
	IMPORT  doorOpen
	IMPORT  doorClose
	IMPORT  SpeakerInit
	IMPORT  Speaker
	
	
	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	BL System_Clock_Init
	BL UART2_Init
	BL EXTI_Init				; necessary for interrupts

	;LDR r0, =str   ; First argument
	;MOV r1, #11    ; Second argument
	;BL USART2_Write
	
	;set a8, a9, a11, a12, a14, a15 as output
	LDR r0, =RCC_BASE ; enable clock of GPIOA/B/C
	LDR r1, [r0, #RCC_AHB2ENR]
	ORR r1, #0x7
	STR r1, [r0, #RCC_AHB2ENR]
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	ORR r1, #0x00000001			;set
	STR r1, [r0, #RCC_AHB2ENR]
	
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_MODER]
	BIC r1, #0x0000000C
	BIC r1, #0x03000000
	BIC r1, #0x00C00000
	BIC r1, #0x000F0000
	BIC r1, #0x0000FF00
	ORR r1, #0x00000004
	ORR r1, #0x01000000
	ORR r1, #0x00400000
	ORR r1, #0x00050000
	ORR r1, #0x0000D000
	ORR r1, #0x00000500	;set
	STR r1, [r0, #GPIO_MODER]
	
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_MODER]
	BIC r1, #0x000000C0
	BIC r1, #0xC0000000
	BIC r1, #0x00300000
	BIC r1, #0x0000F000
	BIC r1, #0x00000C00
	ORR r1, #0x00000040
	ORR r1, #0x40000000
	ORR r1, #0x00100000
	ORR r1, #0x00005000
	ORR r1, #0x00000400
	STR r1, [r0, #GPIO_MODER]
	;initializes the b pins for call lights (5, 6, 10, 15)
	
	

	;initialize move process
	BL MoveInit
	BL SpeakerInit
	;
	;Variables used by the rest of the program
	MOV r5, #0x00000001
	MOV r6, #0x00000000 
	MOV r7, #0x1

;;;;;;;;;;;; YOUR CODE GOES HERE	;;;;;;;;;;;;;;;;;;;

	
	
	BL KeypadInit
	BL MoveInit
		
	B while

	;Update LEDs and character display here
	;get floor and move onto the appropriate pins A8, A9, A11, A12
	;current floor is stored on r7
seven 
	LDR r0, =GPIOA_BASE     ;hardcoded output values
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, #0x1B00
	CMP r7, #0x8
	ORREQ r1, #0x800
	CMP r7, #0x4
	ORREQ r1, #0x300
	CMP r7, #0x2
	ORREQ r1, #0x200
	CMP r7, #0x1
	ORREQ r1, #0x100
	STR r1, [r0, #GPIO_ODR]	
	BX LR
	
direction
	;direction lights are a14, a15
	;r8 0x0 is down, r8 0x1 is up
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
 	BIC r1, #0x12
	CMP r8, #0x0
	ORREQ r1, #0x2
	CMP r8, #0x1
	ORREQ r1, #0x10
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

while
	; check if the current floor is a destination
	; or if it is called in the direction
	BL seven
	AND r8, r5, #0x00000001
	CMP r8, #0x1
	BNE downFlags
	B upFlags
midWhile
	AND r9, r9, r7
	CMP r9, r7
	BEQ openSesame

	AND r9, r5, #0x0000F000 ;checks main call buttons
	LSR r9, #0xC
	AND r9, r7
	CMP r9, r7
	BEQ openSesame
	
	AND r9, r6, #0x100      ;checks panic button
	CMP r9, #0x0
	BHI openSesame
	
	AND r9, r5, #0x10       ;checks open door button
	CMP r9, #0x0
	BHI openSesame
	
	LDR r0, =GPIOA_BASE     ;reset direction leds if still
	LDR r1, [r0, #GPIO_ODR]
 	BIC r1, #0x12
	STR r1, [r0, #GPIO_ODR]
	
	CMP r8, #0x1
	BEQ checkAbove
	B checkBelow

openSesame		;elevator determines door needs open
	BL seven
	BL callLights
	BL Speaker
	BL doorOpen
	BL callLights
	BL doorClose
	;update floor call lights
	BL clearFloor
	BL callLights
	B while		;back to start
	
downFloor
	BL callLights
	BL direction	;display direction
	BL MoveDown
	BIC r5, #0x10    ;clear open door
	;updates current floor
	LSR r7, #0x1
	B while
	
upFloor
	BL callLights
	BL direction	;display direction
	BL MoveUp
	BIC r5, #0x10    ;clear open door flag
	;updates current floor
	LSL r7, #0x1
	B while
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
	BIC r5, #0x8000 ;clears internal call
	BIC r6, #0x80   ;clears down call
	BX LR

clear3
	BIC r5, #0x4000  ;clear internal call
	CMP r8, #0x1
	BICEQ r6, #0x4   ;clear up call
	BICNE r6, #0x40  ;clear down call
	BX LR

clear2
	BIC r5, #0x2000
	CMP r8, #0x1
	BICEQ r6, #0x2   ;clear up call
	BICNE r6, #0x20  ;clear down call
	BX LR

clear1
	BIC r5, #0x1000
	CMP r8, #0x1
	BICEQ r6, #0x1   ;clear up call
	BX LR
	
checkAbove
	MOV r9, r5    ;load flags
	CMP r7, #0x8  ;if floor four change directions
	EORHS r5, #0x1
	BXHS LR
	LSR r9, #0xC  ;shift to be LSBs
	AND r9, #0xF  ;mask floor flags
	SUB r9, r9, r7 ;filter out lower floors
	SUBS r9, r9, r7
	BPL upFloor   ;if higher floors called up, move up
	MOV r9, r6    ;load up calls
	AND r9, #0x7  ;mask up calls
	CMP r9, #0x1  ;if any greater floor calls up
	BHI upFloor
	MOV r9, r6
	LSR r9, #0x4
	AND r9, #0xE
	SUB r9, r7
	SUBS r9, r7
	BPL upFloor
	EOR r5, #0x1   ;if no call above flip direcions
	
	B while
	
checkBelow
	MOV r9, r5     ;load flags
	CMP r7, #0x1   ;if floor one change direction and return
	EORLS r5, #0x1
	BXLS LR
	LSR r9, #0xC   ;shift internal calls to be LSBs
	AND r9, #0xF   ;mask flags
	BIC r9, r7     ;clear calls to higher floors
	BIC r9, r7, LSL #1
	BIC r9, r7, LSL #2
	CMP r9, #0x0   ;if any calls, go down
	BHI downFloor
	MOV r9, r6     ;check if any down flags below
	LSR r9, #0x4
	AND r9, #0xE
	BIC r9, r7     ;ignore higher floor calls down
	BIC r9, r7, LSL #1
	BIC r9, r7, LSL #2
	CMP r9, #0x0
	BHI downFloor
	MOV r9, r6	   ;look for up calls below
	AND r9, #0x7
	BIC r9, r7     ;ignore higher floor calls up
	BIC r9, r7, LSL #1
	CMP r9, #0x0
	BHI downFloor
	EOR r5, #0x1   ;if no calls, change direction
	
	B while
	
	
callLights
	LDR r0, =GPIOB_BASE			
	LDR r1, [r0, #GPIO_ODR]
	
	BIC r1, #0x8000	;should clear the bits for odr
	BIC r1, #0xE0
	
	;checks floor 4
	AND r3, r5, #0x8000  ;internal flag
	ORR r1, r3
	AND r3, r6, #0x80	 ;external flag
	LSL r3, #0x8
	ORR r1, r3
	
	;checks floor 3
	AND r3, r5, #0x4000
	LSR r3, #0x7
	ORR r1, r3
	AND r3, r6, #0x40
	LSL r3, #0x1
	ORR r1, r3
	AND r3, r6, #0x4
	LSL r3, #0x5
	ORR r1, r3
	
	;checks floor 2
	AND r3, r5, #0x2000
	LSR r3, #0x7
	ORR r1, r3
	AND r3, r6, #0x20
	LSL r3, #0x1
	ORR r1, r3
	AND r3, r6, #0x2
	LSL r3, #0x5
	ORR r1, r3
	
	;checks floor 1
	AND r3, r5, #0x1000
	LSR r3, #0x7
	ORR r1, r3
	AND r3, r6, #0x1
	LSL r3, #0x5
	ORR r1, r3
	
	STR r1, [r0, #GPIO_ODR]		;turn them on
	BX LR
	
	
	ENDP		
		
	
	ALIGN			

	AREA myData, DATA, READWRITE
	ALIGN
str DCB "Main",0
	END
	ENDP
	ALIGN			

	AREA    myData, DATA, READWRITE
	ALIGN
;str	DCB   "Levine\r\n", 0

	END
