#include "../include/pwrmng.h"
#include "../include/pwrmng_cmd.h"
#include "../../spl/include/uart.h"

void pwrmng_init(){
	UCR2 |= ( UCR2_txen | UCR2_rxen | (UCR2_N & 0xEF) );
	initialized = 1;	
}
