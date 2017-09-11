/**
@file uart.h

@brief Symbol definitions for uart
*/

#ifndef SPL_UART_included
#define SPL_UART_included

#define UART0_BASE 0x000120 /**< @brief Base address of uart0 */
#define UART1_BASE 0x000124 /**< @brief Base address of uart1 */
#define UART2_BASE 0x000128 /**< @brief Base address of uart2 */

#define UTDR0 (*(unsigned int *)(UART0_BASE + 0)) /**< @brief Register UTDR0 */
#define URDR0 (*(unsigned int *)(UART0_BASE + 1)) /**< @brief Register URDR0 */
#define USR0  (*(unsigned int *)(UART0_BASE + 2)) /**< @brief Register USR0 */
#define UCR0  (*(unsigned int *)(UART0_BASE + 3)) /**< @brief Register UCR0 */

#define UTDR1 (*(unsigned int *)(UART1_BASE + 0)) /**< @brief Register UTDR1 */
#define URDR1 (*(unsigned int *)(UART1_BASE + 1)) /**< @brief Register URDR1 */
#define USR1  (*(unsigned int *)(UART1_BASE + 2)) /**< @brief Register USR1 */
#define UCR1  (*(unsigned int *)(UART1_BASE + 3)) /**< @brief Register UCR1 */

#define UTDR2 (*(unsigned int *)(UART2_BASE + 0)) /**< @brief Register UTDR2 */
#define URDR2 (*(unsigned int *)(UART2_BASE + 1)) /**< @brief Register URDR2 */
#define USR2  (*(unsigned int *)(UART2_BASE + 2)) /**< @brief Register USR2 */
#define UCR2  (*(unsigned int *)(UART2_BASE + 3)) /**< @brief Register UCR2 */

#define UCR0_N     0x0000FFFF /**< @brief Bit mask for baudrate N constant for uart0 */
#define UCR0_rxen  0x00010000 /**< @brief Bit mask for enable transmitter uart0*/
#define UCR0_txen  0x00020000 /**< @brief Bit mask for enable receiver uart0 */
#define UCR0_inten 0x00040000 /**< @brief Bit mask for enable interrupt from uart0 */
#define UCR0_rfint 0x00080000 /**< @brief Bit mask for enable receiver fifo full interrupt on uart0 */
#define UCR0_rhint 0x00100000 /**< @brief Bit mask for enable receiver fifo half full interrupt on uart0 */
#define UCR0_rxint 0x00200000 /**< @brief Bit mask for enable receiver byte interrupt on uart0 */
#define UCR0_teint 0x00400000 /**< @brief Bit mask for enable transmitter fifo empty interrupt on uart0 */
#define UCR0_thint 0x00800000 /**< @brief Bit mask for enable transmitter fifo half empty interrupt on uart0 */
#define UCR0_txint 0x01000000 /**< @brief Bit mask for enable transmitter byte sent interrupt on uart0 */

#define USR0_rxcount 0x0000003F /**< @brief Bit mask for count of bytes in rx fifo on uart0 */
#define USR0_txcount 0x00000FC0 /**< @brief Bit mask for count of bytes in tx fifo on uart0 */
#define USR0_rfif    0x00001000 /**< @brief Bit mask for receiver full interrupt flag on uart0 */
#define USR0_rhif    0x00002000 /**< @brief Bit mask for receiver half full interrupt flag on uart0 */
#define USR0_rxif    0x00004000 /**< @brief Bit mask for receiver byte received interrupt flag on uart0 */
#define USR0_teif    0x00008000 /**< @brief Bit mask for transmitter empty interrupt flag on uart0 */
#define USR0_thif    0x00010000 /**< @brief Bit mask for transmitter half empty interrupt flag on uart0 */
#define USR0_txif    0x00020000 /**< @brief Bit mask for transmitter byte sent interrupt flag on uart0 */

