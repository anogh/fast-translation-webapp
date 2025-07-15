#!/bin/bash

echo "🚀 Fast Translation Webapp - Wrangler Deployment"
echo "================================================"
echo ""

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "❌ Wrangler CLI not found. Installing..."
    npm install -g wrangler
    echo "✅ Wrangler installed successfully!"
else
    echo "✅ Wrangler CLI found"
fi

echo ""
echo "🔐 Setting up authentication..."
wrangler auth login

echo ""
echo "📝 Setting up environment variables..."
echo "Please enter your API keys when prompted:"

echo ""
echo "🔑 Setting Gemini API Key..."
read -p "Enter your Gemini API Key: " GEMINI_KEY
wrangler secret put GEMINI_API_KEY --env production <<< "$GEMINI_KEY"

echo ""
echo "☁️ Setting Google Cloud Credentials..."
echo "Please paste your Google Cloud service account JSON (press Ctrl+D when done):"
GOOGLE_CREDS=$(cat)
echo "$GOOGLE_CREDS" | base64 -w 0 | wrangler secret put GOOGLE_CLOUD_CREDENTIALS --env production

echo ""
echo "🏗️ Setting other environment variables..."
wrangler secret put PROJECT_ID --env production <<< "534521643480"
wrangler secret put LOCATION --env production <<< "us-central1"
wrangler secret put GOOGLE_CLOUD_MODEL --env production <<< "projects/534521643480/locations/us-central1/models/NM3ad0dd20ffa743ba"

echo ""
echo "🚀 Deploying to Cloudflare..."
wrangler deploy --env production

echo ""
echo "🎉 Deployment complete!"
echo "Your webapp should be available at: https://fast-translation-webapp.your-subdomain.workers.dev"
echo ""
echo "📋 Useful commands:"
echo "  wrangler tail --env production    # View live logs"
echo "  wrangler dev                      # Local development"
echo "  wrangler deploy --env production  # Redeploy"