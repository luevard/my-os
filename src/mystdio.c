#include "mystdio.h"

volatile int counter = 0;

void flushscreen(){
    
}

void printf(char* string){
    int size = sizeof(string);
    for(int i=0;i<size;i++){
        (VGA_TEXT_BUFFER+counter*2)[0] = string[i];
        (VGA_TEXT_BUFFER+counter*2)[1] = 0x07;
        counter++;
    }
}