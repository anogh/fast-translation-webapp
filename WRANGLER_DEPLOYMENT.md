# Fast Translation Webapp - Wrangler Deployment Guide

## 🚀 **Deploy with Wrangler (Recommended)**

Wrangler is the official Cloudflare CLI tool that provides the best deployment experience for Cloudflare Workers and Pages.

### 📋 **Prerequisites**

1. **Node.js** (v16 or later) - Download from https://nodejs.org/
2. **Cloudflare Account** - Sign up at https://cloudflare.com/
3. **Gemini API Key** - Get from https://aistudio.google.com/app/apikey
4. **Google Cloud Service Account** - JSON credentials file

### 🛠️ **Quick Deployment**

#### **Option 1: Automated Script (Windows)**
```bash
# Double-click this file:
deploy-wrangler.bat
```

#### **Option 2: Manual Commands**

1. **Install Wrangler**:
   ```bash
   npm install -g wrangler
   ```

2. **Login to Cloudflare**:
   ```bash
   wrangler auth login
   ```

3. **Set Environment Variables**:
   ```bash
   # Gemini API Key
   wrangler secret put GEMINI_API_KEY --env production
   
   # Google Cloud Credentials (paste JSON content)
   wrangler secret put GOOGLE_CLOUD_CREDENTIALS --env production
   
   # Other variables
   echo "534521643480" | wrangler secret put PROJECT_ID --env production
   echo "us-central1" | wrangler secret put LOCATION --env production
   echo "projects/534521643480/locations/us-central1/models/NM3ad0dd20ffa743ba" | wrangler secret put GOOGLE_CLOUD_MODEL --env production
   ```

4. **Deploy**:
   ```bash
   wrangler deploy --env production
   ```

### 🔧 **Configuration Files**

- **`wrangler.toml`** - Cloudflare Workers configuration
- **`deploy-wrangler.bat`** - Windows deployment script
- **`deploy-wrangler.sh`** - Linux/Mac deployment script

### 🌐 **Your App URL**

After deployment, your app will be available at:
```
https://fast-translation-webapp.your-subdomain.workers.dev
```

### 📊 **Useful Wrangler Commands**

```bash
# View live logs
wrangler tail --env production

# Local development
wrangler dev

# Redeploy
wrangler deploy --env production

# View deployment info
wrangler deployments list --env production

# Update secrets
wrangler secret put SECRET_NAME --env production

# List secrets
wrangler secret list --env production
```

### 🔒 **Environment Variables**

| Variable | Description | Example |
|----------|-------------|---------|
| `GEMINI_API_KEY` | Your Gemini API key | `AIza...` |
| `GOOGLE_CLOUD_CREDENTIALS` | Base64 encoded service account JSON | `eyJ0eXBlIjoi...` |
| `PROJECT_ID` | Google Cloud Project ID | `534521643480` |
| `LOCATION` | Google Cloud region | `us-central1` |
| `GOOGLE_CLOUD_MODEL` | Full model path | `projects/.../models/...` |

### 🐛 **Troubleshooting**

#### **Common Issues:**

1. **"wrangler: command not found"**
   ```bash
   npm install -g wrangler
   ```

2. **Authentication errors**
   ```bash
   wrangler auth login
   ```

3. **Environment variable issues**
   ```bash
   wrangler secret list --env production
   ```

4. **Deployment failures**
   ```bash
   wrangler tail --env production
   ```

### 🎯 **Advantages of Wrangler**

- ✅ **Faster deployments** - Direct CLI deployment
- ✅ **Better secret management** - Encrypted environment variables
- ✅ **Live logs** - Real-time debugging with `wrangler tail`
- ✅ **Local development** - Test locally with `wrangler dev`
- ✅ **Automatic scaling** - Cloudflare Workers edge computing
- ✅ **Global distribution** - 200+ data centers worldwide

### 🔄 **Development Workflow**

1. **Local development**:
   ```bash
   wrangler dev
   ```

2. **Test changes**:
   ```bash
   # Your app runs at http://localhost:8787
   ```

3. **Deploy to production**:
   ```bash
   wrangler deploy --env production
   ```

### 📈 **Monitoring**

- **Live logs**: `wrangler tail --env production`
- **Cloudflare Dashboard**: https://dash.cloudflare.com/
- **Analytics**: Built-in Cloudflare Workers analytics

---

**🎉 Ready to deploy? Run `deploy-wrangler.bat` and follow the prompts!**