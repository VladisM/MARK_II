/**
@file ps.h

@brief Symbol definitions for PS2 interface
*/

#ifndef SPL_PS_included
#define SPL_PS_included

#define PS0_BASE 0x000109 /**< @brief Base of PS2 driver */

#define PSBR (*(unsigned int *)(PS0_BASE + 0)) /**< @brief Register PSBR */

#endif
