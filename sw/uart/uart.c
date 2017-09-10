#include <spl.h>

void write_uart0(char text[]);
void delay(int time);

char hello[] = "Hello world!\n";

int main(){

    //enable transmitter on UART0; set baudrate to 1200
    UCR0 |= (UCR0_txen|(UCR0_N & 0x2ED));

    while(1){
        write_uart0(hello);
        delay(0xFFFFF);
    }
    return 0;
}

void write_uart0(char text[]){

    //wait until TX fifo is empty
    while((USR0 & USR0_txcount) != 0);

    //put string into TX fifo
    for(int i = 0; text[i] != 0; i++){
        UTDR0 = text[i];
    }
}

void delay(int time){
    for(int i = 0; i < time; i = i + 1);
}
