# Android Emulator Docker Project

A cross-platform Docker-based Android emulator setup designed to run Android applications, specifically optimized for running idle games automatically. Supports development on M4 Mac and production deployment on x86 Linux servers.

## Project Overview

This project creates a containerized Android emulator that can:
- Run Android API Level 34 (Android 14) with Google APIs
- Provide ADB access for automation and app installation
- Run headless with noVNC web interface for remote viewing
- Be configured for optimal performance with customizable CPU and memory settings
- Support cross-platform development (M4 Mac ↔ x86 Linux server)
- Automate idle game management with Python scripts

## Project Structure

```
android-emulator/
├── README.md                    # This documentation
├── deploy.sh                    # Cross-platform deployment script
├── docker-compose.yml           # Default service configuration
├── docker-compose.dev.yml       # Development configuration (M4 Mac)
├── docker-compose.prod.yml      # Production configuration (x86 server)
├── Dockerfile                   # Custom container build (legacy)
├── apks/                        # Place APK files here for installation
├── game_data/                   # Screenshots, logs, and game data
├── automation/                  # Python automation scripts
│   ├── game_manager.py          # Main automation script
│   └── requirements.txt         # Python dependencies
├── keys/                        # ADB authentication keys
│   ├── adbkey                   # Private key for ADB
│   └── adbkey.pub               # Public key for ADB
└── scripts/                     # Helper scripts
    ├── manage_games.sh          # Game management utilities
    ├── install-sdk.sh           # Android SDK installation (legacy)
    ├── start-emulator.sh        # Emulator startup script (legacy)
    └── emulator-monitoring.sh   # Health monitoring (legacy)
```

## ✅ Current Status: Cross-Platform Ready

This project now provides a **working cross-platform solution**:

✅ **Cross-Platform Support**: M4 Mac development ↔ x86 Linux server deployment  
✅ **Proven Base Image**: Uses `budtmo/docker-android` instead of custom build  
✅ **Automation Ready**: Python scripts for game management and automation  
✅ **Web Interface**: noVNC access at http://localhost:6080  
✅ **Hardware Acceleration**: KVM support on Linux servers  
✅ **Easy Deployment**: One-command setup for dev/prod environments

## 🚀 Quick Start

### For Development (M4 Mac)
```bash
# Clone and enter the project
git clone <your-repo>
cd android-emulator

# Start development environment
./deploy.sh dev

# Note: May take 2-5 minutes to fully boot
# Check status: ./deploy.sh status
# View logs: docker-compose -f docker-compose.dev.yml logs -f

# Access web interface (once emulator boots)
open http://localhost:6080
```

> ⚠️ **M4 Mac Note**: Android emulation on M4 Mac runs through CPU emulation and may be slow or unstable. Consider developing automation scripts locally and testing on your Linux server for best results.

### For Production (x86 Linux Server)
```bash
# Clone and enter the project
git clone <your-repo>
cd android-emulator

# Start production environment
./deploy.sh prod

# Access web interface
http://your-server-ip:6080
```

### Manual Game Management
```bash
# Place APK files in ./apks/ directory
cp ~/Downloads/idle-game.apk ./apks/

# Install APKs and configure emulator
./scripts/manage_games.sh start
./scripts/manage_games.sh install

# Launch a game
./scripts/manage_games.sh launch com.example.idlegame

# Take a screenshot
./scripts/manage_games.sh screenshot game_progress.png
```

## Configuration Options

### Environment Configurations

#### Development Configuration (`docker-compose.dev.yml`)
- **Platform**: linux/amd64 (runs via emulation on M4 Mac)
- **Memory**: 4GB RAM
- **CPU Cores**: 4 cores
- **Resolution**: 1280x720
- **Hardware Acceleration**: Software rendering
- **Use Case**: Local testing and development

#### Production Configuration (`docker-compose.prod.yml`)
- **Platform**: linux/amd64 (x86 server)
- **Memory**: 16GB RAM
- **CPU Cores**: 16 cores
- **Resolution**: 1920x1080
- **Hardware Acceleration**: KVM (when available)
- **Use Case**: 24/7 game automation

### Key Environment Variables

| Variable | Dev Default | Prod Default | Description |
|----------|-------------|--------------|-------------|
| `EMULATOR_DEVICE` | Samsung Galaxy S6 | Samsung Galaxy S10 | Device profile |
| `EMULATOR_ARGS` | 4GB/4 cores | 16GB/16 cores | Memory and CPU allocation |
| `RESOLUTION` | 1280x720 | 1920x1080 | Screen resolution |
| `DISABLE_ANIMATIONS` | true | true | Disable animations for performance |
| `SCREEN_ALWAYS_ON` | true | true | Prevent screen timeout |

