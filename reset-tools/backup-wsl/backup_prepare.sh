#!/bin/bash
set -e

echo "Cleaning caches and unneeded files..."

# Remove cache
rm -rf ~/.cache

# Node caches
rm -rf ~/.npm

# Python caches
rm -rf ~/.local/share/virtualenvs

# Conda / Anaconda caches
rm -rf ~/.conda

# Docker local cache
rm -rf ~/.docker

# Clear apt cache
sudo apt-get clean

echo "Zero-filling free space (this may take some time)..."
sudo dd if=/dev/zero of=/zero.fill bs=1M || true
sudo rm /zero.fill
sync

echo "Preparation complete."
