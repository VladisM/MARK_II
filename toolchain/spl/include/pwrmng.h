/**
@file pwrmng.h

@brief Definitions for pwrmng functions
*/

#ifndef SPL_PWRMNG_included
#define SPL_PWRMNG_included

//return codes
/**
 * \defgroup pwrmng_return_vals Return codes from pwrmng functions
 * @{
 */
#define ERROR_NOT_INITIALIZED -1 /**< @brief ERROR initialize connection first */
#define PWRMNG_OK 0 /**< @brief command executed */
/** @}*/

/**
 * \defgroup sd_return_vals Return values for micro SD
 * @{
 */
#define SD_INSERTED 1 /**< @brief SD card is in slot */
#define SD_NOT_INSERTED 0 /**< @brief SD card is not present */
/** @}*/

int pwrmng_read_vbat(float* voltage); /**< @brief measure rtc battery voltage */
int pwrmng_beep_short(); /**< @brief produce short beep */
int pwrmng_beep_long(); /**< @brief produce long beep */
int pwrmng_led_on(); /**< @brief turn on CPU led */
int pwrmng_led_off(); /**< @brief turn off CPU led */
int pwrmng_led_blink_short(); /**< @brief produce short blink with CPU led */
int pwrmng_led_blink_long(); /**< @brief produce long blink with CPU led */
int pwrmng_power_off(); /**< @brief disable power source */
int pwrmng_reset(); /**< @brief produce SoC wide reset sequence */
int pwrmng_audio_mute(); /**< @brief mute audio DAC */
int pwrmng_audio_unmute(); /**< @brief unmute audo DAC */
int pwrmng_get_sd_state(int* state); /**< @brief get sd connection state */

void pwrmng_init(); /**< @brief Init communication with pwrmng IC */

extern int initialized; /**< @brief Internal variable, hold pwrmng init state */

#endif
