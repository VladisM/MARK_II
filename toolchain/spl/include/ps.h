/**
@file ps.h

@brief Symbol definitions for PS2 interface
*/

#ifndef SPL_PS_included
#define SPL_PS_included

#define PS2_0_BASE 0x000106 /**< @brief Base of PS2_0 driver */
#define PS2_1_BASE 0x000107 /**< @brief Base of PS2_1 driver */

#define PSBR0 (*(unsigned int *)(PS2_0_BASE + 0)) /**< @brief Register PSBR of PS2_0 */
#define PSBR1 (*(unsigned int *)(PS2_1_BASE + 0)) /**< @brief Register PSBR of PS2_1 */

#endif