### Ports

- `6080`: noVNC web interface
- `5554`: Android emulator console port
- `5555`: ADB connection port
- `9100`: Monitoring (production only)

### Volumes

- `./apks/`: APK files for installation
- `./game_data/`: Screenshots, logs, and save data
- `./automation/`: Python automation scripts
- `android_avd_data_*`: Persistent Android Virtual Device data

## 🛠️ Deployment Commands

### Using Deploy Script (Recommended)

```bash
# Development environment (M4 Mac)
./deploy.sh dev                    # Setup and start development
./deploy.sh setup                  # Just setup directories
./deploy.sh status                 # Check service status
./deploy.sh stop                   # Stop services
./deploy.sh clean                  # Clean shutdown with volume removal

# Production environment (x86 Linux server)
./deploy.sh prod                   # Setup and start production
sudo ./deploy.sh prod              # Run as root for optimal setup
```

### Using Docker Compose Directly

```bash
# Development
docker-compose -f docker-compose.dev.yml up -d
docker-compose -f docker-compose.dev.yml --profile automation up -d

# Production
docker-compose -f docker-compose.prod.yml up -d
docker-compose -f docker-compose.prod.yml --profile automation,monitoring up -d

# Default configuration
docker-compose up -d
```

### Using Game Management Script

```bash
# Start and configure emulator
./scripts/manage_games.sh start

# Install APKs from ./apks/ directory
./scripts/manage_games.sh install

# List installed games
./scripts/manage_games.sh list

# Launch a specific game
./scripts/manage_games.sh launch com.example.game

# Take screenshot
./scripts/manage_games.sh screenshot

# Start automation
./scripts/manage_games.sh automation

# View web interface URL
./scripts/manage_games.sh web

# Check status
./scripts/manage_games.sh status

# View logs
./scripts/manage_games.sh logs
```

### Manual ADB Commands

```bash
# Connect to emulator
adb connect localhost:5555

# List connected devices
adb devices

# Install APK manually
adb -s localhost:5555 install path/to/game.apk

# Launch an app
adb -s localhost:5555 shell monkey -p com.example.game -c android.intent.category.LAUNCHER 1

# Take screenshot
adb -s localhost:5555 shell screencap -p > screenshot.png

# Send tap/swipe commands
adb -s localhost:5555 shell input tap 500 500
adb -s localhost:5555 shell input swipe 300 300 700 700 1000
```

## 🤖 Game Automation

### Python Automation Script

The project includes a comprehensive Python automation script (`automation/game_manager.py`) that can:

- **Auto-install APKs**: Automatically install all APK files from the `./apks/` directory
- **Configure emulator**: Optimize settings for idle games (disable animations, keep screen on)
- **Launch games**: Start games and keep them running
- **Monitor health**: Check if games are still active and restart if needed
- **Take screenshots**: Capture game progress for monitoring

### Automation Features

```python
# Key automation capabilities:

# Install all APKs automatically
manager.install_all_apks()

# Configure for idle games
manager.configure_emulator_for_idle_games()

# Launch and monitor games
manager.launch_app('com.example.idlegame')
manager.keep_games_active(['game1', 'game2'], check_interval=300)
```

### Custom Automation

To add custom automation for specific games:

1. **Edit `automation/game_manager.py`**:
   ```python
   def custom_game_automation(self, package_name):
       # Your custom automation logic
       self.run_adb_command(['shell', 'input', 'tap', '500', '500'])
       time.sleep(10)
       self.run_adb_command(['shell', 'input', 'swipe', '100', '100', '900', '900', '1000'])
   ```

2. **Run with automation profile**:
   ```bash
   docker-compose --profile automation up -d
   ```

## 🛠️ Troubleshooting

### Cross-Platform Issues

1. **M4 Mac Development Issues**
   ```bash
   # Android emulators require AMD64, even on M4 Mac
   # This is normal - Docker will run AMD64 through emulation
   ./deploy.sh dev
   
   # If you see platform warnings, this is expected:
   # "budtmo/docker-android only supports AMD64 architecture"
   ```

2. **x86 Server Performance Issues**
   ```bash
   # Enable KVM for hardware acceleration
   sudo modprobe kvm
   sudo chmod 666 /dev/kvm
   sudo usermod -a -G kvm $USER
   
   # Use production configuration
   sudo ./deploy.sh prod
   ```

3. **Container Communication Issues**
   ```bash
   # Check network connectivity
   docker network ls
   docker-compose exec game-automation ping android-emulator
   
   # Restart with fresh network
   docker-compose down
   docker-compose up -d
   ```

### Common Solutions

