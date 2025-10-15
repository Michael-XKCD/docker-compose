#!/bin/bash

set -e

echo "Installing Android SDK and Command Line Tools..."

# Check if CMD_LINE_VERSION is set, otherwise use default
if [ -z "$CMD_LINE_VERSION" ]; then
    CMD_LINE_VERSION="11076708_latest"
fi

# Download Android command line tools
wget -q "https://dl.google.com/android/repository/commandlinetools-linux-${CMD_LINE_VERSION}.zip" -O commandlinetools.zip

# Extract and organize tools
unzip -q commandlinetools.zip -d ${ANDROID_SDK_ROOT}
mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/tools
mv ${ANDROID_SDK_ROOT}/cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/tools/ 2>/dev/null || true
rm commandlinetools.zip

# Accept licenses
yes | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --licenses

# Install platform tools, emulator, and system image
${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager "platform-tools"
${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager "emulator"
${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager "${ANDROID_PLATFORM_VERSION}"
${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager "${PACKAGE_PATH}"

echo "Android SDK installation completed."