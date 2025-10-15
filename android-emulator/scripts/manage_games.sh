#!/bin/bash
# Game Management Helper Script
# Provides easy commands for common game automation tasks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
EMULATOR_CONTAINER="android-emulator"
AUTOMATION_CONTAINER="game-automation"
ADB_ADDRESS="localhost:5555"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if containers are running
check_containers() {
    print_status "Checking container status..."
    
    if ! docker ps | grep -q $EMULATOR_CONTAINER; then
        print_error "Android emulator container is not running!"
        echo "Start it with: docker-compose up -d android-emulator"
        exit 1
    fi
    
    print_status "Emulator container is running"
}

# Function to wait for emulator to be ready
wait_for_emulator() {
    print_status "Waiting for emulator to be ready..."
    
    # Connect ADB
    adb connect $ADB_ADDRESS >/dev/null 2>&1 || true
    
    local max_attempts=60
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if adb -s $ADB_ADDRESS get-state 2>/dev/null | grep -q "device"; then
            if adb -s $ADB_ADDRESS shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; then
                print_status "Emulator is ready!"
                return 0
            fi
        fi
        
        sleep 2
        attempt=$((attempt + 1))
        
        if [ $((attempt % 15)) -eq 0 ]; then
            print_status "Still waiting for emulator... ($attempt/$max_attempts)"
        fi
    done
    
    print_error "Emulator failed to become ready!"
    return 1
}

# Function to install APKs
install_apks() {
    print_status "Installing APK files..."
    
    if [ ! -d "./apks" ] || [ -z "$(ls -A ./apks 2>/dev/null)" ]; then
        print_warning "No APK files found in ./apks directory"
        return 0
    fi
    
    local installed=0
    for apk in ./apks/*.apk; do
        if [ -f "$apk" ]; then
            print_status "Installing $(basename "$apk")..."
            if adb -s $ADB_ADDRESS install -r "$apk"; then
                installed=$((installed + 1))
                print_status "Successfully installed $(basename "$apk")"
            else
                print_error "Failed to install $(basename "$apk")"
            fi
        fi
    done
    
    print_status "Installed $installed APK files"
}

# Function to list installed packages
list_packages() {
    print_status "Listing installed packages (excluding system apps)..."
    adb -s $ADB_ADDRESS shell pm list packages -3 | sed 's/package://g'
}

# Function to launch an app
launch_app() {
    local package_name="$1"
    if [ -z "$package_name" ]; then
        print_error "Package name required"
        echo "Usage: $0 launch <package_name>"
        return 1
    fi
    
    print_status "Launching $package_name..."
    adb -s $ADB_ADDRESS shell monkey -p "$package_name" -c android.intent.category.LAUNCHER 1
}

# Function to configure emulator for idle games
configure_emulator() {
    print_status "Configuring emulator for idle games..."
    
    # Keep screen on
    adb -s $ADB_ADDRESS shell svc power stayon true
    
    # Disable animations
    adb -s $ADB_ADDRESS shell settings put global window_animation_scale 0
    adb -s $ADB_ADDRESS shell settings put global transition_animation_scale 0
    adb -s $ADB_ADDRESS shell settings put global animator_duration_scale 0
    
    # Unlock screen
    adb -s $ADB_ADDRESS shell input keyevent KEYCODE_WAKEUP
    adb -s $ADB_ADDRESS shell input keyevent KEYCODE_MENU
    
    print_status "Emulator configuration completed"
}

# Function to take a screenshot
screenshot() {
    local filename="${1:-screenshot_$(date +%Y%m%d_%H%M%S).png}"
    print_status "Taking screenshot: $filename"
    adb -s $ADB_ADDRESS shell screencap -p > "./game_data/$filename"
    print_status "Screenshot saved to ./game_data/$filename"
}

# Function to start automation
start_automation() {
    print_status "Starting game automation..."
    docker-compose up -d --profile automation
    print_status "Automation container started. View logs with: docker-compose logs -f game-automation"
}

# Function to show web interface URL
show_web_interface() {
    print_status "Web interface (noVNC) should be available at:"
    echo "http://localhost:6080"
    print_status "Use this to view and interact with the emulator"
}

# Main command handling
case "$1" in
    "start")
        print_status "Starting Android emulator..."
        docker-compose up -d android-emulator
        wait_for_emulator
        configure_emulator
        show_web_interface
        ;;
    "stop")
        print_status "Stopping containers..."
        docker-compose down
        ;;
    "install")
        check_containers
        wait_for_emulator
        install_apks
        ;;
    "list")
        check_containers
        wait_for_emulator
        list_packages
        ;;
    "launch")
        check_containers
        wait_for_emulator
        launch_app "$2"
        ;;
    "configure")
        check_containers
        wait_for_emulator
        configure_emulator
        ;;
    "screenshot")
        check_containers
        wait_for_emulator
        screenshot "$2"
        ;;
    "automation")
        check_containers
        start_automation
        ;;
    "web")
        show_web_interface
        ;;
    "status")
        print_status "Container status:"
        docker-compose ps
        if docker ps | grep -q $EMULATOR_CONTAINER; then
            print_status "ADB status:"
            adb devices
        fi
        ;;
    "logs")
        if [ -n "$2" ]; then
            docker-compose logs -f "$2"
        else
            docker-compose logs -f android-emulator
        fi
        ;;
    *)
        echo "Android Emulator Game Manager"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  start                    - Start the emulator and configure it"
        echo "  stop                     - Stop all containers"
        echo "  install                  - Install all APK files from ./apks directory"
        echo "  list                     - List installed packages"
        echo "  launch <package>         - Launch a specific app by package name"
        echo "  configure                - Configure emulator settings for idle games"
        echo "  screenshot [filename]    - Take a screenshot"
        echo "  automation               - Start the automation container"
        echo "  web                      - Show web interface URL"
        echo "  status                   - Show container and ADB status"
        echo "  logs [container]         - Show container logs"
        echo ""
        echo "Examples:"
        echo "  $0 start                                    # Start emulator"
        echo "  $0 install                                  # Install APKs"
        echo "  $0 launch com.example.idlegame              # Launch a game"
        echo "  $0 screenshot my_game.png                   # Take screenshot"
        ;;
esac