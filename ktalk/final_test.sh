#!/usr/bin/env bash
export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json

echo "=== FINAL COMPREHENSIVE TEST ==="
echo "Problem: eglGetProcAddress not found"
echo "Hypothesis: GPU process can't find EGL library in AppImage environment"
echo ""

# Test 1: Check if EGL library exists in AppImage
echo "Test 1: Checking EGL library in AppImage..."
appimage-run ./ktalk-nvidia-x86_64.AppImage --appimage-extract 2>/dev/null
if [ -f squashfs-root/libEGL.so ]; then
    echo "✓ libEGL.so found in AppImage"
    file squashfs-root/libEGL.so
else
    echo "✗ libEGL.so NOT found in AppImage"
fi

# Test 2: Check EGL library compatibility
echo ""
echo "Test 2: Checking EGL library compatibility..."
if [ -f squashfs-root/libEGL.so ]; then
    ldd squashfs-root/libEGL.so 2>/dev/null | grep -i nvidia || echo "Not linked to NVIDIA libraries"
fi

# Test 3: Create a fixed wrapper
echo ""
echo "Test 3: Creating fixed wrapper..."
cat > ktalk-fixed << 'FIXED_EOF'
#!/usr/bin/env bash
export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json

# Critical fix: Ensure EGL libraries are found
export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH"

# Force EGL platform
export EGL_PLATFORM=wayland

# Chromium flags to help with GPU
export CHROMIUM_FLAGS="--use-gl=egl --enable-features=Vulkan"

# Debug
echo "=== Fixed wrapper environment ==="
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "EGL_PLATFORM: $EGL_PLATFORM"

# Run
appimage-run ./ktalk-nvidia-x86_64.AppImage "$@"
FIXED_EOF

chmod +x ktalk-fixed

echo "Wrapper created. Test with:"
echo "  ./ktalk-fixed"
echo ""
echo "If virtual background still doesn't work, try:"
echo "  1. Check if WebGL is working in app"
echo "  2. Try with --disable-gpu-compositing flag"
echo "  3. Check app's GPU settings"

# Cleanup
rm -rf squashfs-root
