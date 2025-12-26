# Ktalk Virtual Background Fix for NVIDIA RTX 5070 on NixOS/Wayland

## Problem Summary
- ✅ Camera works normally
- ✅ Screensharing fixed with `__EGL_VENDOR_LIBRARY_FILENAMES`
- ❌ Virtual background/blur shows white screen
- ❌ Error: `eglGetProcAddress not found` in GPU process

## Root Cause
The **GPU process** in Electron/Chromium cannot find the EGL library because:
1. AppImage bundles its own `libEGL.so` which may not be Wayland-compatible
2. NVIDIA's EGL implementation needs specific Wayland extensions
3. GPU process runs in isolated environment without system library paths

## Solutions (Try in Order)

### Solution 1: Launcher Script (Quick Fix)
```bash
./ktalk-nvidia-fixed.sh
```

This script sets up the correct environment:
- Uses system NVIDIA EGL libraries
- Sets proper EGL platform for Wayland
- Configures Chromium GPU flags

### Solution 2: Create Fixed AppImage (Permanent Fix)
```bash
./create_fixed_appimage.sh
```
Creates `ktalk-nvidia-fixed-x86_64.AppImage` that uses system libraries.

### Solution 3: Manual Environment Setup
```bash
export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json
export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH"
export EGL_PLATFORM=wayland
export CHROMIUM_FLAGS="--use-gl=egl --enable-features=Vulkan --ignore-gpu-blocklist"
appimage-run ./ktalk-nvidia-x86_64.AppImage
```

### Solution 4: XWayland Fallback (If Wayland Still Fails)
```bash
export GDK_BACKEND=x11
export QT_QPA_PLATFORM=xcb
export EGL_PLATFORM=x11
export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json
appimage-run ./ktalk-nvidia-x86_64.AppImage
```

## Key Environment Variables
- `__EGL_VENDOR_LIBRARY_FILENAMES`: Points to NVIDIA EGL vendor config
- `LD_LIBRARY_PATH`: Ensures system NVIDIA libraries are found
- `EGL_PLATFORM`: Set to `wayland` or `x11` based on session
- `CHROMIUM_FLAGS`: GPU/WebGL configuration for virtual background

## Testing Virtual Background
After applying fix:
1. Start Ktalk with fixed launcher
2. Join/create a meeting
3. Click camera settings → Background effects
4. Test blur and virtual backgrounds

## If Still Not Working
1. Check WebGL support in app (might need `--enable-webgl`)
2. Try software rendering: `export LIBGL_ALWAYS_SOFTWARE=1`
3. Check app's GPU settings menu
4. Test with different background effect types

## NixOS-Specific Notes
- Ensure `hardware.nvidia` is properly configured
- NVIDIA driver 580.119.02 should work
- Wayland support requires `services.xserver.displayManager.gdm.wayland = true`
