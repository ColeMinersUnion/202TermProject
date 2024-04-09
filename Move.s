	AREA    Move, CODE, READONLY
	EXPORT	Move				; make __main visible to linker
	

	; When MoveUp or MoveDown is called, the motor is either moved clockwise or counterclockwise by 360 degrees.
	; Output pins will be A:A2, A':A3, B:A6, B':A7
MoveUp PROC
	
	MOV r3, #0x100 ; Determines range of motor
	
uploop
	;Moves motor up
	LDR r0, =GPIOA_BASE
	MOV r1, #0x84 ;A high, A' low, B low, B' high
	STR r1, [r0, #GPIO_ODR]
	BL movedelay
	LDR r0, =GPIOA_BASE
	MOV r1, #0x44 ;A high, A' low, B high, B' low
	STR r1, [r0, #GPIO_ODR]
	BL movedelay
	LDR r0, =GPIOA_BASE
	MOV r1, #0x48 ;A low, A' high, B high, B' low
	STR r1, [r0, #GPIO_ODR]
	BL  movedelay
	LDR r0, =GPIOA_BASE
	MOV r1, #0x88 ;A low, A' high, B low, B' high
	STR r1, [r0, #GPIO_ODR]
	BL movedelay
	
	SUBS r3, r3, #0x1
	BPL uploop
	
	ENDP
		
MoveDown PROC
	
	MOV r3, #0x100 ; Determines range of motor
	
downloop ; moves wiper back
	;Wiper section
	LDR r0, =GPIOA_BASE
	MOV r1, #0x88 ;A high, A' low, B low, B' high
	STR r1, [r0, #GPIO_ODR]
	BL movedelay
	LDR r0, =GPIOA_BASE
	MOV r1, #0x48 ;A high, A' low, B high, B' low
	STR r1, [r0, #GPIO_ODR]
	BL movedelay
	LDR r0, =GPIOA_BASE
	MOV r1, #0x44 ;A low, A' high, B high, B' low
	STR r1, [r0, #GPIO_ODR]
	BL movedelay
	LDR r0, =GPIOA_BASE
	MOV r1, #0x84 ;A low, A' high, B low, B' high
	STR r1, [r0, #GPIO_ODR]
	BL movedelay
	
	SUBS r3, r3, #0x1
	BPL downloop
	
	ENDP
		
		
movedelay
	PUSH{r2}
	MOV r2, #0x999 ;initialize delay
movedelayinner
	SUBS r2, r2, #1 ;subtract 1
	BPL delayinner ;loop back if > 0
	POP{r2}
	BX LR
	
	END