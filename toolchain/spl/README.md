# Standard peripheral library

Set of standard peripheral library for programming under MARK-II in C. There is
defined all peripheral registers.

## Usage

Copy all header files somewhere where you have all tool installed. Then invoke
vbcc with parameter `-I` and add path to folder where headers are stored.

For example, let's compile file blink.c:

```C
#define TIME 0x2FFFF

#include <spl.h>

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

And let's say spl is located in directory /opt/m2tools/spl. Then, to compile this code just invoke:

```bash
m2-vbcc -I/opt/m2tools/spl blink.c
```
