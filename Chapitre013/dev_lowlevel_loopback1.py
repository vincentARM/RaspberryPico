#!/usr/bin/env python3

#
# Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
#
# SPDX-License-Identifier: BSD-3-Clause
#

# sudo pip3 install pyusb

import usb.core
import usb.util
import time 

#import usb.backend.libusb1

#backend = usb.backend.libusb1.get_backend(find_library=lambda x: "E:\\USB\\libusb-win32-bin-1.2.6.0\\libusb-win32-bin-1.2.6.0\\bin\\x86\\libusb0_x86.dll")
#dev = usb.core.find(backend=backend, find_all=True)
print("*****************************")
print("Connexion USB Raspberry Pico.")
print("*****************************")
# find our device
dev = usb.core.find(idVendor=0x0000, idProduct=0x0001)

# was it found?
if dev is None:
    raise ValueError('Device not found')

# get an endpoint instance
cfg = dev.get_active_configuration()
intf = cfg[(0, 0)]

outep = usb.util.find_descriptor(
    intf,
    # match the first OUT endpoint
    custom_match= \
        lambda e: \
            usb.util.endpoint_direction(e.bEndpointAddress) == \
            usb.util.ENDPOINT_OUT)

inep = usb.util.find_descriptor(
    intf,
    # match the first IN endpoint
    custom_match= \
        lambda e: \
            usb.util.endpoint_direction(e.bEndpointAddress) == \
            usb.util.ENDPOINT_IN)

assert inep is not None
assert outep is not None

test_string = "#Pret#"
outep.write(test_string)

from_device = inep.read(len(test_string))
print("{}".format(''.join([chr(x) for x in from_device])))

test_string = "#Att#"
while True:
    outep.write(test_string)
    from_device = inep.read(128)
    #print(repr(from_device))
    #print(len(from_device))
    #if from_device:
    deb=from_device[0:5]
    #print(repr(deb[4]))
    #print(repr(deb))
    #print(repr(deb2))
    if "{}".format(''.join(map(chr, deb))) == "#Rep#": 
        reponse = input()
        outep.write(reponse)
        time.sleep(0.2)
        from_device = inep.read(128)
    elif "{}".format(''.join(map(chr, deb))) != "#Att#":
        print("{}".format(''.join(map(chr, from_device))))
    time.sleep(0.2)
# while

#from_device = inep.read(-1)
#print("Device Says: {}".format(''.join([chr(x) for x in from_device])))

