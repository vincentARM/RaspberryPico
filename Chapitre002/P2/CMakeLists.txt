cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(testPico4A)
pico_sdk_init()
add_executable(testPico4A
        testPico4A.s
        )

# Pull in our pico_stdlib which aggregates commonly used features
target_link_libraries(testPico4A pico_stdlib)

# enable usb output, disable uart output
pico_enable_stdio_usb(testPico4A 1)
pico_enable_stdio_uart(testPico4A 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(testPico4A)


