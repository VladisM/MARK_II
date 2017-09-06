#include <spl.h>

#define TIME 0x2FFFF

static void delay(int time);

int main(){

    DDRA = 0xFF;

    while(1){
        PORTA = 0xAA;
        delay(TIME);
        PORTA = 0x55;
        delay(TIME);
    }

    return 0;
}

static void delay(int time){
    for(int i = 0; i < time; i = i + 1);
}
