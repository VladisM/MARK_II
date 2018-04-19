/*
 * This is example of using SPL library on MARK-II.
 *
 * This example program demonstrate how to use SW interrupt and 
 * interrupts in general.
 */

// include MARK-II Standart Peripheral Library
#include <spl.h>

// declare interrupt service routine
__interrupt void swi_isr();

int main(){
    // configure LEDs
	pwrmng_init();

    // enable interrupt from software 
	INTMR |= INTMR_swi_en;
    
    // set vector of interrupt
	SWI_VECTOR_REG = (unsigned int)(&swi_isr);

    // interrupt and wait a bit
	while(1){
		intrq();
		for(int i = 0; i < 0xFFFFF; i++);
	}		
}

// definition of ISR; keyword __interrupt is mandatory because ISR 
// functions have to use RETI instruction instead RET
__interrupt void swi_isr(){
	pwrmng_led_blink_short();
}
