/**
@file lfsr.h

@brief Symbol definitions for lfsr
*/

#ifndef LFSR_PS_included
#define LFSR_PS_included

#define LFSR_BASE 0x00010E /**< @brief Base of LFSR */

#define LFSR_RN (*(unsigned int *)(LFSR_BASE + 0)) /**< @brief RN Register */

#endif
