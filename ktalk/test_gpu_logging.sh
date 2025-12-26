#!/usr/bin/env bash
export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json

# Enable detailed logging
export ELECTRON_ENABLE_LOGGING=1
export ELECTRON_ENABLE_STACK_DUMPING=1
export LIBGL_DEBUG=verbose
export MESA_DEBUG=1

# Chromium/Electron GPU flags
export CHROMIUM_FLAGS="--enable-logging=stderr --v=1 --use-gl=egl --log-level=0 --enable-gpu-debugging --enable-gpu-service-logging"

echo "=== GPU DEBUGGING ENABLED ==="
echo "LIBGL_DEBUG: $LIBGL_DEBUG"
echo "CHROMIUM_FLAGS: $CHROMIUM_FLAGS"

# Run with logging
appimage-run ./ktalk-nvidia-x86_64.AppImage 2>&1 | tee /tmp/ktalk-gpu-debug.log | grep -i "egl\|gl\|gpu\|vulkan\|error\|fail\|warn\|background" | head -50
