/*
 * This is example of using SPL library on MARK-II.
 *
 * This program have to write string "Hello world!\n" on your
 * uart console. Used uart is uart0.
 */

// include MARK-II Standart Peripheral Library
#include <uart.h>

// function that will write given string into buffer
void write_uart0(char text[]);

// function for delay
void delay(int time);

// this string will be printed
char hello[] = "Hello world!\n";

int main(){

    // enable transmitter on UART0; set baudrate to 9600
    // UCR is configuration register there you can set baudrate, enable UART, enable interrupts..
    // use UCRX_xxx macros
    UCR0 |= (UCR0_txen|(UCR0_N & 0x0077));

    while(1){
        // write string and delay
        write_uart0(hello);
        delay(0xFFFFF);
    }
    return 0;
}

void write_uart0(char text[]){

    // wait until TX fifo is empty
    // in USR register you can found many informations about UART, for example count of bytes in tx fifo
    while((USR0 & USR0_txcount) != 0);

    // put whole string into TX fifo
    // this example doesn't take care about length of string but FIFO is only 32 bytes deep
    for(int i = 0; text[i] != 0; i++){
        //simple write into UTDR register (internal uart logic will store your byte into fifo automatically)
        UTDR0 = text[i];
    }
}

void delay(int time){
    // not so much precise delay
    for(int i = 0; i < time; i = i + 1);
}
