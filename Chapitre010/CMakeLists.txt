cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(testPico21)
pico_sdk_init()
add_executable(testPico21
        testPico21.s
        )

#librairie minimum pour compiler
target_link_libraries(testPico21  pico_standard_link)

# aucune sortie possible !!
# enable usb output, disable uart output
pico_enable_stdio_usb(testPico21 0)
pico_enable_stdio_uart(testPico21 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(testPico21)