1. **Emulator won't start**
   ```bash
   # Check logs
   docker-compose logs android-emulator
   
   # Try with less resources
   # Edit EMULATOR_ARGS in docker-compose.yml:
   # -memory 4096 -cores 4
   ```

2. **ADB connection issues**
   ```bash
   # Reset ADB connection
   adb kill-server
   adb start-server
   adb connect localhost:5555
   ```

3. **Web interface not accessible**
   ```bash
   # Check if port is available
   lsof -i :6080
   
   # Access via container IP
   docker inspect android-emulator | grep IPAddress
   ```

### Debug Commands

```bash
# Container status
./deploy.sh status
./scripts/manage_games.sh status

# View logs
docker-compose logs -f android-emulator
docker-compose logs -f game-automation

# Enter containers
docker-compose exec android-emulator /bin/bash
docker-compose exec game-automation /bin/bash

# Check emulator health
adb -s localhost:5555 shell getprop sys.boot_completed
adb -s localhost:5555 shell dumpsys battery
```

## 💻 System Requirements

### Development Environment (M4 Mac)
- **RAM**: 8GB minimum (16GB recommended)
- **CPU**: Apple M4 with 4+ cores available to Docker
- **Storage**: 10GB free space
- **Software**: Docker Desktop for Mac
- **Network**: Internet access for image downloads

### Production Environment (x86 Linux Server)
- **RAM**: 16GB minimum (32GB recommended for multiple games)
- **CPU**: Intel Xeon or equivalent with 8+ cores
- **Storage**: 50GB+ free space (for games and save data)
- **OS**: Ubuntu 20.04+ or equivalent with KVM support
- **Network**: Stable internet connection
- **Hardware Acceleration**: KVM enabled (`/dev/kvm` accessible)

### Resource Allocation Guide

| Use Case | RAM | CPU Cores | Storage | Performance |
|----------|-----|-----------|---------|-------------|
| Single idle game | 4GB | 4 cores | 20GB | Good |
| Multiple idle games | 8GB | 8 cores | 50GB | Better |
| 24/7 automation | 16GB+ | 16 cores | 100GB+ | Best |

## ⚙️ Optimization for Idle Games

This project is specifically optimized for idle/incremental games:

### Performance Optimizations
- **⚡ Animations Disabled**: Removes UI lag and speeds up interactions
- **📱 Screen Always On**: Prevents games from pausing due to screen timeout
- **🧠 Memory Optimized**: Large RAM allocation prevents crashes during long sessions
- **🏆 Multi-Core Processing**: Utilizes multiple CPU cores for smooth operation
- **🔍 Hardware Acceleration**: KVM support on Linux for maximum performance

### Game Management Features
- **📦 Auto APK Installation**: Bulk install games from `./apks/` directory
- **🚀 Auto-Launch**: Automatically start games on container startup
- **🔄 Health Monitoring**: Restart games if they crash or stop responding
- **📸 Progress Tracking**: Take screenshots for progress monitoring
- **📊 Logging**: Comprehensive logging for debugging and monitoring

## 🚀 Deployment Scenarios

### Scenario 1: Local Development
```bash
# Perfect for testing games and automation scripts
cd android-emulator
./deploy.sh dev

# Add your APK files
cp ~/Downloads/*.apk ./apks/
./scripts/manage_games.sh install
```

### Scenario 2: Remote Server Deployment
```bash
# SSH to your server
ssh user@your-server.com
git clone <your-repo-url>
cd android-emulator

# Setup production environment
sudo ./deploy.sh prod

# Enable automation
docker-compose --profile automation,monitoring up -d
```

### Scenario 3: Multi-Platform Development
```bash
# Develop on Mac
./deploy.sh dev
# Test and develop automation scripts

# Deploy to server
scp -r . user@server:/opt/android-emulator/
ssh user@server "cd /opt/android-emulator && sudo ./deploy.sh prod"
```

## 🔗 Related Resources

### Documentation
- [budtmo/docker-android](https://github.com/budtmo/docker-android) - Base Docker image
- [Android Emulator Documentation](https://developer.android.com/studio/run/emulator)
- [Android Debug Bridge (ADB)](https://developer.android.com/studio/command-line/adb)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

### Tools
- [Android SDK Platform Tools](https://developer.android.com/studio/releases/platform-tools)
- [noVNC](https://novnc.com/) - Web-based VNC client
- [Docker Desktop](https://www.docker.com/products/docker-desktop)

### Community
- [r/incremental_games](https://reddit.com/r/incremental_games) - Idle game community
- [Android Emulation Discord](https://discord.gg/android-emulation)

## 📜 License

This project is provided as-is under the MIT License for educational and personal use.

**⚠️ Disclaimer**: This project is intended for legitimate game automation and testing purposes. Please respect game developers' terms of service and avoid any activities that might violate them.
