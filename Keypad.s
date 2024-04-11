	;INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s
		
	IMPORT USART2_Write
	
	AREA    Keypad, CODE, READONLY
	EXPORT	Keypad				; make __main visible to linker
	

	; For the purposes of the subroutine, if we don't want the program to wait for a button to be pressed then the B loop1 can instead branch to callee
	; r0 will contain pressed value (* = E, # = F)
	; Pin map: GPIOC(0, 1, 2, 3) as output, GPIOB(1, 2, 3, 4) as input
keypad PROC
	
	PUSH {r4, r5, r6, r7, r8, r9, r10, r11, LR}
	
loop1	; Pull all rows low
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, #0xF
	STR r1, [r0, #GPIO_ODR]
	BL delay
		; If all cols are 1, loop
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x1E
	CMP r1, #0x1E
	BEQ loop1
	
		; Pull row 1 low
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	MOV r1, #0xE
	STR r1, [r0, #GPIO_ODR]
	BL delay
		; If all cols are 1 continue, else branch
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x1E
	CMP r1, #0x1E
	BNE checkrow1
	
		; Pull row 2 low
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	MOV r1, #0xD
	STR r1, [r0, #GPIO_ODR]
	BL delay
		; If all cols are 1 continue, else branch
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x1E
	CMP r1, #0x1E
	BNE checkrow2
	
		; Pull row 3 low
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	MOV r1, #0xB
	STR r1, [r0, #GPIO_ODR]
	BL delay
		; If all cols are 1 continue, else branch
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x1E
	CMP r1, #0x1E
	BNE checkrow3
	
		; Pull row 4 low
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	MOV r1, #0x7
	STR r1, [r0, #GPIO_ODR]
	BL delay
		; If all cols are 1 continue, else branch
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x1E
	CMP r1, #0x1E
	BNE checkrow4
	B loop1
	
checkrow1

		LDR r7, =GPIOB_BASE
		LDR r1, [r7, #GPIO_IDR] ; Load input
		
		MOV r2, #0x2 		; Compare to col 1
		AND r3, r1, r2
		CMP r3, #0x0		; If low, move char, wait for unpress, and display
		MOVEQ r0, #0x1
		LDREQ r0, =char1
		BLEQ wait
		
		MOV r2, #0x4		; Compare to col 2
		AND r3, r1, r2
		CMP r3, #0x0		; If low, move char, wait for unpress, and display
		MOVEQ r0, #0x2
		BLEQ wait
		
		MOV r2, #0x8
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 3
		MOVEQ r0, #0x3
		BLEQ wait			; If low, move char, wait for unpress, and display
		
		MOV r2, #0x10
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 4
		MOVEQ r0, #0xA
		BLEQ wait			; If low, move char, wait for unpress, and display
		
		B loop1
		
checkrow2

		LDR r7, =GPIOB_BASE
		LDR r1, [r7, #GPIO_IDR]
		
		MOV r2, #0x2
		AND r3, r1, r2
		CMP r3, #0x0
		MOVEQ r0, #0x4
		BLEQ wait
		
		MOV r2, #0x4
		AND r3, r1, r2
		CMP r3, #0x0
		MOVEQ r0, #0x5
		BLEQ wait
		
		MOV r2, #0x8
		AND r3, r1, r2
		CMP r3, #0x0
		MOVEQ r0, #0x6
		BLEQ wait
		
		MOV r2, #0x10
		AND r3, r1, r2
		CMP r3, #0x0
		MOVEQ r0, #0xB
		BLEQ wait
		
		B loop1
		
checkrow3

		LDR r7, =GPIOB_BASE
		LDR r1, [r7, #GPIO_IDR] ; Load input
		
		MOV r2, #0x2 		; Compare to col 1
		AND r3, r1, r2
		CMP r3, #0x0		; If low, move char, wait for unpress, and display
		MOVEQ r0, #0x7
		BLEQ wait
		
		MOV r2, #0x4		; Compare to col 2
		AND r3, r1, r2
		CMP r3, #0x0		; If low, move char, wait for unpress, and display
		MOVEQ r0, #0x8
		BLEQ wait
		
		MOV r2, #0x8
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 3
		MOVEQ r0, #0x9
		BLEQ wait			; If low, move char, wait for unpress, and display
		
		MOV r2, #0x10
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 4
		MOVEQ r0, #0xC
		BLEQ wait			; If low, move char, wait for unpress, and display
		
		B loop1
		
checkrow4

		LDR r7, =GPIOB_BASE
		LDR r1, [r7, #GPIO_IDR] ; Load input
		
		MOV r2, #0x2 		; Compare to col 1
		AND r3, r1, r2
		CMP r3, #0x0		; If low, move char, wait for unpress, and display
		MOVEQ r0, #0xE
		BLEQ wait
		
		MOV r2, #0x4		; Compare to col 2
		AND r3, r1, r2
		CMP r3, #0x0		; If low, move char, wait for unpress, and display
		MOVEQ r0, #0x0
		BLEQ wait
		
		MOV r2, #0x8
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 3
		MOVEQ r0, #0xF
		BLEQ wait			; If low, move char, wait for unpress, and display
		
		MOV r2, #0x10
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 4
		MOVEQ r0, #0xD
		BLEQ wait			; If low, move char, wait for unpress, and display
		
		B loop1
	
		
displaykey
	STR	r5, [r8]
	;LDR r0, =str   ; First argument
	MOV r1, #1    ; Second argument
	BL USART2_Write
	
	B loop1	
	
	ENDP
	
wait	; Wait until col becomes high
		LDR r7, =GPIOB_BASE
		LDR r1, [r7, #GPIO_IDR]
		AND r1, r1, r2	; mask col pin, will be 0 if low
		CMP r1, #0x0		; if col low, loop
		BEQ wait
		B displaykey
		POP {r4, r5, r6, r7, r8, r9, r10, r11, LR}
		BX LR

	
		

delay	PROC
	; Delay for software debouncing
	LDR	r2, =0x9999
delayloop
	SUBS	r2, #1
	BNE	delayloop
	BX LR
	ENDP
		
		
	ALIGN 		

	AREA myData, DATA, READWRITE
		
char0	DCD 48
char1	DCD	49
char2	DCD 50
char3	DCD 51
char4	DCD 52
char5	DCD 53
char6	DCD 54
char7	DCD 55
char8	DCD 56
char9	DCD 57
charA	DCD 65
charB	DCD 66
charC	DCD 67
charD	DCD 68
charE	DCD 69
charF	DCD 70
charAST DCD 42
charPND DCD 35
	
		
	END