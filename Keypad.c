#include "stm32l476xx.h"

void EXTI_Init(void);
void EXTI1_IRQHandler(void);
void EXTI2_IRQHandler(void);
void EXTI3_IRQHandler(void);
void EXTI4_IRQHandler(void);
extern void Keypad(void);
//Initialize interrupts, based on textbook p. 264

void EXTI_Init(void)
{
	RCC -> APB2ENR |= RCC_APB2ENR_SYSCFGEN;
	
	//Set pin 1 of GPIOB as interrupt
	SYSCFG->EXTICR[0] &= ~SYSCFG_EXTICR1_EXTI1;
	SYSCFG->EXTICR[0] |= SYSCFG_EXTICR1_EXTI1_PB;
	SYSCFG->EXTICR[0] &= ~(0x000F);
	//Set pin 2 of GPIOB as interrupt
	SYSCFG->EXTICR[0] &= ~SYSCFG_EXTICR1_EXTI2;
	SYSCFG->EXTICR[0] |= SYSCFG_EXTICR1_EXTI2_PB;
	SYSCFG->EXTICR[0] &= ~(0x000F);
	//Set pin 3 of GPIOB as interrupt
	SYSCFG->EXTICR[0] &= ~SYSCFG_EXTICR1_EXTI3;
	SYSCFG->EXTICR[0] |= SYSCFG_EXTICR1_EXTI3_PB;
	SYSCFG->EXTICR[0] &= ~(0x000F);
	//Set pin 4 of GPIOB as interrupt
	SYSCFG->EXTICR[1] &= ~SYSCFG_EXTICR2_EXTI4;
	SYSCFG->EXTICR[1] |= SYSCFG_EXTICR2_EXTI4_PB;
	
	
	//Disable rising edge trigger
	EXTI->RTSR1 &= ~EXTI_RTSR1_RT1;
	//Enable falling edge trigger
	EXTI->FTSR1 |= EXTI_FTSR1_FT1;
	
	//Disable rising edge trigger
	EXTI->RTSR1 &= ~EXTI_RTSR1_RT2;
	//Enable falling edge trigger
	EXTI->FTSR1 |= EXTI_FTSR1_FT2;
	
	//Disable rising edge trigger
	EXTI->RTSR1 &= ~EXTI_RTSR1_RT3;
	//Enable falling edge trigger
	EXTI->FTSR1 |= EXTI_FTSR1_FT3;
	
	//Disable rising edge trigger
	EXTI->RTSR1 &= ~EXTI_RTSR1_RT4;
	//Enable falling edge trigger
	EXTI->FTSR1 |= EXTI_FTSR1_FT4;
	
	
	//Enable EXTI 1 interrupt
	EXTI->IMR1 |= EXTI_IMR1_IM1;
	//Set priority to 1
	NVIC_SetPriority(EXTI1_IRQn, 1);
	//Enable EXTI 1 interrupt
	NVIC_EnableIRQ(EXTI1_IRQn);
	
	//Enable EXTI 2 interrupt
	EXTI->IMR1 |= EXTI_IMR1_IM2;
	//Set priority to 1
	NVIC_SetPriority(EXTI2_IRQn, 1);
	//Enable EXTI 2 interrupt
	NVIC_EnableIRQ(EXTI2_IRQn);
	
	//Enable EXTI 3 interrupt
	EXTI->IMR1 |= EXTI_IMR1_IM3;
	//Set priority to 1
	NVIC_SetPriority(EXTI3_IRQn, 1);
	//Enable EXTI 3 interrupt
	NVIC_EnableIRQ(EXTI3_IRQn);
	
	//Enable EXTI 4 interrupt
	EXTI->IMR1 |= EXTI_IMR1_IM4;
	//Set priority to 1
	NVIC_SetPriority(EXTI4_IRQn, 1);
	//Enable EXTI 4 interrupt
	NVIC_EnableIRQ(EXTI4_IRQn);
}

void EXTI1_IRQHandler(void)
{
	//check interrupt flag
	if((EXTI->PR1 & 0x2) == 0x2)
	{
		//interrupt code
		Keypad();
		//Clear interrupt request
		EXTI->PR1 |= EXTI_PR1_PIF1;
	}
}

void EXTI2_IRQHandler(void)
{
	//check interrupt flag
	if((EXTI->PR1 & EXTI_PR1_PIF2) == EXTI_PR1_PIF2)
	{
		//interrupt code
		Keypad();
		//Clear interrupt request
		EXTI->PR1 |= EXTI_PR1_PIF2;
	}
}

void EXTI3_IRQHandler(void)
{
	//check interrupt flag
	if((EXTI->PR1 & EXTI_PR1_PIF3) == EXTI_PR1_PIF3)
	{
		//interrupt code
		Keypad();
		//Clear interrupt request
		EXTI->PR1 |= EXTI_PR1_PIF3;
	}
}

void EXTI4_IRQHandler(void)
{
	//check interrupt flag
	if((EXTI->PR1 & EXTI_PR1_PIF4) == EXTI_PR1_PIF4)
	{
		//interrupt code
		Keypad();
		//Clear interrupt request
		EXTI->PR1 |= EXTI_PR1_PIF4;
	}
}
