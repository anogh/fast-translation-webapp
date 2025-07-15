# Fast Translation Webapp - GitHub Setup Script
# This script helps you push your webapp to GitHub for Cloudflare Pages deployment

Write-Host "🚀 Fast Translation Webapp - GitHub Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Check if git is installed
try {
    git --version | Out-Null
    Write-Host "✅ Git is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Git is not installed. Please install Git first." -ForegroundColor Red
    Write-Host "Download from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Get repository information
Write-Host ""
Write-Host "📝 Repository Setup" -ForegroundColor Yellow
$username = Read-Host "Enter your GitHub username"
$reponame = Read-Host "Enter your repository name (e.g., fast-translation-webapp)"

# Confirm the repository URL
$repoUrl = "https://github.com/$username/$reponame.git"
Write-Host ""
Write-Host "📋 Repository URL: $repoUrl" -ForegroundColor Cyan
$confirm = Read-Host "Is this correct? (y/n)"

if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "❌ Setup cancelled. Please run the script again." -ForegroundColor Red
    exit 1
}

# Initialize git repository
Write-Host ""
Write-Host "🔧 Setting up Git repository..." -ForegroundColor Yellow

try {
    # Check if already a git repository
    if (Test-Path ".git") {
        Write-Host "📁 Git repository already exists" -ForegroundColor Green
    } else {
        git init
        Write-Host "✅ Git repository initialized" -ForegroundColor Green
    }

    # Add all files
    git add .
    Write-Host "✅ Files added to staging" -ForegroundColor Green

    # Commit
    git commit -m "Initial commit: Fast Translation Webapp for Cloudflare Pages"
    Write-Host "✅ Initial commit created" -ForegroundColor Green

    # Set main branch
    git branch -M main
    Write-Host "✅ Main branch set" -ForegroundColor Green

    # Add remote origin
    try {
        git remote add origin $repoUrl
        Write-Host "✅ Remote origin added" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Remote origin might already exist" -ForegroundColor Yellow
        git remote set-url origin $repoUrl
        Write-Host "✅ Remote origin updated" -ForegroundColor Green
    }

    # Push to GitHub
    Write-Host ""
    Write-Host "📤 Pushing to GitHub..." -ForegroundColor Yellow
    git push -u origin main

    Write-Host ""
    Write-Host "🎉 SUCCESS! Your code is now on GitHub!" -ForegroundColor Green
    Write-Host "Repository URL: $repoUrl" -ForegroundColor Cyan

} catch {
    Write-Host "❌ Error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Manual commands to run:" -ForegroundColor Yellow
    Write-Host "git init" -ForegroundColor White
    Write-Host "git add ." -ForegroundColor White
    Write-Host "git commit -m `"Initial commit: Fast Translation Webapp`"" -ForegroundColor White
    Write-Host "git branch -M main" -ForegroundColor White
    Write-Host "git remote add origin $repoUrl" -ForegroundColor White
    Write-Host "git push -u origin main" -ForegroundColor White
    exit 1
}

# Next steps
Write-Host ""
Write-Host "🚀 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "==============" -ForegroundColor Cyan
Write-Host "1. Go to https://dash.cloudflare.com/pages" -ForegroundColor White
Write-Host "2. Click 'Create a project'" -ForegroundColor White
Write-Host "3. Connect to Git and select your repository" -ForegroundColor White
Write-Host "4. Use the environment variables from CLOUDFLARE_DEPLOYMENT.txt" -ForegroundColor White
Write-Host "5. Deploy and enjoy your webapp!" -ForegroundColor White
Write-Host ""
Write-Host "📖 For detailed instructions, see CLOUDFLARE_DEPLOYMENT.txt" -ForegroundColor Yellow

# Open the deployment guide
$openGuide = Read-Host "Open deployment guide? (y/n)"
if ($openGuide -eq "y" -or $openGuide -eq "Y") {
    if (Test-Path "CLOUDFLARE_DEPLOYMENT.txt") {
        Start-Process "CLOUDFLARE_DEPLOYMENT.txt"
    } else {
        Write-Host "⚠️  CLOUDFLARE_DEPLOYMENT.txt not found" -ForegroundColor Yellow
    }
}