#!/usr/bin/env bash
# Fixed launcher for Ktalk with NVIDIA on NixOS/Wayland
# Solves virtual background white screen issue

# Set EGL vendor to NVIDIA
export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json

# CRITICAL: Add system NVIDIA libraries to library path
export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH"

# Set EGL platform based on current session
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "Detected Wayland session"
    export EGL_PLATFORM=wayland
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
else
    echo "Detected X11 session"
    export EGL_PLATFORM=x11
fi

# GPU configuration for virtual background support
export CHROMIUM_FLAGS="--use-gl=egl --enable-features=Vulkan --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds"
export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --enable-webgl --enable-webgl2-compute-context --enable-accelerated-2d-canvas"

# Optional debug logging (uncomment if needed)
# export ELECTRON_ENABLE_LOGGING=1
# export LIBGL_DEBUG=verbose

echo "========================================="
echo "Ktalk NVIDIA Fixed Launcher"
echo "========================================="
echo "Session: $XDG_SESSION_TYPE"
echo "EGL Platform: $EGL_PLATFORM"
echo "EGL Vendor: NVIDIA"
echo "Library Path: /run/opengl-driver/lib"
echo "========================================="
echo ""
echo "Starting Ktalk with fixed GPU configuration..."
echo "Virtual background should now work correctly."
echo ""

# Run the AppImage
exec appimage-run ./ktalk-nvidia-x86_64.AppImage "$@"