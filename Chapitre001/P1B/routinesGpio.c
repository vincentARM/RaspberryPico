/**
 * routines en C pour appeler les routines de la librairie
 * raspberry pico
 */

#include <stdio.h>
#include "pico/stdlib.h"
    
    int my_gpio_init(int LED_PIN) {
gpio_init(LED_PIN);
}

int my_gpio_set_dir(int LED_PIN, int ON_OFF) {
gpio_set_dir(LED_PIN, GPIO_OUT);
}

int my_gpio_put(int LED_PIN, int ON_OFF) {
gpio_put(LED_PIN, ON_OFF);

}

