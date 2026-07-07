#!/bin/sh
set -xe

swiftc -static -static-stdlib Sources/main.swift \
  -I ./Libraries/raylib-6.0_linux_amd64/include \
  -L ./Libraries/raylib-6.0_linux_amd64/lib \
  ./Libraries/raylib-6.0_linux_amd64/lib/libraylib.a \
  -lm -lX11

