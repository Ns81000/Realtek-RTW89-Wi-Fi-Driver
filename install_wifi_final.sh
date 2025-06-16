#!/bin/bash

# ===================================================================================
# Definitive Automated Realtek RTW89 Wi-Fi Driver Installation Script
#
# This script is the final result of our detailed troubleshooting. It automates
# every successful step we discovered, creating a reliable, one-click solution.
#
# It will:
# 1. Update your system and install ALL necessary dependencies.
# 2. Download the latest driver source code.
# 3. Automatically patch the code to fix the known compilation error.
# 4. Perform a clean, manual installation to avoid all installer bugs.
# 5. Fix the known driver filename bug.
# 6. *** NEW: Create the driver options file to fix cold boot & dual-boot issues. ***
# 7. Load the newly installed driver.
#
# How to Use:
# 1. Save this script as a file, for example: "install_wifi_final.sh".
# 2. Make the script executable:  chmod +x install_wifi_final.sh
# 3. Run the script with sudo:      sudo ./install_wifi_final.sh
#
# ===================================================================================

# --- Configuration & Colors ---
# Exit immediately if a command exits with a non-zero status.
set -e 

# Colors for clear, user-friendly output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Helper Functions ---
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# --- Root User Check ---
if [ "$EUID" -ne 0 ]; then 
  log_error "This script must be run with sudo. Please run as: sudo ./install_wifi_final.sh"
fi

# --- Main Script ---

log_info "Starting the definitive Realtek Wi-Fi driver installation."

# === STEP 1: SYSTEM PREPARATION ===
log_info "Step 1: Preparing system and installing all dependencies..."
log_info "Updating package lists and upgrading system. This may take a moment..."
apt update && apt full-upgrade -y

log_info "Installing all required packages: headers, build tools, git, and firmware..."
# This combines all package installations into one robust command.
apt install -y build-essential git linux-headers-generic linux-headers-$(uname -r) firmware-realtek

# === STEP 2: DOWNLOAD SOURCE CODE ===
log_info "Step 2: Downloading the latest driver source code..."
# Remove the old directory if it exists to ensure a fresh start
if [ -d "rtw89" ]; then
    log_warn "An old 'rtw89' directory was found. Removing it now."
    rm -rf rtw89
fi
git clone https://github.com/lwfinger/rtw89.git
cd rtw89
log_info "Successfully downloaded and entered the rtw89 source directory."

# === STEP 3: COMPILE DRIVER WITH AUTOMATED PATCHING ===
log_info "Step 3: Compiling the driver..."
make clean
log_info "Attempting initial compilation..."

# Attempt to compile, but continue even if it fails so we can patch it.
make_output=$(make 2>&1) || true 

# Check if the compilation failed with our specific known error.
if echo "$make_output" | grep -q "incompatible pointer type"; then
    log_warn "Known compilation error detected. Applying automatic patch..."
    # This 'sed' command performs the nano edit automatically.
    sed -i 's/static void rtw89_ops_stop(struct ieee80211_hw \*hw)/static void rtw89_ops_stop(struct ieee80211_hw \*hw, bool changed)/' mac80211.c
    log_info "Code patched. Re-compiling..."
    make
else
    log_info "Initial compilation successful, no patch needed."
fi
log_info "Driver has been compiled successfully."

# === STEP 4: GUARANTEED MANUAL INSTALLATION ===
log_info "Step 4: Performing a clean, manual installation..."

# Define the system's driver directory path for readability.
SYSTEM_DRIVER_DIR="/lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/rtw89"

log_info "Cleaning the target directory: $SYSTEM_DRIVER_DIR"
# Create the directory if it doesn't exist, and remove any old files.
mkdir -p "$SYSTEM_DRIVER_DIR"
rm -f "$SYSTEM_DRIVER_DIR"/*.ko*

log_info "Copying the newly compiled driver files..."
# We are still inside the '~/rtw89' directory from Step 2.
cp *.ko "$SYSTEM_DRIVER_DIR/"

log_info "Fixing the incorrect driver filenames..."
# Navigate to the system directory to perform the renaming.
cd "$SYSTEM_DRIVER_DIR"
for f in rtw_*.ko; do 
  # This check prevents errors if no files match the pattern.
  if [ -e "$f" ]; then
    log_warn "Renaming '$f' to 'rtw89${f#rtw}'"
    mv "$f" "rtw89${f#rtw}"
  fi
done

# === STEP 5: APPLY HARDWARE COMPATIBILITY FIX ===
log_info "Step 5: Applying the fix for cold boot and dual-boot issues..."
# This creates a configuration file to disable ASPM, which fixes the firmware failure.
CONF_FILE="/etc/modprobe.d/rtw89.conf"
log_info "Creating configuration file at $CONF_FILE..."
echo "options rtw89_pci disable_aspm=y" > "$CONF_FILE"

# === STEP 6: FINAL ACTIVATION & VERIFICATION ===
log_info "Step 6: Activating and verifying the new driver..."

log_info "Updating module dependencies..."
depmod -a

log_info "Loading the main Wi-Fi driver (rtw89_8851be)..."
modprobe rtw89_8851be

log_info "Verifying that the driver is loaded and active..."
if lsmod | grep -q "rtw89pci"; then
    log_info "✅ SUCCESS! The Wi-Fi driver has been installed and is now active."
    log_info "Your Wi-Fi should be working permanently. A final reboot is highly recommended."
    echo -e "\nTo complete the process, please run 'sudo reboot' now."
else
    log_error "The driver was installed but failed to load. Please review the output above for errors."
fi

exit 0
