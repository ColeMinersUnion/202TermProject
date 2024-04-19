	INCLUDE stm32l476xx_constants.s
	
	AREA    speaker, CODE, READONLY
	EXPORT	Speaker				; make speaker visible to linker
	EXPORT  SpeakerInit
	
Speaker PROC
	
	LDR r0, =GPIOC_BASE
	MOV r3, #0x100
speakerLoop1
	LDR r1, [r0, #GPIO_ODR]
	EOR r1, #0x400
	STR r1, [r0, #GPIO_ODR]
	SUBS r3, #0x1
	BPL speakerDelay1
	MOV r3, #0x100
speakerLoop2
	LDR r1, [r0, #GPIO_ODR]
	EOR r1, #0x400
	STR r1, [r0, #GPIO_ODR]
	SUBS r3, #0x1
	BPL speakerDelay2
	MOV r3, #0x300
speakerLoop3
	LDR r1, [r0, #GPIO_ODR]
	EOR r1, #0x400
	STR r1, [r0, #GPIO_ODR]
	SUBS r3, #0x1
	BPL speakerDelay3
	BX LR
	
	ENDP

speakerDelay1
	;MOV r2, #10000
	MOV r2, #20000    ;6.6khz = 2000 
	;MOV r2, #40000
speakerDelayLoop1
	SUBS r2, #0x1
	BPL speakerDelayLoop1
	B speakerLoop1
speakerDelay2
	;MOV r2, #5952
	MOV r2, #11904    ;6.6khz = 2000 
	;MOV r2, #23809
speakerDelayLoop2
	SUBS r2, #0x1
	BPL speakerDelayLoop2
	B speakerLoop2
speakerDelay3
	;MOV r2, #6666
	MOV r2, #13333    ;6.6khz = 2000 
	;MOV r2, #26666
speakerDelayLoop3
	SUBS r2, #0x1
	BPL speakerDelayLoop3
	B speakerLoop3

SpeakerInit PROC
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_MODER]
	BIC r1, #0x300000
	ORR r1, #0x100000
	STR r1, [r0, #GPIO_MODER]
	BX LR
	ENDP
		
	END
