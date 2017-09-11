/**
@file ram.h

@brief Symbol definitions for ram
*/

#ifndef SPL_RAM_included
#define SPL_RAM_included

#define RAM0_beg 0x000400 /**< @brief Beginning of ram0. */
#define RAM0_end 0x0007FF /**< @brief End of ram0. */
#define RAM1_beg 0x100000 /**< @brief Beginning of ram1. */
#define RAM1_end 0x101FFF /**< @brief End of ram1. */

#define RAM0(OFFSET) (*(unsigned int *)(RAM0_beg + OFFSET)) /**< @brief Simple macro for accessing RAM0 */
#define RAM1(OFFSET) (*(unsigned int *)(RAM1_beg + OFFSET)) /**< @brief Simple macro for accessing RAM1 */

#endif
