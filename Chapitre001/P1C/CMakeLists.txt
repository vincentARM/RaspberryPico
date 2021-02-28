cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(testPico2C)
pico_sdk_init()
add_executable(testPico2C
        testPico2C.s
        )
#pico_bare_metal(1)
   set(pico_bare_metal 1)
# Pull in our pico_stdlib which aggregates commonly used features
target_link_libraries(testPico2C  pico_runtime pico_platform pico_binary_info  hardware_gpio)
#target_link_libraries(testPico2C  pico_stdlib)
#target_compile_definitions( testPico2C
#CMAKE_ASM_LINK_EXECUTABLE=1
#)
# enable usb output, disable uart output
pico_enable_stdio_usb(testPico2C 0)
pico_enable_stdio_uart(testPico2C 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(testPico2C)

# add url via pico_set_program_url
#example_auto_set_url(hello_usb)
