#include <vgaio.h>
#include <vga.h>

void vgaio_clear(){
    int x, y = 0;
    for(x = ROW_0; x <= ROW_29; x++){
        for(y = COLUMN_0; y <= COLUMN_79; y++){
            VRAM0(x,y) = 0x00 | FG_BLACK | BG_BLACK;
        }
    }
    vgaio_home();
}
