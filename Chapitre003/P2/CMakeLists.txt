cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(testPico8)
pico_sdk_init()
add_executable(testPico8
        testPico8.s
        )

# Pull in our pico_stdlib which aggregates commonly used features
target_link_libraries(testPico8 pico_stdlib)

#add_definitions(-DPICO_ENTER_USB_BOOT_ON_EXIT=1)

# enable usb output, disable uart output
pico_enable_stdio_usb(testPico8 1)
pico_enable_stdio_uart(testPico8 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(testPico8)

# add url via pico_set_program_url
#example_auto_set_url(hello_usb)
