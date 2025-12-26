#!/usr/bin/env bash
export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json

# Force X11 backend for GUI toolkits
export GDK_BACKEND=x11
export QT_QPA_PLATFORM=xcb
export SDL_VIDEODRIVER=x11

# Force EGL platform to X11 (not Wayland)
export EGL_PLATFORM=x11

echo "Testing with XWayland fallback..."
echo "EGL vendor: $__EGL_VENDOR_LIBRARY_FILENAMES"
echo "GDK_BACKEND: $GDK_BACKEND"
echo "EGL_PLATFORM: $EGL_PLATFORM"

appimage-run ./ktalk-nvidia-x86_64.AppImage
