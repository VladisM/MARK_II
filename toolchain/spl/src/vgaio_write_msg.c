#include <vgaio.h>
#include <vga.h>

static void vgaio_move_lines_up();

void vgaio_write_msg(char text[]){
    for(int i = 0; text[i] != 0; i++){
        if (text[i] == '\n'){
            
            if (vgaio_row < ROW_29) {
                vgaio_row = vgaio_row + 1;
                vgaio_column = COLUMN_0;
            }
            else{
                vgaio_move_lines_up();
                vgaio_row = ROW_29;
                vgaio_column = COLUMN_0;
            }
            
        }
        else if (text[i] == '\r'){
            vgaio_column = COLUMN_0;
        }
        else{
            VRAM0(vgaio_row, vgaio_column) = text[i] | FG_WHITE | BG_BLACK;
            vgaio_column = vgaio_column + 1;
        }        
    }
}

static void vgaio_move_lines_up(){
    int x, y = 0;
    for(x = ROW_1; x <= ROW_29; x++){
        for(y = COLUMN_0; y <= COLUMN_79; y++){
            VRAM0(x-1,y) = VRAM0(x, y);
        }
    }
    for(y = COLUMN_0; y <= COLUMN_79; y++){
        VRAM0(ROW_29,y) = 0x00 | FG_BLACK | BG_BLACK;
    }
}
