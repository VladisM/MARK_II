/**
@file gpio.h

@brief Symbol definitions for GPIO
*/

#ifndef SPL_GPIO_included
#define SPL_GPIO_included

#define GPIO0_BASE 0x000100 /**< @brief Base address of gpio0 */

#define PORTA (*(unsigned int *)(GPIO0_BASE + 0)) /**< @brief Register PORTA */
#define DDRA  (*(unsigned int *)(GPIO0_BASE + 1)) /**< @brief Register DDRA */
#define PORTB (*(unsigned int *)(GPIO0_BASE + 2)) /**< @brief Register PORTB */
#define DDRB  (*(unsigned int *)(GPIO0_BASE + 3)) /**< @brief Register DDRB */

#define PA0 0x01 /**< @brief Bit 0 of PORTA register. */
#define PA1 0x02 /**< @brief Bit 1 of PORTA register. */
#define PA2 0x04 /**< @brief Bit 2 of PORTA register. */
#define PA3 0x08 /**< @brief Bit 3 of PORTA register. */
#define PA4 0x10 /**< @brief Bit 4 of PORTA register. */
#define PA5 0x20 /**< @brief Bit 5 of PORTA register. */
#define PA6 0x40 /**< @brief Bit 6 of PORTA register. */
#define PA7 0x80 /**< @brief Bit 7 of PORTA register. */

#define DA0 0x01 /**< @brief Bit 0 of DDRA register. */
#define DA1 0x02 /**< @brief Bit 1 of DDRA register. */
#define DA2 0x04 /**< @brief Bit 2 of DDRA register. */
#define DA3 0x08 /**< @brief Bit 3 of DDRA register. */
#define DA4 0x10 /**< @brief Bit 4 of DDRA register. */
#define DA5 0x20 /**< @brief Bit 5 of DDRA register. */
#define DA6 0x40 /**< @brief Bit 6 of DDRA register. */
#define DA7 0x80 /**< @brief Bit 7 of DDRA register. */

#define PB0 0x01 /**< @brief Bit 0 of PORTB register. */
#define PB1 0x02 /**< @brief Bit 1 of PORTB register. */
#define PB2 0x04 /**< @brief Bit 2 of PORTB register. */
#define PB3 0x08 /**< @brief Bit 3 of PORTB register. */
#define PB4 0x10 /**< @brief Bit 4 of PORTB register. */
#define PB5 0x20 /**< @brief Bit 5 of PORTB register. */
#define PB6 0x40 /**< @brief Bit 6 of PORTB register. */
#define PB7 0x80 /**< @brief Bit 7 of PORTB register. */

#define DB0 0x01 /**< @brief Bit 0 of DDRB register. */
#define DB1 0x02 /**< @brief Bit 1 of DDRB register. */
#define DB2 0x04 /**< @brief Bit 2 of DDRB register. */
#define DB3 0x08 /**< @brief Bit 3 of DDRB register. */
#define DB4 0x10 /**< @brief Bit 4 of DDRB register. */
#define DB5 0x20 /**< @brief Bit 5 of DDRB register. */
#define DB6 0x40 /**< @brief Bit 6 of DDRB register. */
#define DB7 0x80 /**< @brief Bit 7 of DDRB register. */

#endif
