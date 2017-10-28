#include <vgaio.h>

#include <spl.h>

static void move_lines_up();

static int row = ROW_0;
static int column = COLUMN_0;

void write_msg(char text[]){
    for(int i = 0; text[i] != 0; i++){
        if (text[i] == '\n'){
            
            if (row < ROW_29) {
                row = row + 1;
                column = COLUMN_0;
            }
            else{
                move_lines_up();
                row = ROW_29;
                column = COLUMN_0;
            }
            
        }
        else if (text[i] == '\r'){
            column = COLUMN_0;
        }
        else{
            VRAM0(row, column) = text[i] | FG_WHITE | BG_BLACK;
            column = column + 1;
        }        
    }
}

void clear(){
    int x, y = 0;
    for(x = ROW_0; x <= ROW_29; x++){
        for(y = COLUMN_0; y <= COLUMN_79; y++){
            VRAM0(x,y) = 0x00 | FG_BLACK | BG_BLACK;
        }
    }
    row = ROW_0;
    column = COLUMN_0;
}

static void move_lines_up(){
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
