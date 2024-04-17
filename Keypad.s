	INCLUDE stm32l476xx_constants.s
	
	AREA    Keypad, CODE, READONLY
	EXPORT	Keypad				; make __main visible to linker
	EXPORT  KeypadInit
	

	; Corresponding flag will be updated after completion
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
	POPEQ {LR} ;temp
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
	POP {LR}
	BX LR  ; else exit
	
wait	; Wait until col becomes high
	;LDR r7, =GPIOB_BASE
	;LDR r1, [r7, #GPIO_IDR]
	;AND r1, r1, r2	; mask col pin, will be 0 if low
	;CMP r1, #0x0		; if col low, loop
	;BEQ wait
	BL delay
	LDR r0, =GPIOC_BASE    ; Reset all rows
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, #0xF
	STR r1, [r0, #GPIO_ODR]
	POP{LR}
	BX LR
		
checkrow1

		LDR r1, [r7, #GPIO_IDR] ; Load input
		
		MOV r2, #0x2 		; Compare to col 1
		AND r3, r1, r2
		CMP r3, #0x0		; If low, update flag, wait for unpress, exit interrupt
		ORREQ r5, #0x1000    ; Update floor 1 flag
		BEQ wait
		
		MOV r2, #0x4		; Compare to col 2
		AND r3, r1, r2
		CMP r3, #0x0		
		ORREQ r5, #0x2000   ; Update floor 2 flag
		BEQ wait
		
		MOV r2, #0x8
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 3
		ORREQ r5, #0x4000   ; Update floor 3 flag
		BEQ wait			
		
		MOV r2, #0x10
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 4
		ORREQ r5, #0x8000
		BEQ wait			
		
		BX LR
		
checkrow2

		LDR r1, [r7, #GPIO_IDR]
		
		MOV r2, #0x2
		AND r3, r1, r2
		CMP r3, #0x0
		ORREQ r6, #0x1  ; Up flag floor 1
		BEQ wait
		
		MOV r2, #0x4
		AND r3, r1, r2
		CMP r3, #0x0
		ORREQ r6, #0x2 ; Up flag floor 2
		BEQ wait
		
		MOV r2, #0x8
		AND r3, r1, r2
		CMP r3, #0x0
		ORREQ r6, #0x4 ; Up flag floor 3
		BEQ wait
		
		MOV r2, #0x10
		AND r3, r1, r2
		CMP r3, #0x0
		ORREQ r6, #0x80 ; Down flag floor 4
		BEQ wait
		
		BX LR
		
checkrow3

		LDR r1, [r7, #GPIO_IDR] ; Load input
		
		MOV r2, #0x2 		; Compare to col 1
		AND r3, r1, r2
		CMP r3, #0x0		; If low, update flag, wait for unpress, exit interrupt
		; Unassigned button
		BEQ wait
		
		MOV r2, #0x4		; Compare to col 2
		AND r3, r1, r2
		CMP r3, #0x0		
		ORREQ r6, #0x20     ; Down flag floor 2
		BEQ wait
		
		MOV r2, #0x8
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 3
		ORREQ r6, #0x40     ; Down flag floor 3
		BEQ wait			
		
		MOV r2, #0x10
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 4
		; Unassigned button
		BEQ wait			
		
		BX LR
		
checkrow4

		LDR r1, [r7, #GPIO_IDR] ; Load input
		
		MOV r2, #0x2 		; Compare to col 1
		AND r3, r1, r2
		CMP r3, #0x0		; If low, update flag, wait for unpress, exit interrupt
		ORREQ r5, #0x10
		BEQ wait
		
		MOV r2, #0x4		; Compare to col 2
		AND r3, r1, r2
		CMP r3, #0x0		
		ORREQ r5, #0x20
		BEQ wait
		
		MOV r2, #0x8
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 3
		; Unassigned currently, Panic
		BEQ wait			
		
		MOV r2, #0x10
		AND r3, r1, r2
		CMP r3, #0x0		; Compare to col 4
		; Unassigned currently, Admin
		BEQ wait			
		
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
	
KeypadInit PROC
	
	LDR r0, =GPIOC_BASE ; set pins C0, 1, 2, 3 as output (Keypad)
	LDR r1, [r0, #GPIO_MODER]
	BIC r1, #0xFF
	ORR r1, #0x55
	STR r1, [r0, #GPIO_MODER]
	
	LDR r0, =GPIOB_BASE ; set pins B1, 2, 3, 4 as input (Keypad)
	LDR r1, [r0, #GPIO_MODER]
	BIC r1, #0x300
	BIC r1, #0xFF
	STR r1, [r0, #GPIO_MODER]
	
	BX LR
	ENDP

	END
