#!/bin/bash
# Build script for Cloudflare Pages

echo "Starting build process..."

# Install minimal dependencies first
pip install -r requirements-minimal.txt

echo "Build completed successfully!"