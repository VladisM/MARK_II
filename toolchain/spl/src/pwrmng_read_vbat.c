#include <pwrmng.h>
#include <pwrmng_cmd.h>
#include <uart.h>

int pwrmng_read_vbat(float* voltage){
	int adc;
	
	if(initialized != 1)		
		return ERROR_NOT_INITIALIZED;
		
	while((USR2 & USR2_txcount) != 0);
	UTDR2 = CMD_READ_VBAT;
	
	while((USR2 & USR2_rxcount) == 0);
	adc = URDR2;
	
	*voltage = (((float)(2 * adc)) / 256.0) * 3.3;
	
	return PWRMNG_OK;
	
}
