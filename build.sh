#!/bin/bash
# ==================================================
#  UEM Deployment Tools - Unified Build Script
# ==================================================

echo "Starting full build process..."
echo

# --- Step 1: Build Linux Agents ---
# We use GOOS and GOARCH to cross-compile the agent code for Linux platforms.
# The output files are placed in the project root temporarily so the main app can find them.

echo "Building Linux agent for amd64..."
GOOS=linux GOARCH=amd64 go build -o cncyagent_amd64 ./agent
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build Linux amd64 agent."
    exit 1
fi
echo " -> Successfully created 'cncyagent_amd64'"
echo

echo "Building Linux agent for arm64..."
GOOS=linux GOARCH=arm64 go build -o cncyagent_arm64 ./agent
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build Linux arm64 agent."
    rm -f cncyagent_amd64 # Clean up the previous binary
    exit 1
fi
echo " -> Successfully created 'cncyagent_arm64'"
echo

# --- Step 2: Build Windows Wails Application ---
# Now, we build the main Wails application for Windows.
# It will be able to access the agent binaries we just created in the project root.

echo "Building Windows Wails application (uemtools.exe)..."
wails build -clean -platform windows
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build Windows Wails application."
    # Clean up agent binaries before exiting
    rm -f cncyagent_amd64 cncyagent_arm64
    exit 1
fi
echo " -> Successfully created 'build/bin/uemtools.exe'"
echo

# --- Step 3: Consolidate all binaries into the 'build/bin' directory ---
# Move the generated agent binaries into the final output directory for a clean structure.

echo "Consolidating all binaries into ./build/bin/ ..."
mv cncyagent_amd64 ./build/bin/
mv cncyagent_arm64 ./build/bin/
echo " -> Moved agent binaries."
echo

# --- Final Success Message ---
echo "=================================="
echo "  Full Build Successful!"
echo "=================================="
echo
echo "All artifacts are located in: ./build/bin/"
echo " - uemtools.exe (Windows Client)"
echo " - cncyagent_amd64 (Linux Agent x86_64)"
echo " - cncyagent_arm64 (Linux Agent ARM64)"
echo
