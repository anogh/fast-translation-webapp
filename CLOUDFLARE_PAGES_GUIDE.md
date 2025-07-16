# 🚀 Cloudflare Pages Deployment Guide

## 📋 **Step-by-Step Deployment**

### **Step 1: Create GitHub Repository**

1. Go to **https://github.com/new**
2. **Repository name**: `fast-translation-webapp`
3. **Description**: `AI-powered English to Bengali translation webapp`
4. **Visibility**: Public (or Private if you prefer)
5. **Click "Create repository"**

### **Step 2: Push Code to GitHub**

Your Git repository is already initialized. Now add the remote and push:

```bash
# Add your GitHub repository as remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/fast-translation-webapp.git

# Push to GitHub
git push -u origin main
```

### **Step 3: Connect to Cloudflare Pages**

1. **Go to Cloudflare Pages**: https://dash.cloudflare.com/pages
2. **Click "Create a project"**
3. **Connect to Git** → **GitHub**
4. **Select your repository**: `fast-translation-webapp`
5. **Click "Begin setup"**

### **Step 4: Configure Build Settings**

Use these exact settings:

```
Project name: fast-translation-webapp
Production branch: main
Framework preset: None
Build command: pip install -r requirements.txt
Build output directory: (leave empty)
Root directory: (leave empty)
```

### **Step 5: Environment Variables Setup**

**CRITICAL**: Set these in Cloudflare Pages dashboard, NOT in files!

1. Go to your Cloudflare Pages project
2. Navigate to **Settings** → **Environment variables**
3. Add these variables for both **Production** and **Preview**:

```
GEMINI_API_KEY = your_gemini_api_key_here
PROJECT_ID = gen-lang-client-0695443309
LOCATION = us-central1
GOOGLE_CLOUD_MODEL = gemini-1.5-flash-002
GOOGLE_CLOUD_CREDENTIALS = {paste your service account JSON here}
```

**⚠️ For GOOGLE_CLOUD_CREDENTIALS**: Copy the entire JSON content from your `gen-lang-client-0695443309-85a37f2c9fd6.json` file and paste it as the value (not base64 encoded).

### **Step 6: Deploy**

1. **Click "Save and Deploy"**
2. **Wait for build to complete** (usually 2-5 minutes)
3. **Your app will be available** at: `https://fast-translation-webapp.pages.dev`

## 🔑 **Getting Your API Keys**

### **Gemini API Key**
1. Go to: https://aistudio.google.com/app/apikey
2. Click "Create API Key"
3. Copy the key

### **Google Cloud Credentials**
Your credentials are already in the project. To get the base64 encoded version:

```bash
# In your webapp directory, run:
certutil -encode gen-lang-client-0695443309-85a37f2c9fd6.json temp.txt
# Then copy the content between the BEGIN/END lines (without the header/footer)
```

## 🎯 **Next Steps After Deployment**

1. **Test your deployment** at the provided URL
2. **Set up custom domain** (optional) in Cloudflare Pages settings
3. **Monitor logs** in the Cloudflare dashboard
4. **Update code** by pushing to GitHub (auto-deploys)

## 🔧 **Troubleshooting**

### **Build Fails**
- Check environment variables are set correctly
- Verify your Google Cloud credentials are valid
- Check the build logs in Cloudflare Pages dashboard

### **Runtime Errors**
- Check the Functions logs in Cloudflare Pages
- Verify API keys are working
- Test locally first with `python main.py`

### **Need Help?**
- Check Cloudflare Pages documentation
- Review the build logs for specific errors
- Test the app locally to isolate issues

---

**🎉 Ready to deploy? Follow the steps above and your webapp will be live on Cloudflare's global network!**