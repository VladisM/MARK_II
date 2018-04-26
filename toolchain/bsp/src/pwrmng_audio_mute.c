#include "../include/pwrmng.h"
#include "../include/pwrmng_cmd.h"
#include "../../spl/include/uart.h"

int pwrmng_audio_mute(){
	if(initialized != 1)		
		return ERROR_NOT_INITIALIZED;
	while((USR2 & USR2_txcount) != 0);
	UTDR2 = CMD_AUDIO_MUTE;
	return PWRMNG_OK;	
}
