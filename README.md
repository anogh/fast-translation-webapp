# Fast Translation Webapp

A modern web application for English to Bengali translation with AI-powered features and custom dictionaries.

## Features

- **AI-Powered Translation**: Uses Google Gemini AI for intelligent translation
- **Custom Dictionaries**: Multiple dictionary types for precise translations
  - Word Replacement Dictionary
  - Keyword-Based Dictionary
  - Single Word Dictionary
  - Gemini Keyword Prompts
- **Fire Mode**: Real-time translation as you type
- **AI Mode**: Enhanced translation using AI prompts
- **Modern UI**: Beautiful, responsive design with animations
- **Cloud Ready**: Optimized for Cloudflare Pages deployment

## Local Development

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Set environment variables:
```bash
export GEMINI_API_KEY="your_gemini_api_key"
export GOOGLE_CLOUD_CREDENTIALS="base64_encoded_credentials_json"
export PROJECT_ID="your_google_cloud_project_id"
```

3. Run the application:
```bash
python main.py
```

4. Open http://localhost:8000 in your browser

## 🚀 Cloudflare Deployment

### **Option 1: Wrangler CLI (Recommended)**

The fastest and most reliable way to deploy:

```bash
# Run the deployment script
deploy-to-cloudflare.bat

# Choose option 1 for Wrangler deployment
```

**Advantages:**
- ✅ Faster deployments
- ✅ Better secret management  
- ✅ Live logs and debugging
- ✅ Local development with `wrangler dev`

### **Option 2: Cloudflare Pages**

Traditional GitHub-based deployment:

```bash
# Run the deployment script  
deploy-to-cloudflare.bat

# Choose option 2 for Pages deployment
```

### **Quick Start**

1. **Get your Gemini API Key**: https://aistudio.google.com/app/apikey
2. **Deploy via Terminal**:
   - **Windows**: Open PowerShell or Command Prompt in the `webapp` directory and run:
     ```bash
     .\deploy-wrangler.bat
     ```
   - **Linux/macOS**: Open Terminal in the `webapp` directory and run:
     ```bash
     bash deploy-wrangler.sh
     ```
3. **Follow the prompts** to set up your API keys.
4. **Deploy and enjoy!**

For detailed instructions, see:
- **Wrangler**: `WRANGLER_DEPLOYMENT.md`
- **Pages**: `CLOUDFLARE_DEPLOYMENT.txt`

### Prerequisites
- Cloudflare account
- Google Cloud Project with Translation API enabled
- Gemini API key

### Deployment Steps

1. **Prepare your repository**:
   - Push this webapp folder to a GitHub repository
   - Ensure all files are in the root of the repository

2. **Set up Cloudflare Pages**:
   - Go to Cloudflare Dashboard → Pages
   - Click "Create a project"
   - Connect your GitHub repository
   - Set build settings:
     - Framework preset: None
     - Build command: `pip install -r requirements.txt`
     - Build output directory: `/`

3. **Configure Environment Variables**:
   In Cloudflare Pages settings, add these environment variables:
   
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   GOOGLE_CLOUD_CREDENTIALS=base64_encoded_json_credentials
   PROJECT_ID=your_google_cloud_project_id
   LOCATION=us-central1
   GOOGLE_CLOUD_MODEL=projects/YOUR_PROJECT_ID/locations/us-central1/models/YOUR_MODEL_ID
   ```

4. **Get Google Cloud Credentials**:
   ```bash
   # Download your service account key JSON file
   # Then encode it to base64:
   base64 -i path/to/your/credentials.json
   ```
   Use the output as the `GOOGLE_CLOUD_CREDENTIALS` environment variable.

5. **Deploy**:
   - Click "Save and Deploy"
   - Your app will be available at your Cloudflare Pages URL

### Environment Variables Explained

- `GEMINI_API_KEY`: Your Google AI Studio API key for Gemini
- `GOOGLE_CLOUD_CREDENTIALS`: Base64 encoded Google Cloud service account JSON
- `PROJECT_ID`: Your Google Cloud Project ID
- `LOCATION`: Google Cloud region (default: us-central1)
- `GOOGLE_CLOUD_MODEL`: Full path to your Google Cloud Translation model

## Usage

1. **Basic Translation**:
   - Enter text in the input field
   - Press Ctrl+Enter or enable Fire Mode for automatic translation

2. **AI Mode**:
   - Toggle AI Mode for enhanced translations
   - Configure custom prompts for specific keywords

3. **Custom Dictionaries**:
   - Add word replacements for consistent terminology
   - Set up keyword-based rules for context-specific translations
   - Create Gemini prompts for specialized content

4. **Settings**:
   - Configure your Gemini API key
   - Select different AI models
   - Save settings for future use

## API Endpoints

- `GET /` - Main application interface
- `POST /translate` - Translate text
- `GET /dictionaries` - Get all dictionaries
- `POST /update_dictionary` - Update dictionary entries
- `DELETE /delete_dictionary_entry` - Delete dictionary entry
- `POST /toggle_dictionary_entry` - Enable/disable dictionary entry
- `GET /get_general_prompt` - Get general AI prompt
- `POST /update_general_prompt` - Update general AI prompt
- `POST /toggle_ai_mode` - Toggle AI mode
- `POST /save_settings` - Save API settings
- `GET /load_settings` - Load API settings

## Security Notes

- API keys are stored securely as environment variables
- Credentials are base64 encoded for secure transmission
- CORS is configured for browser compatibility
- Input validation prevents malicious requests

## Troubleshooting

### Common Issues

1. **Translation fails**: Check your API keys and quotas
2. **Deployment fails**: Verify all environment variables are set
3. **UI not loading**: Check static file paths and CORS settings

### Support

For issues related to:
- Google Cloud Translation: Check Google Cloud Console
- Gemini AI: Verify API key and model availability
- Cloudflare Pages: Check build logs and environment variables

## License

This project is licensed under the MIT License.