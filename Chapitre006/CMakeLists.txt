cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(testPico9)
pico_sdk_init()
add_executable(testPico9
        testPico9.s
        routinesPico.s
        )

# Pull in our pico_stdlib which aggregates commonly used features
target_link_libraries(testPico9 pico_stdlib)

#add_definitions(-DPICO_ENTER_USB_BOOT_ON_EXIT=1)

# enable usb output, disable uart output
pico_enable_stdio_usb(testPico9 1)
pico_enable_stdio_uart(testPico9 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(testPico9)

# add url via pico_set_program_url
#example_auto_set_url(hello_usb)
