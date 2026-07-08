#!/bin/sh
set -xe

OS="$(uname -s)"

RAYLIB="./Libraries/raylib-6.0_linux_amd64_macos"

if [ $OS = "Linux" ]; then
    swiftc \
      -static -static-stdlib \
      Sources/main.swift \
      -I $RAYLIB/include \
      -L $RAYLIB/lib \
      $RAYLIB/lib/libraylib_linux.a \
      -lm -lX11
fi

if [ $OS = "Darwin" ]; then
    swiftc \
      -static \
      Sources/main.swift \
      -I $RAYLIB/include \
      -L $RAYLIB/lib \
      $RAYLIB/lib/libraylib_macos.a \
      -framework Cocoa -framework IOKit -framework CoreVideo -framework OpenGL
fi
