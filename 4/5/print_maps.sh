#!/bin/sh
./mapping_loop &
cat /proc/$(pidof mapping_loop)/maps
kill $(pidof mapping_loop)

