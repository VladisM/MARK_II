/**
@file rom.h

@brief Symbol definitions for rom
*/

#ifndef SPL_ROM_included
#define SPL_ROM_included

#define ROM0_beg 0x000000 /**< @brief Beginning of rom0. */
#define ROM0_end 0x0000FF /**< @brief End of rom0. */

#define ROM0(OFFSET) (*(unsigned int *)(ROM0_beg + OFFSET)) /**< @brief Simple macro for accessing ROM0 */

#endif
