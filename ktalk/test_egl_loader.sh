#!/usr/bin/env bash
export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json

# Create a simple test program to check EGL loading
cat > /tmp/test_egl.c << 'C_EOF'
#include <EGL/egl.h>
#include <stdio.h>
#include <dlfcn.h>

int main() {
    void* handle = dlopen("libEGL.so.1", RTLD_LAZY);
    if (!handle) {
        printf("Failed to load libEGL.so.1: %s\n", dlerror());
        return 1;
    }
    
    void* sym = dlsym(handle, "eglGetProcAddress");
    if (!sym) {
        printf("eglGetProcAddress not found in loaded library\n");
        dlclose(handle);
        return 1;
    }
    
    printf("Successfully loaded EGL library and found eglGetProcAddress\n");
    dlclose(handle);
    return 0;
}
C_EOF

# Compile and run
gcc -o /tmp/test_egl /tmp/test_egl.c -ldl 2>/dev/null
if [ -f /tmp/test_egl ]; then
    echo "=== Testing EGL library loading ==="
    /tmp/test_egl
    echo "=== Testing with LD_LIBRARY_PATH ==="
    LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH" /tmp/test_egl
fi
