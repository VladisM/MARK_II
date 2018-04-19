/**
@file intdrv.h

@brief Symbol definitions for interrupt driver
*/

#ifndef SPL_INTDRV_included
#define SPL_INTDRV_included

#define INTDRV_BASE 0x00010F /**< @brief Base address of intdrv0 */

#define INTMR    (*(unsigned int *)(INTDRV_BASE + 0)) /**< @brief Register INTMR */
#define INTVEC0  (*(unsigned int *)(INTDRV_BASE + 1)) /**< @brief Register INTVEC0 */
#define INTVEC1  (*(unsigned int *)(INTDRV_BASE + 2)) /**< @brief Register INTVEC1 */
#define INTVEC2  (*(unsigned int *)(INTDRV_BASE + 3)) /**< @brief Register INTVEC2 */
#define INTVEC3  (*(unsigned int *)(INTDRV_BASE + 4)) /**< @brief Register INTVEC3 */
#define INTVEC4  (*(unsigned int *)(INTDRV_BASE + 5)) /**< @brief Register INTVEC4 */
#define INTVEC5  (*(unsigned int *)(INTDRV_BASE + 6)) /**< @brief Register INTVEC5 */
#define INTVEC6  (*(unsigned int *)(INTDRV_BASE + 7)) /**< @brief Register INTVEC6 */
#define INTVEC7  (*(unsigned int *)(INTDRV_BASE + 8)) /**< @brief Register INTVEC7 */
#define INTVEC8  (*(unsigned int *)(INTDRV_BASE + 9)) /**< @brief Register INTVEC8 */
#define INTVEC9  (*(unsigned int *)(INTDRV_BASE + 10)) /**< @brief Register INTVEC9 */
#define INTVEC10 (*(unsigned int *)(INTDRV_BASE + 11)) /**< @brief Register INTVEC10 */
#define INTVEC11 (*(unsigned int *)(INTDRV_BASE + 12)) /**< @brief Register INTVEC11 */
#define INTVEC12 (*(unsigned int *)(INTDRV_BASE + 13)) /**< @brief Register INTVEC12 */
#define INTVEC13 (*(unsigned int *)(INTDRV_BASE + 14)) /**< @brief Register INTVEC13 */
#define INTVEC14 (*(unsigned int *)(INTDRV_BASE + 15)) /**< @brief Register INTVEC14 */
#define INTVEC15 (*(unsigned int *)(INTDRV_BASE + 16)) /**< @brief Register INTVEC15 */

#define SWI_VECTOR_REG INTVEC0
#define SYSTIM_VECTOR_REG INTVEC1
#define UART0_VECTOR_REG INTVEC8
#define UART1_VECTOR_REG INTVEC9
#define UART2_VECTOR_REG INTVEC10
#define PS2_0_VECTOR_REG INTVEC11
#define PS2_1_VECTOR_REG INTVEC12

#define INTMR_swi_en    0x0001 /**< @brief Bit mask for interrupt by swi instruction*/
#define INTMR_systim_en 0x0002 /**< @brief Bit mask for interrupt by system timer*/
#define INTMR_uart0_en  0x0100 /**< @brief Bit mask for interrupt by uart0*/
#define INTMR_uart1_en  0x0200 /**< @brief Bit mask for interrupt by uart1*/
#define INTMR_uart2_en  0x0400 /**< @brief Bit mask for interrupt by uart2*/
#define INTMR_PS2_0_en  0x0800 /**< @brief Bit mask for interrupt by PS2_0 interface*/
#define INTMR_PS2_1_en  0x1000 /**< @brief Bit mask for interrupt by PS2_1 interface*/

#endif
