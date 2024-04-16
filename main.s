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

	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	;
	;Variables used by the rest of the program
	MOV r5, #0x00000000
	MOV r6, #0x00000000 

	;using r7 as my working register
	;r7 now stores the current floor
while AND r7, r5, #0x000F0000
	; check if the current floor is a destination
	; or if it is called in the direction
	AND r8, r5, #0x00000001
	CMP r8, #0x1
	BNE downFlags
	BEQ upFlags
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
	BEQ upFloor

	;Update LEDs and character display here
	B while
downFlags
	AND r9, #0x00000000
	AND r9, r6, #0xF0
	LSR r9, #0x4 
	B midWhile	
	
upFlags
	AND r9, #0x00000000
	AND r9, r6, #0xF
	B midWhile	

openSesame
	BL doorOpen
	BL keypad
	BL doorClose
	
downFloor
	BL downloop
	;reset floor
	AND r5, #0xFFF0FFFF
	LSL r7, #0x09
	OR r5, r5, r7
	;turn on next floor
	;turn off previous destination and previous calls
	
upFloor
	BL uploop
	;reset floor
	AND r5, #0xFFF0FFFF
	LSL r7, #0x11
	ORR r5, r5, r7
	;turn on next floor
	;turn off previous destination and previous calls


	ENDP		
		
	
	ALIGN			

	AREA myData, DATA, READWRITE
	ALIGN
; Replace ECE1770 with your last name
str DCB "Main",0
	END
