#!/usr/bin/env bash
# Fixed launcher for Ktalk with NVIDIA on Wayland/Hyprland
# Solves: eglGetProcAddress not found error

export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json

# CRITICAL: Ensure system NVIDIA libraries are found by GPU process
export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH"

# Force EGL platform (try both Wayland and X11)
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    export EGL_PLATFORM=wayland
    # NVIDIA Wayland specific
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
else
    export EGL_PLATFORM=x11
fi

# Chromium/Electron GPU flags
export CHROMIUM_FLAGS="--use-gl=egl --enable-features=Vulkan --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds"

# WebGL/Canvas flags for virtual background
export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --enable-webgl --enable-webgl2-compute-context --enable-accelerated-2d-canvas"

# Debug logging (optional)
# export ELECTRON_ENABLE_LOGGING=1
# export LIBGL_DEBUG=verbose

echo "=== Ktalk NVIDIA Fixed Launcher ==="
echo "Session: $XDG_SESSION_TYPE"
echo "EGL Platform: $EGL_PLATFORM"
echo "EGL Vendor: $(basename $(readlink -f /run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json 2>/dev/null || echo 'unknown'))"
echo ""

# Run the AppImage
# appimage-run ./ktalk-nvidia-x86_64.AppImage "$@"
appimage-run ./ktalk3.3.0x86_64.AppImage "$@"
