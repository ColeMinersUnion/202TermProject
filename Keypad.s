	;INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s
		
	IMPORT USART2_Write
	IMPORT UART2_Init
	
	AREA    Keypad, CODE, READONLY
	EXPORT	Keypad				; make __main visible to linker
	

	; r0 will contain pressed value (* = E, # = F)
	; Pin map: GPIOC(0, 1, 2, 3) as output, GPIOB(1, 2, 3, 4) as input
keypad PROC
	
	PUSH{LR}
	
	; Pull all rows low
	LDR r7, =GPIOB_BASE
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
	BXEQ LR
	
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
	BX LR  ; ellse exit
	
wait	; Wait until col becomes high
	;LDR r7, =GPIOB_BASE
	LDR r1, [r7, #GPIO_IDR]
	AND r1, r1, r2	; mask col pin, will be 0 if low
	CMP r1, #0x0		; if col low, loop
	BEQ wait
	;BL UART2_Init
	MOV r1, #1    ; Second argument
	BL USART2_Write
	POP{LR}
	BX LR
		
checkrow1

		;LDR r7, =GPIOB_BASE
		LDR r1, [r7, #GPIO_IDR] ; Load input
		
		MOV r2, #0x2 		; Compare to col 1
		AND r3, r1, r2
		CMP r3, #0x0		; If low, move char, wait for unpress, and display
		;MOVEQ r5, #0x1
		MOV r0, #0x1   ; First argument
		BEQ wait
		
		MOV r2, #0x4		; Compare to col 2
		AND r3, r1, r2
		CMP r3, #0x0		; If low, move char, wait for unpress, and display
		MOVEQ r0, #0x2
		BEQ wait
		
		MOV r2, #0x8
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 3
		MOVEQ r0, #0x3
		BEQ wait			; If low, move char, wait for unpress, and display
		
		MOV r2, #0x10
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 4
		MOVEQ r0, #0xA
		BEQ wait			; If low, move char, wait for unpress, and display
		
		BX LR
		
checkrow2

		;LDR r7, =GPIOB_BASE
		LDR r1, [r7, #GPIO_IDR]
		
		MOV r2, #0x2
		AND r3, r1, r2
		CMP r3, #0x0
		MOVEQ r0, #0x4
		BEQ wait
		
		MOV r2, #0x4
		AND r3, r1, r2
		CMP r3, #0x0
		MOVEQ r0, #0x5
		BEQ wait
		
		MOV r2, #0x8
		AND r3, r1, r2
		CMP r3, #0x0
		MOVEQ r0, #0x6
		BEQ wait
		
		MOV r2, #0x10
		AND r3, r1, r2
		CMP r3, #0x0
		MOVEQ r0, #0xB
		BEQ wait
		
		BX LR
		
checkrow3

		;LDR r7, =GPIOB_BASE
		LDR r1, [r7, #GPIO_IDR] ; Load input
		
		MOV r2, #0x2 		; Compare to col 1
		AND r3, r1, r2
		CMP r3, #0x0		; If low, move char, wait for unpress, and display
		MOVEQ r0, #0x7
		BEQ wait
		
		MOV r2, #0x4		; Compare to col 2
		AND r3, r1, r2
		CMP r3, #0x0		; If low, move char, wait for unpress, and display
		MOVEQ r0, #0x8
		BEQ wait
		
		MOV r2, #0x8
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 3
		MOVEQ r0, #0x9
		BEQ wait			; If low, move char, wait for unpress, and display
		
		MOV r2, #0x10
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 4
		MOVEQ r0, #0xC
		BEQ wait			; If low, move char, wait for unpress, and display
		
		BX LR
		
checkrow4

		;LDR r7, =GPIOB_BASE
		LDR r1, [r7, #GPIO_IDR] ; Load input
		
		MOV r2, #0x2 		; Compare to col 1
		AND r3, r1, r2
		CMP r3, #0x0		; If low, move char, wait for unpress, and display
		MOVEQ r0, #0xE
		BEQ wait
		
		MOV r2, #0x4		; Compare to col 2
		AND r3, r1, r2
		CMP r3, #0x0		; If low, move char, wait for unpress, and display
		MOVEQ r0, #0x0
		BEQ wait
		
		MOV r2, #0x8
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 3
		MOVEQ r0, #0xF
		BEQ wait			; If low, move char, wait for unpress, and display
		
		MOV r2, #0x10
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 4
		MOVEQ r0, #0xD
		BEQ wait			; If low, move char, wait for unpress, and display
		
		BX LR
	
	ENDP
	


	
		

delay	PROC
	; Delay for software debouncing
	LDR	r2, =0x9999
delayloop
	SUBS	r2, #1
	BNE	delayloop
	BX LR
	ENDP
		
	END
