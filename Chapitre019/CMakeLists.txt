cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(testTelnet)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()
add_executable(testTelnet
        pgmTelnetAsm.s
        )

# Pull in our pico_stdlib which aggregates commonly used features
target_link_libraries(testTelnet 
            pico_cyw43_arch_lwip_threadsafe_background 
            pico_lwip_http
            pico_stdlib)
target_compile_definitions(testTelnet PRIVATE
            WIFI_SSID=\"${WIFI_SSID}\"
            WIFI_PASSWORD=\"${WIFI_PASSWORD}\"
            TEST_TCP_SERVER_IP=\"${TEST_TCP_SERVER_IP}\"
            )
    target_include_directories(testTelnet PRIVATE
            ${CMAKE_CURRENT_LIST_DIR}
            ${CMAKE_CURRENT_LIST_DIR}/.. # for our common lwipopts
            )

#add_definitions(-DPICO_ENTER_USB_BOOT_ON_EXIT=1)

# enable usb output, disable uart output
pico_enable_stdio_usb(testTelnet 1)
pico_enable_stdio_uart(testTelnet 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(testTelnet)

# add url via pico_set_program_url
#example_auto_set_url(hello_usb)
