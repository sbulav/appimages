#!/usr/bin/env bash
export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json

# Create a temporary directory with symlinks to system libraries
TEMP_DIR=$(mktemp -d)
echo "Using temp directory: $TEMP_DIR"

# Copy the AppImage to temp dir
cp ktalk-nvidia-x86_64.AppImage "$TEMP_DIR/"
chmod +x "$TEMP_DIR/ktalk-nvidia-x86_64.AppImage"

# Extract the AppImage
cd "$TEMP_DIR"
./ktalk-nvidia-x86_64.AppImage --appimage-extract 2>/dev/null
cd squashfs-root

# Replace bundled graphics libraries with system symlinks
echo "=== Replacing bundled libraries with system symlinks ==="

# Backup original libraries
mkdir -p lib-backup
cp -f libEGL.so libGLESv2.so libvulkan.so.1 lib-backup/ 2>/dev/null || true

# Create symlinks to system NVIDIA libraries
ln -sf /run/opengl-driver/lib/libEGL_nvidia.so.0 libEGL.so
ln -sf /run/opengl-driver/lib/libGLESv2_nvidia.so libGLESv2.so
ln -sf /run/opengl-driver/lib/libvulkan.so.1 libvulkan.so.1

# Also symlink other possible needed libraries
ln -sf /run/opengl-driver/lib/libnvidia-egl-wayland.so.1 libnvidia-egl-wayland.so.1 2>/dev/null || true

echo "=== Testing with system libraries ==="
echo "Current libEGL.so: $(readlink -f libEGL.so || echo 'not a symlink')"
echo "Current libGLESv2.so: $(readlink -f libGLESv2.so || echo 'not a symlink')"

# Test the modified AppImage
export LD_LIBRARY_PATH="$PWD:$LD_LIBRARY_PATH"
./AppRun --no-sandbox 2>&1 | grep -i "egl\|gl\|gpu\|error\|fail" | head -20

# Cleanup
cd /home/sab/Downloads
rm -rf "$TEMP_DIR"
