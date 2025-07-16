@echo off
echo.
echo === Fast Translation Webapp - GitHub Setup ===
echo.
echo Your local Git repository is ready!
echo.
echo Next steps:
echo 1. Go to https://github.com/new
echo 2. Create repository: fast-translation-webapp
echo 3. Make it PUBLIC (required for free Cloudflare Pages)
echo 4. DO NOT initialize with README
echo 5. Copy the git commands GitHub shows you
echo 6. Run them in this directory
echo.
echo Opening GitHub in your browser...
start https://github.com/new
echo.
echo After pushing to GitHub:
echo - Go to https://dash.cloudflare.com/
echo - Navigate to Pages
echo - Connect to Git and select your repository
echo - Use build settings from CLOUDFLARE_PAGES_GUIDE.md
echo - Add environment variables from DEPLOYMENT_CONFIG.md
echo.
pause