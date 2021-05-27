cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(testPico12)
pico_sdk_init()
add_executable(testPico12
        testPico12.s
        routinesPico.s
        )
pico_set_binary_type(testPico12 copy_to_ram)
# Pull in our pico_stdlib which aggregates commonly used features
target_link_libraries(testPico12 pico_stdlib)

# enable usb output, disable uart output
pico_enable_stdio_usb(testPico12 1)
pico_enable_stdio_uart(testPico12 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(testPico12)

