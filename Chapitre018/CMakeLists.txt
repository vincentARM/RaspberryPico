cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(serveurWifi)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()
add_executable(serveurWifi
        serveurWifiAsm.s
        )

# Pull in our pico_stdlib which aggregates commonly used features
target_link_libraries(serveurWifi 
            pico_cyw43_arch_lwip_threadsafe_background 
            pico_lwip_http
            pico_stdlib)
#target_compile_definitions(serveurWifi PRIVATE
      #      WIFI_SSID=\"${WIFI_SSID}\"
       #     WIFI_PASSWORD=\"${WIFI_PASSWORD}\"
      #      TEST_TCP_SERVER_IP=\"${TEST_TCP_SERVER_IP}\"
     #       )
    target_include_directories(serveurWifi PRIVATE
            ${CMAKE_CURRENT_LIST_DIR}
            ${CMAKE_CURRENT_LIST_DIR}/.. # for our common lwipopts
            )


# Aucun message vers usb ou uart 
pico_enable_stdio_usb(serveurWifi 1)
pico_enable_stdio_uart(serveurWifi 1)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(serveurWifi)

