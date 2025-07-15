@echo off
echo 🚀 Fast Translation Webapp - Cloudflare Deployment
echo ================================================
echo.
echo Choose your deployment method:
echo.
echo 1. Wrangler CLI (Recommended) - Fast, automated deployment
echo 2. Cloudflare Pages - Manual setup via GitHub
echo.
set /p choice="Enter your choice (1 or 2): "

if "%choice%"=="1" (
    echo.
    echo 🔧 Using Wrangler CLI deployment...
    echo 📋 Opening Wrangler deployment guide...
    start WRANGLER_DEPLOYMENT.md
    echo.
    echo 🚀 Running Wrangler deployment script...
    call deploy-wrangler.bat
) else if "%choice%"=="2" (
    echo.
    echo 📋 Using Cloudflare Pages deployment...
    echo 📋 Opening deployment guide...
    start CLOUDFLARE_DEPLOYMENT.txt
    echo.
    echo 🔧 Running GitHub setup...
    powershell -ExecutionPolicy Bypass -File setup-github.ps1
) else (
    echo.
    echo ❌ Invalid choice. Please run the script again and choose 1 or 2.
    pause
    exit /b 1
)

echo.
echo 🎉 Setup complete! Check the deployment guide for next steps.
pause