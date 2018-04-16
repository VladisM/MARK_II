/**
 * @file pwrmng_cmd.h
 * 
 * @brief commands definitions for pwrmng functions
 */

#ifndef SPL_PWRMNG_CMD_included
#define SPL_PWRMNG_CMD_included

//commands for pwrmng
#define CMD_READ_VBAT           0x80
#define CMD_BEEP_SHORT          0x81
#define CMD_BEEP_LONG           0x82
#define CMD_LED_ON              0x83
#define CMD_LED_OFF             0x84
#define CMD_LED_BLINK_SHORT     0x85
#define CMD_LED_BLINK_LONG      0x86
#define CMD_POWEROFF            0x87
#define CMD_RESET               0x88
#define CMD_AUDIO_MUTE          0x89
#define CMD_AUDIO_UNMUTE        0x8A
#define CMD_GET_SD_STATE        0x8B

#endif
