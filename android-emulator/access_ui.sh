#!/bin/bash
# Script to help access the Android emulator UI

echo "🔍 Checking Android Emulator Access Options..."
echo

# Check if container is running
if ! docker ps | grep -q android-emulator; then
    echo "❌ Android emulator container is not running!"
    echo "Start it with: ./deploy.sh dev"
    exit 1
fi

echo "✅ Container is running: android-emulator-dev"

# Get container IP
CONTAINER_IP=$(docker inspect android-emulator-dev | grep '"IPAddress"' | head -1 | cut -d'"' -f4)
echo "📍 Container IP: $CONTAINER_IP"

echo
echo "🖥️  ACCESS OPTIONS:"
echo

echo "1️⃣  Web Browser (noVNC) - May not work on M4 Mac:"
echo "   http://localhost:6080"
echo

echo "2️⃣  macOS Screen Sharing (Recommended for Mac):"
echo "   • Open Finder"
echo "   • Press Cmd+K"
echo "   • Enter: vnc://localhost:5900"
echo "   • Or try: vnc://$CONTAINER_IP:5900"
echo

echo "3️⃣  VNC Client (if you have one installed):"
echo "   • Host: localhost"
echo "   • Port: 5900"
echo "   • Password: (none/empty)"
echo

echo "4️⃣  ADB Connection (Command line):"
echo "   adb connect localhost:5555"
echo "   adb devices"
echo "   adb shell"
echo

# Test web interface
echo "🧪 Testing web interface..."
if curl -s --connect-timeout 3 http://localhost:6080 >/dev/null; then
    echo "✅ Web interface is responding!"
    echo "   Try: open http://localhost:6080"
else
    echo "❌ Web interface not responding"
    echo "   This is common on M4 Mac - use VNC option instead"
fi

echo
echo "💡 Quick Access Commands:"
echo "   ./scripts/manage_games.sh web     # Show web interface URL"
echo "   ./scripts/manage_games.sh status  # Check container status"
echo "   open vnc://localhost:5900         # Open VNC (may work)"

# Try to open Screen Sharing
echo
read -p "🚀 Try to open macOS Screen Sharing now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Opening Screen Sharing..."
    open vnc://localhost:5900 || echo "Could not open Screen Sharing automatically"
fi