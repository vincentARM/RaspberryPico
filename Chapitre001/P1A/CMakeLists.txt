cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(testPico1A)
pico_sdk_init()
add_executable(testPico1A
        testPico1A.s
        )

# Pull in our pico_stdlib which aggregates commonly used features
target_link_libraries(testPico1A pico_stdlib)

# enable usb output, disable uart output
pico_enable_stdio_usb(testPico1A 0)
pico_enable_stdio_usb(testPico1A 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(testPico1A)

