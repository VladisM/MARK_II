/**
@file vgaio.h

@brief Definitions for VGA text operations.
*/

#ifndef VGAIO_H_included
#define VGAIO_H_included

void vgaio_write_msg(char text[]);    /**< @brief Write string on VGA screen. **/
void vgaio_clear(); /**< @brief Clear screen. **/
void vgaio_home(); /**< @brief Set cursor to left up corner. **/

extern int vgaio_row; /**< @brief Hold actual position of cursor on screen. **/
extern int vgaio_column; /**< @brief Hold actual position of cursor on screen. **/

#endif
