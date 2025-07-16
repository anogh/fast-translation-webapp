# PowerShell script to help set up GitHub repository for Cloudflare Pages deployment
# Run this script to get step-by-step instructions

Write-Host "=== Fast Translation Webapp - GitHub Setup ===" -ForegroundColor Green
Write-Host ""

Write-Host "Your local Git repository is ready! Now you need to:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Create a GitHub repository:" -ForegroundColor Cyan
Write-Host "   - Go to https://github.com/new"
Write-Host "   - Repository name: fast-translation-webapp"
Write-Host "   - Description: AI-powered translation webapp with FastAPI"
Write-Host "   - Make it Public (required for free Cloudflare Pages)"
Write-Host "   - DO NOT initialize with README (we already have files)"
Write-Host ""

Write-Host "2. After creating the repository, GitHub will show you commands like:" -ForegroundColor Cyan
Write-Host "   git remote add origin https://github.com/YOUR_USERNAME/fast-translation-webapp.git"
Write-Host "   git branch -M main"
Write-Host "   git push -u origin main"
Write-Host ""

Write-Host "3. Copy and run those commands in this directory" -ForegroundColor Cyan
Write-Host ""

Write-Host "4. Once pushed to GitHub, go to Cloudflare Pages:" -ForegroundColor Cyan
Write-Host "   - Visit https://dash.cloudflare.com/"
Write-Host "   - Go to Pages section"
Write-Host "   - Click 'Connect to Git'"
Write-Host "   - Select your GitHub repository"
Write-Host ""

Write-Host "5. Configure build settings:" -ForegroundColor Cyan
Write-Host "   - Framework preset: None"
Write-Host "   - Build command: pip install -r requirements.txt"
Write-Host "   - Build output directory: /"
Write-Host "   - Root directory: /"
Write-Host ""

Write-Host "6. Add environment variables (from DEPLOYMENT_CONFIG.md):" -ForegroundColor Cyan
Write-Host "   - GEMINI_API_KEY"
Write-Host "   - GOOGLE_CLOUD_CREDENTIALS (base64 encoded)"
Write-Host "   - PROJECT_ID"
Write-Host "   - LOCATION"
Write-Host "   - GOOGLE_CLOUD_MODEL"
Write-Host ""

Write-Host "Current directory: $PWD" -ForegroundColor Green
Write-Host ""
Write-Host "Ready to proceed? Press any key to open GitHub in your browser..." -ForegroundColor Yellow
Read-Host

# Open GitHub new repository page
Start-Process "https://github.com/new"

Write-Host "GitHub opened in your browser. Follow the steps above!" -ForegroundColor Green