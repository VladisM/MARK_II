/**
@file intdrv.h

@brief Symbol definitions for interrupt driver
*/

#ifndef SPL_INTDRV_included
#define SPL_INTDRV_included

#define INTDRV_BASE 0x000108 /**< @brief Base address of intdrv0 */

#define INTMR (*(unsigned int *)(INTDRV_BASE + 0)) /**< @brief Register INTMR */

#define INTMR_systim_en 0x00000001 /**< @brief Bit mask for interrupt by system timer*/
#define INTMR_uart0_en  0x00000100 /**< @brief Bit mask for interrupt by uart0*/
#define INTMR_uart1_en  0x00000200 /**< @brief Bit mask for interrupt by uart1*/
#define INTMR_uart2_en  0x00000400 /**< @brief Bit mask for interrupt by uart2*/
#define INTMR_tim0_en   0x00004000 /**< @brief Bit mask for interrupt by timer0*/
#define INTMR_tim1_en   0x00008000 /**< @brief Bit mask for interrupt by timer1*/
#define INTMR_tim2_en   0x00010000 /**< @brief Bit mask for interrupt by timer2*/
#define INTMR_tim3_en   0x00020000 /**< @brief Bit mask for interrupt by timer3*/
#define INTMR_ps0_en    0x00040000 /**< @brief Bit mask for interrupt by PS2 interface*/

#endif
