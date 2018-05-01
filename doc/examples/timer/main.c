/*
 * This is example of using SPL library on MARK-II.
 *
 */

// include MARK-II Standart Peripheral Library
#include <spl.h>

// declare interrupt service routine
__interrupt void timer_isr();

static volatile int count = 0;

int main(){
    
    // configure LEDs
	pwrmng_init();
    
    // set vector of interrupt
	TIMER0_VECTOR_REG = (unsigned int)(&timer_isr);
	
	/* 
	 * configure timer
	 * 
	 * Fclk = 25 * 10^(6) * 1/16
	 * TOP = 2^16-1
	 * enable interrupt
	 */
	TCR0 |= (TCRx_ten | TCRx_ien | TCRx_DIV_2 | 0xFFFF);
       
    // enable interrupt from timer 0
	INTMR |= INTMR_timer0_en;
	// do nothing loop
	while(1);
}

// definition of ISR; keyword __interrupt is mandatory because ISR 
// functions have to use RETI instruction instead RET
__interrupt void timer_isr(){
	//counting up to 24 give to us 1s intervals +/- few ms
	if(count == 23){
		pwrmng_led_blink_short();	
		count = 0;
	}
	else{
		count++;
	}
}
