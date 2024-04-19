	INCLUDE stm32l476xx_constants.s
	
	AREA    Move, CODE, READONLY
	EXPORT  MoveInit
	EXPORT	MoveUp
	EXPORT  MoveDown ; make functions visible to linker
	

	; When MoveUp or MoveDown is called, the motor is either moved clockwise or counterclockwise by 360 degrees.
	; Output pins will be A:B11, A':B12, B:B8, B':B9
		
MoveUp PROC
	PUSH {LR}
	MOV r3, #0x200 ; Determines range of motor
	
uploop
	;Moves motor up
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, #0x1B00
	ORR r1, #0xA00 ;A high, A' low, B low, B' high
	STR r1, [r0, #GPIO_ODR]
	BL movedelay
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, #0x1B00
	ORR r1, #0x900 ;A high, A' low, B high, B' low
	STR r1, [r0, #GPIO_ODR]
	BL movedelay
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, #0x1B00
	ORR r1, #0x1100 ;A low, A' high, B high, B' low
	STR r1, [r0, #GPIO_ODR]
	BL  movedelay
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, #0x1B00
	ORR r1, #0x1200 ;A low, A' high, B low, B' high
	STR r1, [r0, #GPIO_ODR]
	BL movedelay
	
	SUBS r3, r3, #0x1
	BPL uploop
	
	POP {LR}
	BX LR
	
	ENDP
		
MoveDown PROC
	PUSH {LR}
	MOV r3, #0x200 ; Determines range of motor
	
downloop ; moves wiper back
	;Wiper section
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, #0x1B00
	ORR r1, #0x1200 ;A low, A' high, B low, B' high
	STR r1, [r0, #GPIO_ODR]
	BL movedelay
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, #0x1B00
	ORR r1, #0x1100 ;A low, A' high, B high, B' low
	STR r1, [r0, #GPIO_ODR]
	BL movedelay
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, #0x1B00
	ORR r1, #0x900 ;A high, A' low, B high, B' low
	STR r1, [r0, #GPIO_ODR]
	BL movedelay
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, #0x1B00
	ORR r1, #0xA00 ;A high, A' low, B low, B' high
	STR r1, [r0, #GPIO_ODR]
	BL movedelay
	
	SUBS r3, r3, #0x1
	BPL downloop
	
	POP {LR}
	BX LR
	
	ENDP
		
		
movedelay
	PUSH{r2}
	MOV r2, #0x18000 ;initialize delay
delayinner
	SUBS r2, r2, #1 ;subtract 1
	BPL delayinner ;loop back if > 0
	POP{r2}
	BX LR
	
MoveInit PROC
	; Set GPIOB pins 8, 9, 11, 12 as output pins (Motor)
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_MODER]
	BIC r1, #0xFF0000
	BIC r1, #0xF000000
	ORR r1, #0x50000
	ORR r1, #0x1000000
	ORR r1, #0x400000
	STR r1, [r0, #GPIO_MODER]
	BX LR
	ENDP
	
	END
