#include "../include/pwrmng.h"
#include "../include/pwrmng_cmd.h"
#include "../../spl/include/uart.h"

int pwrmng_get_sd_state(int* state){
	if(initialized != 1)		
		return ERROR_NOT_INITIALIZED;
		
	while((USR2 & USR2_txcount) != 0);
	UTDR2 = CMD_GET_SD_STATE;
	
	while((USR2 & USR2_rxcount) == 0);
	*state = URDR2;
	
	return PWRMNG_OK;
}
