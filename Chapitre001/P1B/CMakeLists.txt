cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(testASM)
pico_sdk_init()
add_executable(testPico2
        routinesGpio.c
        testPico2.s
        )
#pico_generate_pio_header(testPico2 ./testPico2.s)   ERREUR ERREUR
# Pull in our pico_stdlib which aggregates commonly used features
target_link_libraries(testPico2 pico_stdlib
                       hardware_gpio)

# enable usb output, disable uart output
pico_enable_stdio_usb(testPico2 1)
pico_enable_stdio_uart(testPico2 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(testPico2)

# add url via pico_set_program_url
#example_auto_set_url(hello_usb)
