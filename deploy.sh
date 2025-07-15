#!/bin/bash

# Cloudflare Pages Deployment Script
# This script helps you deploy the Fast Translation Webapp to Cloudflare Pages

echo "🚀 Fast Translation Webapp - Cloudflare Pages Deployment Helper"
echo "=============================================================="

# Check if required tools are installed
command -v git >/dev/null 2>&1 || { echo "❌ Git is required but not installed. Aborting." >&2; exit 1; }

echo "📋 Pre-deployment Checklist:"
echo "1. ✅ Ensure you have a Cloudflare account"
echo "2. ✅ Have your Gemini API key ready"
echo "3. ✅ Have your Google Cloud credentials JSON file"
echo "4. ✅ Know your Google Cloud Project ID"

read -p "📝 Do you have all the above ready? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Please prepare the requirements first, then run this script again."
    exit 1
fi

echo ""
echo "🔧 Setting up for deployment..."

# Create .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
    cat > .gitignore << EOL
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv/
pip-log.txt
pip-delete-this-directory.txt
.tox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.log
.git
.mypy_cache
.pytest_cache
.hypothesis
.env
.env.local
.env.*.local
*.log
EOL
    echo "✅ Created .gitignore file"
fi

# Get Google Cloud credentials
echo ""
echo "🔑 Google Cloud Credentials Setup:"
echo "Please provide the path to your Google Cloud service account JSON file:"
read -p "📁 Path to credentials.json: " CREDS_PATH

if [ ! -f "$CREDS_PATH" ]; then
    echo "❌ File not found: $CREDS_PATH"
    exit 1
fi

# Encode credentials to base64
ENCODED_CREDS=$(base64 -i "$CREDS_PATH" | tr -d '\n')
echo "✅ Credentials encoded successfully"

# Get other required information
echo ""
echo "🔧 Configuration Setup:"
read -p "🔑 Enter your Gemini API key: " GEMINI_KEY
read -p "🏗️  Enter your Google Cloud Project ID: " PROJECT_ID

# Create environment variables summary
echo ""
echo "📋 Environment Variables for Cloudflare Pages:"
echo "=============================================="
echo "GEMINI_API_KEY=$GEMINI_KEY"
echo "GOOGLE_CLOUD_CREDENTIALS=$ENCODED_CREDS"
echo "PROJECT_ID=$PROJECT_ID"
echo "LOCATION=us-central1"
echo "GOOGLE_CLOUD_MODEL=projects/$PROJECT_ID/locations/us-central1/models/YOUR_MODEL_ID"
echo ""
echo "⚠️  IMPORTANT: Replace 'YOUR_MODEL_ID' with your actual Google Cloud Translation model ID"
echo ""

# Save to file for reference
cat > deployment-config.txt << EOL
Cloudflare Pages Environment Variables:
=====================================

GEMINI_API_KEY=$GEMINI_KEY
GOOGLE_CLOUD_CREDENTIALS=$ENCODED_CREDS
PROJECT_ID=$PROJECT_ID
LOCATION=us-central1
GOOGLE_CLOUD_MODEL=projects/$PROJECT_ID/locations/us-central1/models/YOUR_MODEL_ID

Deployment Instructions:
=======================
1. Push this code to a GitHub repository
2. Go to Cloudflare Dashboard → Pages
3. Create a new project and connect your GitHub repo
4. Set build command: pip install -r requirements.txt
5. Set build output directory: /
6. Add the above environment variables in Pages settings
7. Deploy!

EOL

echo "✅ Configuration saved to deployment-config.txt"

# Initialize git if not already done
if [ ! -d .git ]; then
    echo ""
    echo "🔄 Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial commit: Fast Translation Webapp"
    echo "✅ Git repository initialized"
    
    echo ""
    echo "📤 Next steps:"
    echo "1. Create a new repository on GitHub"
    echo "2. Add the remote: git remote add origin <your-repo-url>"
    echo "3. Push the code: git push -u origin main"
else
    echo ""
    echo "📤 Committing changes..."
    git add .
    git commit -m "Update: Fast Translation Webapp for Cloudflare Pages"
    echo "✅ Changes committed"
    
    echo ""
    echo "📤 Push to GitHub: git push origin main"
fi

echo ""
echo "🎉 Setup Complete!"
echo "==================="
echo "1. ✅ Code is ready for deployment"
echo "2. ✅ Environment variables are prepared"
echo "3. ✅ Configuration saved to deployment-config.txt"
echo ""
echo "🚀 Next: Deploy to Cloudflare Pages"
echo "1. Go to https://dash.cloudflare.com/pages"
echo "2. Create a new project"
echo "3. Connect your GitHub repository"
echo "4. Use the environment variables from deployment-config.txt"
echo "5. Deploy and enjoy your webapp!"
echo ""
echo "📖 For detailed instructions, see README.md"