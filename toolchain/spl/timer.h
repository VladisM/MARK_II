/**
@file timer.h

@brief Symbol definitions for timers
*/

#ifndef SPL_TIMER_included
#define SPL_TIMER_included

#define TIMER0_BASE 0x000110 /**< @brief Base address of timer0 */
#define TIMER1_BASE 0x000114 /**< @brief Base address of timer1 */
#define TIMER2_BASE 0x000118 /**< @brief Base address of timer2 */
#define TIMER3_BASE 0x00011C /**< @brief Base address of timer3 */

#define TCCR0 (*(unsigned int *)(TIMER0_BASE + 0)) /**< @brief Register TCCR0 */
#define OCRA0 (*(unsigned int *)(TIMER0_BASE + 1)) /**< @brief Register OCRA0 */
#define OCRB0 (*(unsigned int *)(TIMER0_BASE + 2)) /**< @brief Register OCRB0 */
#define TCNR0 (*(unsigned int *)(TIMER0_BASE + 3)) /**< @brief Register TCNR0 */

#define TCCR1 (*(unsigned int *)(TIMER1_BASE + 0)) /**< @brief Register TCCR1 */
#define OCRA1 (*(unsigned int *)(TIMER1_BASE + 1)) /**< @brief Register OCRA1 */
#define OCRB1 (*(unsigned int *)(TIMER1_BASE + 2)) /**< @brief Register OCRB1 */
#define TCNR1 (*(unsigned int *)(TIMER1_BASE + 3)) /**< @brief Register TCNR1 */

#define TCCR2 (*(unsigned int *)(TIMER2_BASE + 0)) /**< @brief Register TCCR2 */
#define OCRA2 (*(unsigned int *)(TIMER2_BASE + 1)) /**< @brief Register OCRA2 */
#define OCRB2 (*(unsigned int *)(TIMER2_BASE + 2)) /**< @brief Register OCRB2 */
#define TCNR2 (*(unsigned int *)(TIMER2_BASE + 3)) /**< @brief Register TCNR2 */

#define TCCR3 (*(unsigned int *)(TIMER3_BASE + 0)) /**< @brief Register TCCR3 */
#define OCRA3 (*(unsigned int *)(TIMER3_BASE + 1)) /**< @brief Register OCRA3 */
#define OCRB3 (*(unsigned int *)(TIMER3_BASE + 2)) /**< @brief Register OCRB3 */
#define TCNR3 (*(unsigned int *)(TIMER3_BASE + 3)) /**< @brief Register TCNR3 */

#define TCCR0_ccmen 0x00000001 /**< @brief Bit mask for clear on compare match of timer0 */
#define TCCR0_timen 0x00000002 /**< @brief Bit mask for enable timer0 */
#define TCCR0_ovint 0x00000004 /**< @brief Bit mask for enable overflow interrupt by timer0 */
#define TCCR0_cmint 0x00000008 /**< @brief Bit mask for enable interrupt on compare match by timer0 */
#define TCCR0_pwmen 0x00000010 /**< @brief Bit mask for enabling PWM outputs on both timer0 channels */
#define TCCR0_pre0  0x00000020 /**< @brief Bit mask for lower bit of prescaler configuration for timer0 */
#define TCCR0_pre1  0x00000040 /**< @brief Bit mask for higher bit of prescaler configuration for timer0 */

#define TCCR1_ccmen 0x00000001 /**< @brief Bit mask for clear on compare match of timer1 */
#define TCCR1_timen 0x00000002 /**< @brief Bit mask for enable timer1 */
#define TCCR1_ovint 0x00000004 /**< @brief Bit mask for enable overflow interrupt by timer1 */
#define TCCR1_cmint 0x00000008 /**< @brief Bit mask for enable interrupt on compare match by timer1 */
#define TCCR1_pwmen 0x00000010 /**< @brief Bit mask for enabling PWM outputs on both timer1 channels */
#define TCCR1_pre0  0x00000020 /**< @brief Bit mask for lower bit of prescaler configuration for timer1 */
#define TCCR1_pre1  0x00000040 /**< @brief Bit mask for higher bit of prescaler configuration for timer1 */

#define TCCR2_ccmen 0x00000001 /**< @brief Bit mask for clear on compare match of timer2 */
#define TCCR2_timen 0x00000002 /**< @brief Bit mask for enable timer2 */
#define TCCR2_ovint 0x00000004 /**< @brief Bit mask for enable overflow interrupt by timer2 */
#define TCCR2_cmint 0x00000008 /**< @brief Bit mask for enable interrupt on compare match by timer2 */
#define TCCR2_pwmen 0x00000010 /**< @brief Bit mask for enabling PWM outputs on both timer2 channels */
#define TCCR2_pre0  0x00000020 /**< @brief Bit mask for lower bit of prescaler configuration for timer2 */
#define TCCR2_pre1  0x00000040 /**< @brief Bit mask for higher bit of prescaler configuration for timer2 */

#define TCCR3_ccmen 0x00000001 /**< @brief Bit mask for clear on compare match of timer3 */
#define TCCR3_timen 0x00000002 /**< @brief Bit mask for enable timer3 */
#define TCCR3_ovint 0x00000004 /**< @brief Bit mask for enable overflow interrupt by timer3 */
#define TCCR3_cmint 0x00000008 /**< @brief Bit mask for enable interrupt on compare match by timer3 */
#define TCCR3_pwmen 0x00000010 /**< @brief Bit mask for enabling PWM outputs on both timer3 channels */
#define TCCR3_pre0  0x00000020 /**< @brief Bit mask for lower bit of prescaler configuration for timer3 */
#define TCCR3_pre1  0x00000040 /**< @brief Bit mask for higher bit of prescaler configuration for timer3 */

#endif
