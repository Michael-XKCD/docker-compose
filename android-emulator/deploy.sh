#!/bin/bash
# Deployment script for Android Emulator Game Automation
# Handles cross-platform deployment between M4 Mac and x86 server

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

print_header() {
    echo -e "${BLUE}[DEPLOY]${NC} $1"
}

# Function to detect environment
detect_environment() {
    local arch=$(uname -m)
    local os=$(uname -s)
    
    if [[ "$os" == "Darwin" && "$arch" == "arm64" ]]; then
        echo "mac-arm64"
    elif [[ "$os" == "Darwin" && "$arch" == "x86_64" ]]; then
        echo "mac-x86"
    elif [[ "$os" == "Linux" && "$arch" == "x86_64" ]]; then
        echo "linux-x86"
    elif [[ "$os" == "Linux" && "$arch" == "aarch64" ]]; then
        echo "linux-arm64"
    else
        echo "unknown"
    fi
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        exit 1
    fi
    
    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available!"
        exit 1
    fi
    
    # Check ADB (for local testing)
    if ! command -v adb &> /dev/null; then
        print_warning "ADB not found. Install Android SDK platform-tools for local testing."
    fi
    
    print_status "Prerequisites check completed"
}

# Function to setup directories
setup_directories() {
    print_status "Setting up directories..."
    
    # Create required directories
    mkdir -p apks
    mkdir -p game_data
    mkdir -p automation
    
    # Set permissions
    chmod -R 755 scripts/ 2>/dev/null || true
    chmod -R 755 automation/ 2>/dev/null || true
    
    print_status "Directories setup completed"
}

# Function to configure for development (Mac)
configure_dev() {
    print_header "Configuring for development environment (Mac)"
    
    # Copy development configuration
    if [ -f "docker-compose.dev.yml" ]; then
        print_status "Using development configuration"
        export COMPOSE_FILE="docker-compose.dev.yml"
    else
        print_warning "Development config not found, using default"
    fi
    
    # Check if KVM is available (it won't be on Mac)
    print_warning "Hardware acceleration (KVM) not available on macOS"
    print_status "Using software rendering for emulation"
    
    print_status "Development environment configured"
}

# Function to configure for production (Linux server)
configure_prod() {
    print_header "Configuring for production environment (Linux server)"
    
    # Copy production configuration
    if [ -f "docker-compose.prod.yml" ]; then
        print_status "Using production configuration"
        export COMPOSE_FILE="docker-compose.prod.yml"
    else
        print_warning "Production config not found, using default"
    fi
    
    # Check KVM availability
    if [ -e "/dev/kvm" ]; then
        print_status "KVM hardware acceleration available"
    else
        print_warning "KVM not available. Performance may be limited."
        print_status "To enable KVM on Linux:"
        print_status "1. sudo modprobe kvm"
        print_status "2. sudo chmod 666 /dev/kvm"
        print_status "3. Add your user to kvm group: sudo usermod -a -G kvm \$USER"
    fi
    
    # Create production data directory
    local data_dir="/opt/android-emulator-data"
    if [[ $EUID -eq 0 ]]; then
        mkdir -p "$data_dir"
        chmod 755 "$data_dir"
        print_status "Created production data directory: $data_dir"
    else
        print_warning "Run as root to create production data directory: $data_dir"
    fi
    
    print_status "Production environment configured"
}

# Function to pull Docker images
pull_images() {
    print_status "Pulling Docker images..."
    
    # Pull multi-arch images
    docker pull --platform linux/amd64 budtmo/docker-android:emulator_14.0
    docker pull --platform linux/amd64 python:3.11-slim
    
    # Note: budtmo/docker-android only supports AMD64
    # M4 Mac will run AMD64 containers through emulation
    if [[ "$env" == "mac-arm64" ]]; then
        print_status "M4 Mac detected - will run AMD64 containers through emulation"
        print_status "This is normal for Android emulators which typically require x86_64"
    fi
    
    print_status "Docker images pulled successfully"
}

# Function to start services
start_services() {
    local profile="$1"
    print_status "Starting services with profile: $profile"
    
    if [ -n "$profile" ]; then
        docker compose --profile "$profile" up -d
    else
        docker compose up -d
    fi
    
    print_status "Services started. Checking status..."
    docker compose ps
}

# Function to show usage information
show_usage() {
    echo "Android Emulator Deployment Script"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  dev                      - Configure and start development environment"
    echo "  prod                     - Configure and start production environment"
    echo "  setup                    - Just setup directories and check prerequisites"
    echo "  pull                     - Pull Docker images for current platform"
    echo "  start [profile]          - Start services (optionally with profile)"
    echo "  stop                     - Stop all services"
    echo "  clean                    - Stop services and remove volumes"
    echo "  status                   - Show service status"
    echo ""
    echo "Examples:"
    echo "  $0 dev                   # Setup and start development environment"
    echo "  $0 prod                  # Setup and start production environment"
    echo "  $0 start automation      # Start with automation profile"
    echo "  $0 clean                 # Clean shutdown"
}

# Main execution
main() {
    local command="$1"
    local env=$(detect_environment)
    
    print_header "Android Emulator Game Automation Deployment"
    print_status "Detected environment: $env"
    
    case "$command" in
        "dev")
            check_prerequisites
            setup_directories
            configure_dev
            pull_images
            start_services
            print_status "Development environment ready!"
            print_status "Web interface: http://localhost:6080"
            ;;
        "prod")
            check_prerequisites
            setup_directories
            configure_prod
            pull_images
            start_services
            print_status "Production environment ready!"
            print_status "Web interface: http://localhost:6080"
            ;;
        "setup")
            check_prerequisites
            setup_directories
            ;;
        "pull")
            pull_images
            ;;
        "start")
            start_services "$2"
            ;;
        "stop")
            print_status "Stopping services..."
            docker compose down
            ;;
        "clean")
            print_status "Cleaning up..."
            docker compose down -v
            docker system prune -f
            ;;
        "status")
            print_status "Service status:"
            docker compose ps
            print_status "ADB devices:"
            adb devices 2>/dev/null || print_warning "ADB not available"
            ;;
        *)
            show_usage
            ;;
    esac
}

# Run main function with all arguments
main "$@"