cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(testPico9C)
pico_sdk_init()
add_executable(testPico9C
        testPico9C.s
        routinesPico.s
        )

# Pull in our pico_stdlib which aggregates commonly used features
target_link_libraries(testPico9C pico_stdlib )


# enable usb output, disable uart output
pico_enable_stdio_usb(testPico9C 1)
pico_enable_stdio_uart(testPico9C 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(testPico9C)
