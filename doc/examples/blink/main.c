/*
 * This is example of using SPL library on MARK-II.
 *
 * This example program will blink with LED connected to pwrmng.
 */

// include MARK-II Board Support Package 
#include <pwrmng.h>

// define constant for delay
#define TIME 0x2FFFF

static void delay(int time);

int main(){
	
	// initialize pwrmng connection 
	pwrmng_init();
	
    while(1){
		// set CPU_LED on 
        pwrmng_led_on();

        // delay some time
        delay(TIME);
		
		// set CPU_LED off
        pwrmng_led_off();

        // delay again
        delay(TIME);
    }

    return 0;
}

static void delay(int time){
    //not so much precise delay
    for(int i = 0; i < time; i = i + 1);
}