#define UCR1_N     0x0000FFFF /**< @brief Bit mask for baudrate N constant for uart1 */
#define UCR1_rxen  0x00010000 /**< @brief Bit mask for enable transmitter uart1*/
#define UCR1_txen  0x00020000 /**< @brief Bit mask for enable receiver uart1 */
#define UCR1_inten 0x00040000 /**< @brief Bit mask for enable interrupt from uart1 */
#define UCR1_rfint 0x00080000 /**< @brief Bit mask for enable receiver fifo full interrupt on uart1 */
#define UCR1_rhint 0x00100000 /**< @brief Bit mask for enable receiver fifo half full interrupt on uart1 */
#define UCR1_rxint 0x00200000 /**< @brief Bit mask for enable receiver byte interrupt on uart1 */
#define UCR1_teint 0x00400000 /**< @brief Bit mask for enable transmitter fifo empty interrupt on uart1 */
#define UCR1_thint 0x00800000 /**< @brief Bit mask for enable transmitter fifo half empty interrupt on uart1 */
#define UCR1_txint 0x01000000 /**< @brief Bit mask for enable transmitter byte sent interrupt on uart1 */

#define USR1_rxcount 0x0000003F /**< @brief Bit mask for count of bytes in rx fifo on uart1 */
#define USR1_txcount 0x00000FC0 /**< @brief Bit mask for count of bytes in tx fifo on uart1 */
#define USR1_rfif    0x00001000 /**< @brief Bit mask for receiver full interrupt flag on uart1 */
#define USR1_rhif    0x00002000 /**< @brief Bit mask for receiver half full interrupt flag on uart1 */
#define USR1_rxif    0x00004000 /**< @brief Bit mask for receiver byte received interrupt flag on uart1 */
#define USR1_teif    0x00008000 /**< @brief Bit mask for transmitter empty interrupt flag on uart1 */
#define USR1_thif    0x00010000 /**< @brief Bit mask for transmitter half empty interrupt flag on uart1 */
#define USR1_txif    0x00020000 /**< @brief Bit mask for transmitter byte sent interrupt flag on uart1 */

#define UCR2_N     0x0000FFFF /**< @brief Bit mask for baudrate N constant for uart2 */
#define UCR2_rxen  0x00010000 /**< @brief Bit mask for enable transmitter uart2*/
#define UCR2_txen  0x00020000 /**< @brief Bit mask for enable receiver uart2 */
#define UCR2_inten 0x00040000 /**< @brief Bit mask for enable interrupt from uart2 */
#define UCR2_rfint 0x00080000 /**< @brief Bit mask for enable receiver fifo full interrupt on uart2 */
#define UCR2_rhint 0x00100000 /**< @brief Bit mask for enable receiver fifo half full interrupt on uart2 */
#define UCR2_rxint 0x00200000 /**< @brief Bit mask for enable receiver byte interrupt on uart2 */
#define UCR2_teint 0x00400000 /**< @brief Bit mask for enable transmitter fifo empty interrupt on uart2 */
#define UCR2_thint 0x00800000 /**< @brief Bit mask for enable transmitter fifo half empty interrupt on uart2 */
#define UCR2_txint 0x01000000 /**< @brief Bit mask for enable transmitter byte sent interrupt on uart2 */

#define USR2_rxcount 0x0000003F /**< @brief Bit mask for count of bytes in rx fifo on uart2 */
#define USR2_txcount 0x00000FC0 /**< @brief Bit mask for count of bytes in tx fifo on uart2 */
#define USR2_rfif    0x00001000 /**< @brief Bit mask for receiver full interrupt flag on uart2 */
#define USR2_rhif    0x00002000 /**< @brief Bit mask for receiver half full interrupt flag on uart2 */
#define USR2_rxif    0x00004000 /**< @brief Bit mask for receiver byte received interrupt flag on uart2 */
#define USR2_teif    0x00008000 /**< @brief Bit mask for transmitter empty interrupt flag on uart2 */
#define USR2_thif    0x00010000 /**< @brief Bit mask for transmitter half empty interrupt flag on uart2 */
#define USR2_txif    0x00020000 /**< @brief Bit mask for transmitter byte sent interrupt flag on uart2 */

#endif
