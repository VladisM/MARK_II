/**
@file timer.h

@brief Symbol definitions for timers
*/

#ifndef SPL_TIMER_included
#define SPL_TIMER_included

#define TIMER0_BASE 0x000140 /**< @brief Base address of timer0 */
#define TIMER0_BASE 0x000144 /**< @brief Base address of timer0 */
#define TIMER0_BASE 0x000148 /**< @brief Base address of timer0 */
#define TIMER0_BASE 0x00014C /**< @brief Base address of timer0 */

#define TCR0 (*(unsigned int *)(TIMER0_BASE + 0)) /**< @brief Register TCR0 */
#define TCR1 (*(unsigned int *)(TIMER1_BASE + 0)) /**< @brief Register TCR1 */
#define TCR2 (*(unsigned int *)(TIMER2_BASE + 0)) /**< @brief Register TCR2 */
#define TCR3 (*(unsigned int *)(TIMER3_BASE + 0)) /**< @brief Register TCR3 */

#define TVR0 (*(unsigned int *)(TIMER0_BASE + 1)) /**< @brief Register TVR0 */
#define TVR1 (*(unsigned int *)(TIMER1_BASE + 1)) /**< @brief Register TVR1 */
#define TVR2 (*(unsigned int *)(TIMER2_BASE + 1)) /**< @brief Register TVR2 */
#define TVR3 (*(unsigned int *)(TIMER3_BASE + 1)) /**< @brief Register TVR3 */

#define TCRx_CMPM     0x0000FFFF /**< @brief CMPM mask for TCRx register */
#define TCRx_CMPM_pos 0          /**< @brief position of beginning CMPM in register TCRx */
#define TCRx_ten      0x00010000 /**< @brief tie mask for TCRx register */
#define TCRx_ien      0x00020000 /**< @brief ien mask for TCRx register */
#define TCRx_DIV      0x001C0000 /**< @brief DIV mask for TCRx register */
#define TCRx_DIV_0    0x00040000 /**< @brief DIV bit 0 mask for TCRx register */
#define TCRx_DIV_1    0x00080000 /**< @brief DIV bit 1 mask for TCRx register */
#define TCRx_DIV_2    0x00100000 /**< @brief DIV bit 2 mask for TCRx register */
#define TCRx_DIV_pos  18         /**< @brief position of beginning DIV in register TCRx*/
#define TVRx_VAL      0x0000FFFF /**< @brief Value mask for TVRx register */

#endif 

