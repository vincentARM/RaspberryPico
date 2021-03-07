cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(testPico5A)
pico_sdk_init()
add_executable(testPico5A
        testPico5A.s
        )

# Pull in our pico_stdlib which aggregates commonly used features
target_link_libraries(testPico5A pico_stdlib)

# enable usb output, disable uart output
pico_enable_stdio_usb(testPico5A 1)
pico_enable_stdio_uart(testPico5A 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(testPico5A)

