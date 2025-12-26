#!/usr/bin/env bash
# Create a fixed AppImage that uses system NVIDIA libraries

echo "=== Creating fixed AppImage ==="
echo "Original: ktalk-nvidia-x86_64.AppImage"
echo ""

# Extract the AppImage
echo "Extracting AppImage..."
./ktalk-nvidia-x86_64.AppImage --appimage-extract 2>/dev/null

if [ ! -d squashfs-root ]; then
    echo "Failed to extract AppImage"
    exit 1
fi

cd squashfs-root

echo "Replacing graphics libraries with system symlinks..."
# Remove bundled graphics libraries
rm -f libEGL.so libGLESv2.so libvulkan.so.1 libvk_swiftshader.so

# Create launcher script that uses system libraries
cat > AppRun.fixed << 'LAUNCHER_EOF'
#!/usr/bin/env bash
export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json
export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH"

# Set EGL platform based on session
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    export EGL_PLATFORM=wayland
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
else
    export EGL_PLATFORM=x11
fi

# GPU flags
export CHROMIUM_FLAGS="--use-gl=egl --enable-features=Vulkan --ignore-gpu-blocklist"

# Run the binary
exec ./ktalk "$@"
LAUNCHER_EOF

chmod +x AppRun.fixed

# Replace original AppRun
mv AppRun AppRun.original
mv AppRun.fixed AppRun

echo "Creating new AppImage..."
cd ..
appimagetool squashfs-root ktalk-nvidia-fixed-x86_64.AppImage 2>/dev/null

if [ -f ktalk-nvidia-fixed-x86_64.AppImage ]; then
    echo ""
    echo "✓ Fixed AppImage created: ktalk-nvidia-fixed-x86_64.AppImage"
    echo "Size: $(du -h ktalk-nvidia-fixed-x86_64.AppImage | cut -f1)"
    echo ""
    echo "Usage:"
    echo "  ./ktalk-nvidia-fixed-x86_64.AppImage"
    echo ""
    echo "This version uses system NVIDIA libraries instead of bundled ones."
else
    echo "Failed to create new AppImage"
fi

# Cleanup
rm -rf squashfs-root
