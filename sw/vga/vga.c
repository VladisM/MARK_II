#include <spl.h>

void write(int row, int column, int color, char text[]);

char hello[] = "Hello world!";

int main(){

    write(ROW_0, COLUMN_0, FG_GREEN, hello);

    while(1);
    return 0;
}

void write(int row, int column, int color, char text[]){
    for(int i = 0; text[i] != 0; i++){
        VRAM0(row, column + i) = text[i] | color;
    }
}
