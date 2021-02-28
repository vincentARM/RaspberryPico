/**
 * Test d'une routine en assembleur depuis un programme C
 * pour raspberry pico 
 */

#include <stdio.h>
#include "pico/stdlib.h"
extern int routine1();
int main() {
    int i;
    stdio_init_all();
    i=routine1();
    while (true) {
        printf("Hello, world!  %i  \n",i); 
        sleep_ms(1000);
    }
    return 0;
}
