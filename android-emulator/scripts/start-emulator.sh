#!/bin/bash

set -e

echo "Starting Android Emulator..."

# Set default values if not provided
MEMORY=${MEMORY:-8192}
CORES=${CORES:-8}
DISABLE_ANIMATION=${DISABLE_ANIMATION:-false}
DISABLE_HIDDEN_POLICY=${DISABLE_HIDDEN_POLICY:-true}
SKIP_AUTH=${SKIP_AUTH:-false}

# Create AVD if it doesn't exist
AVD_NAME="emulator"
if [ ! -d "${ANDROID_AVD_HOME}/${AVD_NAME}.avd" ]; then
    echo "Creating AVD: ${AVD_NAME}"
    echo "no" | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/avdmanager create avd \
        --force \
        --name "${AVD_NAME}" \
        --device "${DEVICE_ID}" \
        --package "${PACKAGE_PATH}" \
        --tag "${IMG_TYPE}" \
        --abi "${ARCHITECTURE}"
        
    # Configure AVD
    echo "hw.ramSize=${MEMORY}" >> ${ANDROID_AVD_HOME}/${AVD_NAME}.avd/config.ini
    echo "hw.keyboard=yes" >> ${ANDROID_AVD_HOME}/${AVD_NAME}.avd/config.ini
    echo "hw.cpu.ncore=${CORES}" >> ${ANDROID_AVD_HOME}/${AVD_NAME}.avd/config.ini
    echo "disk.dataPartition.size=8192MB" >> ${ANDROID_AVD_HOME}/${AVD_NAME}.avd/config.ini
fi

# Start virtual display
export DISPLAY=:0
Xvfb :0 -screen 0 1920x1080x24 &

# Start window manager
fluxbox &

# Start VNC server (optional)
x11vnc -display :0 -nopw -listen localhost -xkb -ncache 10 -ncache_cr -forever &

# Configure animation settings
if [ "$DISABLE_ANIMATION" = "true" ]; then
    ANIMATION_ARGS="-no-window-animation -no-snapshot-save -no-snapshot-load"
else
    ANIMATION_ARGS=""
fi

# Configure authentication
if [ "$SKIP_AUTH" = "true" ]; then
    AUTH_ARGS="-no-auth"
else
    AUTH_ARGS=""
fi

# Start emulator with appropriate settings
echo "Starting emulator with AVD: ${AVD_NAME}"
${ANDROID_SDK_ROOT}/emulator/emulator \
    -avd "${AVD_NAME}" \
    -port 5554 \
    -no-audio \
    -no-skin \
    -no-window \
    -accel auto \
    -gpu swiftshader_indirect \
    -camera-back none \
    -camera-front none \
    ${ANIMATION_ARGS} \
    ${AUTH_ARGS} \
    -verbose &

# Wait for emulator to start
echo "Waiting for emulator to start..."
${ANDROID_SDK_ROOT}/platform-tools/adb wait-for-device

# Start monitoring script in background
/opt/emulator-monitoring.sh &

# Keep container running
wait