#!/bin/bash

echo "Starting emulator monitoring..."

# Function to check if emulator is responsive
check_emulator_health() {
    local timeout=30
    local count=0
    
    while [ $count -lt $timeout ]; do
        if ${ANDROID_SDK_ROOT}/platform-tools/adb shell "echo 'test'" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done
    return 1
}

# Function to configure emulator settings
configure_emulator() {
    echo "Configuring emulator settings..."
    
    # Wait for boot completion
    ${ANDROID_SDK_ROOT}/platform-tools/adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed | tr -d '\r') ]]; do sleep 1; done; input keyevent 82'
    
    # Disable animations if requested
    if [ "$DISABLE_ANIMATION" = "true" ]; then
        echo "Disabling animations..."
        ${ANDROID_SDK_ROOT}/platform-tools/adb shell settings put global window_animation_scale 0
        ${ANDROID_SDK_ROOT}/platform-tools/adb shell settings put global transition_animation_scale 0
        ${ANDROID_SDK_ROOT}/platform-tools/adb shell settings put global animator_duration_scale 0
    fi
    
    # Configure hidden policy if requested
    if [ "$DISABLE_HIDDEN_POLICY" = "true" ]; then
        echo "Configuring hidden policy..."
        ${ANDROID_SDK_ROOT}/platform-tools/adb shell settings put global hidden_api_policy_pre_p_apps 1
        ${ANDROID_SDK_ROOT}/platform-tools/adb shell settings put global hidden_api_policy_p_apps 1
        ${ANDROID_SDK_ROOT}/platform-tools/adb shell settings put global hidden_api_policy 1
    fi
    
    # Keep screen awake
    ${ANDROID_SDK_ROOT}/platform-tools/adb shell svc power stayon true
    
    echo "Emulator configuration completed."
}

# Wait for emulator to be ready
echo "Waiting for emulator to be fully ready..."
if check_emulator_health; then
    echo "Emulator is responsive."
    configure_emulator
else
    echo "Warning: Emulator may not be fully responsive."
fi

# Monitor emulator health continuously
while true; do
    if ! check_emulator_health; then
        echo "Warning: Emulator appears to be unresponsive!"
    fi
    
    # Log emulator status every 5 minutes
    sleep 300
    echo "Emulator monitoring check at $(date)"
done