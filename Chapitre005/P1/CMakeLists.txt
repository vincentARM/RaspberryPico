cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(testPico10)
pico_sdk_init()
add_executable(testPico10
        testPico10.s
        routinesPico.s
        )

# Pull in our pico_stdlib which aggregates commonly used features
target_link_libraries(testPico10 pico_stdlib hardware_adc)

#add_definitions(-DPICO_ENTER_USB_BOOT_ON_EXIT=1)

# enable usb output, disable uart output
pico_enable_stdio_usb(testPico10 1)
pico_enable_stdio_uart(testPico10 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(testPico10)

# add url via pico_set_program_url
#example_auto_set_url(hello_usb)
