@echo off
echo 🚀 Fast Translation Webapp - Wrangler Deployment
echo ================================================
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js not found. Please install Node.js from https://nodejs.org/
    echo    Then run this script again.
    pause
    exit /b 1
)

echo ✅ Node.js found

REM Check if wrangler is installed
wrangler --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Wrangler CLI not found. Installing...
    npm install -g wrangler
    echo ✅ Wrangler installed successfully!
) else (
    echo ✅ Wrangler CLI found
)

echo.
echo 🔐 Setting up authentication...
echo Please login to Cloudflare in the browser window that opens.
wrangler auth login

echo.
echo 📝 Setting up environment variables...
echo Please enter your API keys when prompted:

echo.
set /p GEMINI_KEY="🔑 Enter your Gemini API Key: "
echo %GEMINI_KEY% | wrangler secret put GEMINI_API_KEY --env production

echo.
echo ☁️ Setting Google Cloud Credentials...
echo Please paste your Google Cloud service account JSON content:
echo (Press Ctrl+Z then Enter when done)
set GOOGLE_CREDS=
for /f "delims=" %%i in ('more') do set GOOGLE_CREDS=!GOOGLE_CREDS!%%i

REM Convert to base64 (simplified approach)
echo %GOOGLE_CREDS% | wrangler secret put GOOGLE_CLOUD_CREDENTIALS --env production

echo.
echo 🏗️ Setting other environment variables...
echo 534521643480 | wrangler secret put PROJECT_ID --env production
echo us-central1 | wrangler secret put LOCATION --env production
echo projects/534521643480/locations/us-central1/models/NM3ad0dd20ffa743ba | wrangler secret put GOOGLE_CLOUD_MODEL --env production

echo.
echo 🚀 Deploying to Cloudflare...
wrangler deploy --env production

echo.
echo 🎉 Deployment complete!
echo Your webapp should be available at: https://fast-translation-webapp.your-subdomain.workers.dev
echo.
echo 📋 Useful commands:
echo   wrangler tail --env production    # View live logs
echo   wrangler dev                      # Local development  
echo   wrangler deploy --env production  # Redeploy
echo.
pause