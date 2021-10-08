cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(testPico24A)
pico_sdk_init()
add_executable(testPico24A
        testPico24A.s
        routinesPico.s
        )

#pico_set_binary_type(testPico24A no_flash)
# Pull in our pico_stdlib which aggregates commonly used features
target_link_libraries(testPico24A pico_stdlib hardware_adc)

#add_definitions(-DPICO_ENTER_USB_BOOT_ON_EXIT=1)

# enable usb output, disable uart output
pico_enable_stdio_usb(testPico24A 1)
pico_enable_stdio_uart(testPico24A 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(testPico24A)
