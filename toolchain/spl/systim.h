/**
@file systim.h

@brief Symbol definitions for systim
*/

#ifndef SPL_SYSTIM_included
#define SPL_SYSTIM_included

#define SYSTIM0_BASE 0x000104 /**< @brief Base address of systim0 */

#define SYSTCR (*(unsigned int *)(SYSTIM0_BASE + 0)) /**< @brief Register SYSTCR */
#define SYSTVR (*(unsigned int *)(SYSTIM0_BASE + 1)) /**< @brief Register SYSTVR */

#define SYSTCR_top 0x00FFFFFF /**< @brief Bit mask for top value in SYSTCR register */
#define SYSTCR_en  0x01000000 /**< @brief Bit mask for timer enable in SYSTCR register */

#endif
