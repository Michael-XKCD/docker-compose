# Troubleshooting Guide

## Common Issues and Solutions

### 1. Emulator Won't Start on M4 Mac

**Problem**: Container starts but emulator fails to initialize, web interface not accessible.

**Root Cause**: Android emulators require significant resources and hardware acceleration. Running AMD64 containers on ARM64 Mac through emulation can be challenging.

**Solutions**:

#### Option A: Reduce Resource Requirements
```bash
# Stop current container
./deploy.sh stop

# Edit docker-compose.dev.yml and reduce resources:
# Change: -memory 4096 -cores 4
# To: -memory 2048 -cores 2

# Restart
./deploy.sh dev
```

#### Option B: Try Alternative Image (Recommended for Testing)
```bash
# Stop current setup
./deploy.sh stop

# Use a lighter Android image for testing
docker run -d \
  --name android-test \
  --privileged \
  -p 5554:5554 -p 5555:5555 -p 6080:6080 \
  budtmo/docker-android:genymotion_10.0
```

#### Option C: Local Testing Alternative
If the Docker approach is problematic on M4 Mac, consider:
1. **Android Studio Emulator**: Use Android Studio's built-in emulator for development
2. **Physical Device**: Connect a real Android device via USB debugging
3. **Cloud Emulator**: Use services like AWS Device Farm or Firebase Test Lab

### 2. Development on Mac, Production on Server

**Recommended Workflow**:
```bash
# 1. Develop automation scripts locally (without full emulator)
# Edit automation/game_manager.py and test logic

# 2. Test on your Linux server where hardware acceleration works
ssh user@your-server.com
git clone <your-repo>
cd android-emulator
sudo ./deploy.sh prod

# 3. Iterate: develop on Mac, test on server
```

### 3. Container Logs Show "device exited with status 1"

**Common Causes**:
- Insufficient memory/CPU allocation
- Hardware acceleration not available
- Platform architecture mismatch

**Debug Steps**:
```bash
# Check detailed logs
docker-compose -f docker-compose.dev.yml logs -f android-emulator

# Enter container to debug
docker-compose -f docker-compose.dev.yml exec android-emulator /bin/bash

# Check emulator process inside container
ps aux | grep emulator
```

### 4. Web Interface (noVNC) Not Working

**Check Steps**:
```bash
# 1. Verify container is running
docker ps | grep android-emulator

# 2. Check if port is accessible
curl http://localhost:6080

# 3. Try accessing container IP directly
docker inspect android-emulator-dev | grep IPAddress
# Then try: http://[container_ip]:6080
```

### 5. ADB Connection Issues

**Solutions**:
```bash
# Install Android SDK platform-tools for ADB
brew install android-platform-tools  # macOS

# Connect to emulator
adb connect localhost:5555

# If connection fails, wait for emulator to fully boot
# Check container logs for "Boot completed" message
```

### 6. Best Practices for M4 Mac Development

1. **Use Server for Real Testing**: Develop scripts on Mac, test on Linux server
2. **Reduce Resources**: Start with minimal resources and scale up
3. **Monitor Performance**: Watch Docker Desktop resource usage
4. **Consider Alternatives**: Android Studio emulator might be more reliable for local dev

### 7. Production Deployment (Linux Server)

**Pre-flight Checklist**:
```bash
# 1. Enable KVM
sudo modprobe kvm
sudo chmod 666 /dev/kvm
sudo usermod -a -G kvm $USER

# 2. Check available resources
free -h  # Memory
nproc    # CPU cores
df -h    # Disk space

# 3. Deploy with production config
sudo ./deploy.sh prod
```

### 8. Memory and CPU Recommendations

| Environment | RAM | CPU | Expected Performance |
|-------------|-----|-----|---------------------|
| Mac Development | 2-4GB | 2-4 cores | Basic functionality |
| Linux Testing | 4-8GB | 4-8 cores | Good performance |
| Production Server | 8-16GB | 8-16 cores | Optimal for 24/7 |

### 9. Alternative Approach: Server-First Development

If Mac development is too resource-intensive:

```bash
# 1. Set up your Linux server as the primary development environment
ssh user@server
cd /opt/android-emulator

# 2. Use VS Code Remote Development
# Install "Remote - SSH" extension
# Connect to your server and develop directly there

# 3. Use port forwarding for web interface
ssh -L 6080:localhost:6080 user@server
# Then access http://localhost:6080 on your Mac
```

## Getting Help

If you continue to have issues:

1. **Check Docker Desktop Resources**: Ensure adequate CPU and memory allocation
2. **Monitor System Resources**: Use Activity Monitor to check system load
3. **Try on Linux**: The project is optimized for Linux servers with KVM
4. **Consider Cloud Development**: Use a cloud instance for development if local resources are limited

Remember: Android emulation is resource-intensive. It's normal for it to require significant CPU and memory, especially when running through architecture emulation (AMD64 on ARM64).