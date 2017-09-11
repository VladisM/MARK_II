/*
 * This is example of using SPL library on MARK-II.
 *
 * This example program will blink with LEDs connected on
 * PORTA (8 green LEDs on DE0 Nano board).
 */

// include MARK-II Standart Peripheral Library
#include <spl.h>

// define constant for delay
#define TIME 0x2FFFF

static void delay(int time);

int main(){

    // set PORTA as output (8 LEDs on DE0 Nano board)
    DDRA = 0xFF;

    while(1){
        // write value 0xAA into PORTA (light on all even LEDs)
        PORTA = 0xAA;

        // delay some time
        delay(TIME);

        // light on all odd LEDs
        PORTA = 0x55;

        // delay again
        delay(TIME);
    }

    return 0;
}

static void delay(int time){
    //not so much precise delay
    for(int i = 0; i < time; i = i + 1);
}
