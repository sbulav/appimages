#!/usr/bin/env bash
export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json

# Debug library loading
export LD_DEBUG=libs
export LD_DEBUG_OUTPUT=/tmp/ktalk-ld-debug

echo "=== LIBRARY LOADING DEBUG ==="
echo "LD_DEBUG: $LD_DEBUG"
echo "Output: ${LD_DEBUG_OUTPUT}.${$}"

# Run briefly to capture library loading
timeout 5 appimage-run ./ktalk-nvidia-x86_64.AppImage 2>&1 >/dev/null

# Check for EGL/GL library loading
cat ${LD_DEBUG_OUTPUT}.${$} 2>/dev/null | grep -i "egl\|gl\|nvidia" | head -30
