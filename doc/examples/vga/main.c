/*
 * This is example of using SPL library on MARK-II.
 *
 * This program demonstrate using VGA driver to display some
 * text on monitor. String "Hello world!" should appear on top left
 * corner of your screen.
 */

// include MARK-II Standard Peripheral Library
#include <vga.h>

// this is function that will write text on monitor
void write(int row, int column, int color, char text[]);

// this text will be written
char hello[] = "Hello world!";

int main(){

    // call write function
    //
    // use macro ROW_X and COLUMN_X for setting position
    //
    // macro FG_WHITE to set foreground color to white
    //
    // there is also additional colors and is possible to
    // change background color too
    write(ROW_0, COLUMN_0, FG_WHITE, hello);

    // then halt
    while(1);
    return 0;
}

void write(int row, int column, int color, char text[]){

    // for is used for going through whole string
    for(int i = 0; text[i] != 0; i++){

        // for each character write it into VRAM
        //
        // VRAM0 is macro that will count right address from
        // given arguments
        //
        // character in VRAM is composed from its code (ASCII) and colors
        // use macros FG_XXX and BG_XXX and or them together with char

        VRAM0(row, column + i) = text[i] | color;
    }
}
