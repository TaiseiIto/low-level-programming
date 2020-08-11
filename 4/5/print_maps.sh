#!/bin/sh
./mappings_loop.exe &
cat /proc/$(pidof mappings_loop.exe)/maps
kill $(pidof mappings_loop.exe)

