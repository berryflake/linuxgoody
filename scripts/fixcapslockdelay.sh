#!/bin/bash
# This script fixes the caps lock delay
# Symptom: IF You SEeing THis while you're typing, THen THis is for you.
# This is a known issue, and yet to be fixed, occurrent on most ubuntu / ubuntu-based distro.
# Tow way to fix it, one, try to change your way of typing, try using shift instead of using caps lock.
# Second way, run this script on startup.

xkbcomp -xkb "$DISPLAY" - | sed 's#key <CAPS>.*#key <CAPS> {\
    repeat=no,\
    type[group1]="ALPHABETIC",\
    symbols[group1]=[ Caps_Lock, Caps_Lock],\
    actions[group1]=[ LockMods(modifiers=Lock),\
    Private(type=3,data[0]=1,data[1]=3,data[2]=3)]\
};\
#' | xkbcomp -w 0 - "$DISPLAY"
