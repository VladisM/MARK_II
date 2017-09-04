# Standard peripheral library

Set of standard peripheral library for programming under MARK-II in C. There is
defined all peripheral registers.

## Usage

For now, just put all these files in same directory where you have your project,
and include main library file called spl.h. Simple demo led blink program should
look like:

```
#define TIME 0x2FFFF

#include "spl/spl.h"

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
    unsigned int i;
    for(i = 0; i < time; i = i + 1);
}
```
