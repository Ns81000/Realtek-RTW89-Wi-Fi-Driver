# Realtek RTW89 Wi-Fi Driver Installer for Kali Linux

![Kali Linux](https://img.shields.io/badge/Kali%20Linux-557C94?style=for-the-badge&logo=kalilinux&logoColor=white)
![Bash](https://img.shields.io/badge/bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/status-stable-brightgreen?style=for-the-badge)

## 🚀 Overview

This is a **definitive, automated installation script** for Realtek RTW89 series Wi-Fi drivers, specifically optimized and tested for **Kali Linux**. The script was developed after extensive troubleshooting and combines all successful installation steps into a single, reliable solution.

### 🎯 What This Script Does

The script automates the complete installation process:

1. **System Preparation**: Updates Kali Linux and installs all required dependencies
2. **Source Download**: Clones the latest RTW89 driver source code
3. **Intelligent Compilation**: Automatically detects and patches known compilation errors
4. **Clean Installation**: Performs manual driver installation to avoid installer bugs
5. **Bug Fixes**: Corrects known driver filename issues
6. **Driver Activation**: Loads and verifies the newly installed driver

### 📋 Supported Hardware

This script supports Realtek RTW89 series Wi-Fi adapters, including:
- **RTL8851BE** (Primary target)
- **RTL8852AE**
- **RTL8852BE**
- **RTL8852CE**
- Other RTW89 series adapters

## 🔧 Requirements

### System Requirements
- **Kali Linux** (2023.x or newer recommended)
- **Root/sudo access** (required for driver installation)
- **Active internet connection** (for downloading dependencies and source code)
- **Minimum 1GB free disk space**

### Pre-Installation Check
Before running the script, verify your Wi-Fi adapter:
```bash
lspci | grep -i wireless
# or
lsusb | grep -i realtek
```

## 📥 Download & Installation

### Method 1: Direct Download
```bash
# Navigate to your desired directory
cd ~/Downloads

# Download the script
wget https://raw.githubusercontent.com/your-repo/install_wifi_final.sh

# Make it executable
chmod +x install_wifi_final.sh
```

### Method 2: Clone Repository
```bash
# Clone the entire repository
git clone https://github.com/your-repo/rtw89-kali-installer.git
cd rtw89-kali-installer

# Make the script executable
chmod +x install_wifi_final.sh
```

### Method 3: Manual Creation
1. Copy the script content from `install_wifi_final.sh`
2. Create a new file: `nano install_wifi_final.sh`
3. Paste the content and save
4. Make executable: `chmod +x install_wifi_final.sh`

## 🚀 Usage

### Quick Start
```bash
# Run with sudo privileges
sudo ./install_wifi_final.sh
```

### Step-by-Step Execution
1. **Open Terminal** in Kali Linux
2. **Navigate** to the script directory:
   ```bash
   cd /path/to/script/directory
   ```
3. **Execute** the script:
   ```bash
   sudo ./install_wifi_final.sh
   ```
4. **Follow** the on-screen prompts
5. **Reboot** when installation completes:
   ```bash
   sudo reboot
   ```

## 📊 Installation Process Details

### Phase 1: System Preparation (2-5 minutes)
- Updates package repositories
- Upgrades existing packages
- Installs build-essential, git, kernel headers
- Installs firmware-realtek package

### Phase 2: Source Code Management (1-2 minutes)
- Removes any existing RTW89 directories
- Clones fresh source code from lwfinger/rtw89
- Prepares compilation environment

### Phase 3: Intelligent Compilation (2-3 minutes)
- Attempts initial compilation
- **Auto-detects** common compilation errors
- **Automatically patches** known issues in `mac80211.c`
- Recompiles with fixes applied

### Phase 4: Manual Installation (1 minute)
- Creates proper system directories
- Copies compiled drivers to system location
- **Fixes filename bugs** (renames rtw_*.ko to rtw89*.ko)
- Updates module dependencies

### Phase 5: Activation & Verification (30 seconds)
- Loads the rtw89_8851be driver
- Verifies driver is active
- Provides success confirmation

## 🔍 Technical Details

### Key Features
- **Error-Resilient**: Continues execution even if intermediate steps fail
- **Intelligent Patching**: Automatically fixes known compilation issues
- **Clean Installation**: Bypasses problematic automated installers
- **Comprehensive Logging**: Color-coded output for easy troubleshooting
- **Safety Checks**: Validates root privileges and system compatibility

### Files Modified/Created
```
/lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/rtw89/
├── rtw89core.ko
├── rtw89pci.ko
├── rtw898851be.ko
└── [other driver files]
```

### Automatic Patches Applied
The script automatically fixes this common compilation error:
```c
// Original (causes error):
static void rtw89_ops_stop(struct ieee80211_hw *hw)

// Patched (works correctly):
static void rtw89_ops_stop(struct ieee80211_hw *hw, bool changed)
```

## 🛠️ Troubleshooting

### Common Issues & Solutions

#### ❌ "Permission Denied" Error
**Solution**: Ensure you're running with sudo:
```bash
sudo ./install_wifi_final.sh
```

#### ❌ "Command Not Found" Errors
**Solution**: Update package lists and install missing dependencies:
```bash
sudo apt update
sudo apt install build-essential git
```

#### ❌ "No Space Left on Device"
**Solution**: Free up disk space:
```bash
sudo apt autoremove
sudo apt autoclean
```

#### ❌ Compilation Fails
**Solution**: Install kernel headers for your specific kernel:
```bash
sudo apt install linux-headers-$(uname -r)
```

#### ❌ Driver Loads But Wi-Fi Still Not Working
**Solution**: 
1. Reboot your system: `sudo reboot`
2. Check if firmware is properly installed: `sudo apt install firmware-realtek`
3. Verify driver is loaded: `lsmod | grep rtw89`

### Verification Commands
```bash
# Check if driver is loaded
lsmod | grep rtw89

# Check Wi-Fi interfaces
ip link show

# Check NetworkManager status
systemctl status NetworkManager

# View kernel messages
dmesg | grep rtw89
```

## 📋 Post-Installation

### Immediate Steps
1. **Reboot** your system (highly recommended)
2. **Enable Wi-Fi** in network settings
3. **Connect** to your wireless network

### Verification
After reboot, verify installation:
```bash
# Check loaded modules
lsmod | grep rtw89

# Check available interfaces
iwconfig

# Test connectivity
ping -c 4 google.com
```

## 🔄 Uninstallation

To remove the installed driver:
```bash
# Remove driver files
sudo rm -rf /lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/rtw89/

# Update module dependencies
sudo depmod -a

# Reboot
sudo reboot
```

## 🤝 Contributing

### Reporting Issues
If you encounter problems:
1. Run the script with verbose output
2. Collect system information: `uname -a` and `lspci`
3. Include full error messages
4. Specify your Kali Linux version

## 📞 Support

### Resources
- **Kali Linux Documentation**: [kali.org/docs](https://www.kali.org/docs/)
- **RTW89 Driver Source**: [lwfinger/rtw89](https://github.com/lwfinger/rtw89)
- **Kernel Headers**: [packages.debian.org](https://packages.debian.org/)

### Before Seeking Help
1. Read this entire README
2. Try the troubleshooting steps
3. Check if your hardware is supported
4. Verify you're using a supported Kali version

## ⚖️ License

This script is provided as-is for educational and practical purposes. The underlying RTW89 driver source code follows its original license terms.

## ⚠️ Disclaimer

- **Backup your system** before running the script
- This script modifies system kernel modules
- **Test in a virtual machine** first if possible
- Use at your own risk on production systems

---

**Made with ❤️ for the Kali Linux community**
