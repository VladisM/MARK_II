/**
@file sdram.h

@brief Symbol definitions for external sdram
*/

#ifndef SPL_SDRAM_included
#define SPL_SDRAM_included

#define SDRAM0_beg 0x800000 /**< @brief Beginning of sdram0. */
#define SDRAM0_end 0xFFFFFF /**< @brief End of sdram0. */

#define SDRAM0(OFFSET) (*(unsigned int *)(SDRAM0_beg + OFFSET)) /**< @brief Simple macro for accessing SDRAM0 */

#endif
