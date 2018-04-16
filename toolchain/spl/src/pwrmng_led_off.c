#include <pwrmng.h>
#include <pwrmng_cmd.h>
#include <uart.h>

int pwrmng_led_off(){
	if(initialized != 1)		
		return ERROR_NOT_INITIALIZED;
	while((USR2 & USR2_txcount) != 0);
	UTDR2 = CMD_LED_OFF;
	return PWRMNG_OK;	
}
