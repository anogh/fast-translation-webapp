import os
import json
import time
from typing import Dict, Any, List, Optional
from fastapi import FastAPI, Request, Form, HTTPException
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse, HTMLResponse
from pydantic import BaseModel
import re
from fastapi.middleware.cors import CORSMiddleware

# Get the absolute path of the directory containing main.py
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Load environment variables safely
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # dotenv not available in production

# Create FastAPI app with minimal configuration
app = FastAPI(
    title="Fast Translation Webapp",
    description="A fast translation service",
    version="1.0.0"
)

# Enable CORS for the translation extension
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files with absolute path
app.mount("/static", StaticFiles(directory=os.path.join(BASE_DIR, "static")), name="static")

# Templates with absolute path
templates = Jinja2Templates(directory=os.path.join(BASE_DIR, "templates"))

# Environment variables for Cloudflare
GOOGLE_CLOUD_CREDENTIALS = os.environ.get("GOOGLE_CLOUD_CREDENTIALS")
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")
PROJECT_ID = os.environ.get("PROJECT_ID", "534521643480")
LOCATION = os.environ.get("LOCATION", "us-central1")
GOOGLE_CLOUD_MODEL = os.environ.get("GOOGLE_CLOUD_MODEL", "projects/534521643480/locations/us-central1/models/NM3ad0dd20ffa743ba")

# Lazy loading for heavy dependencies
_genai = None
_translate = None
_service_account = None
_types = None

def get_genai():
    """Lazy load Google Generative AI"""
    global _genai
    if _genai is None:
        try:
            import google.generativeai as genai
            _genai = genai
        except ImportError as e:
            print(f"WARNING: Could not import google.generativeai: {e}")
            _genai = False
    return _genai if _genai is not False else None

def get_translate():
    """Lazy load Google Cloud Translate"""
    global _translate
    if _translate is None:
        try:
            from google.cloud import translate_v2 as translate
            _translate = translate
        except ImportError as e:
            print(f"WARNING: Could not import google.cloud.translate: {e}")
            _translate = False
    return _translate if _translate is not False else None

def get_service_account():
    """Lazy load Google OAuth2 Service Account"""
    global _service_account
    if _service_account is None:
        try:
            from google.oauth2 import service_account
            _service_account = service_account
        except ImportError as e:
            print(f"WARNING: Could not import google.oauth2.service_account: {e}")
            _service_account = False
    return _service_account if _service_account is not False else None

def get_types():
    """Lazy load Google Generative AI types"""
    global _types
    if _types is None:
        try:
            from google.generativeai import types
            _types = types
        except ImportError as e:
            print(f"WARNING: Could not import google.generativeai.types: {e}")
            _types = False
    return _types if _types is not False else None

# Initialize Google Cloud Translation client (lazy initialization)
client = None

def get_google_cloud_client():
    """Lazy initialization of Google Cloud Translation client"""
    global client
    
    if client is not None:
        return client
        
    if not GOOGLE_CLOUD_CREDENTIALS:
        print("WARNING: No Google Cloud credentials provided")
        return None
        
    try:
        # Get required modules
        translate = get_translate()
        service_account = get_service_account()
        
        if not translate or not service_account:
            print("WARNING: Required Google Cloud modules not available")
            return None
        
        # Handle credentials as raw JSON (not base64 encoded)
        if isinstance(GOOGLE_CLOUD_CREDENTIALS, str):
            credentials_data = json.loads(GOOGLE_CLOUD_CREDENTIALS)
        else:
            credentials_data = GOOGLE_CLOUD_CREDENTIALS
        
        # Create credentials object directly from JSON data (no file needed)
        credentials = service_account.Credentials.from_service_account_info(credentials_data)
        
        # Initialize client with credentials object
        client = translate.TranslationServiceClient(credentials=credentials)
        print("INFO: Google Cloud Translation client initialized successfully with in-memory credentials")
        return client
    except Exception as e:
        print(f"ERROR: Failed to initialize Google Cloud Translation client: {e}")
        return None

parent = f"projects/{PROJECT_ID}/locations/{LOCATION}"

# Default configuration
DEFAULT_DICTIONARIES = {
    "word_replacement": {},
    "keyword_based": {},
    "single_word": {},
    "gemini_keyword_prompts": {},
    "settings": {
        "ai_mode_enabled": False,
        "api_keys": [],
        "model_names": [],
        "current_api_key": GEMINI_API_KEY or "",
        "current_model_name": "gemini-2.5-flash-preview-05-20"
    }
}

DEFAULT_GENERAL_PROMPT = "You are an experienced English to Bengali translator. You will translate the provided text into fluent and accurate bengali. Do not output anything other than the translation."

# In-memory storage (for demo purposes - in production, use a database)
dictionaries_cache = DEFAULT_DICTIONARIES.copy()
general_prompt_cache = DEFAULT_GENERAL_PROMPT

def apply_dictionaries(text, dictionaries, original_english_text):
    used_entries = []
    
    # Apply keyword-based replacements (sorted by length)
    keyword_based = dictionaries.get("keyword_based", {})
    sorted_keywords = sorted(keyword_based.keys(), key=len, reverse=True)
    for keyword in sorted_keywords:
        entry = keyword_based[keyword]
        if not entry.get("enabled", True):
            continue
        original_bengali = entry.get("original")
        replacement_bengali = entry.get("replacement")
        
        # Check if the English keyword is in the original English text
        if keyword.lower() in original_english_text.lower():
            if original_bengali and replacement_bengali and original_bengali in text:
                highlighted = f'<span style="color:red">{replacement_bengali}</span>'
                text = text.replace(original_bengali, highlighted)
                used_entries.append({"type": "keyword_based", "key": keyword, "original": original_bengali, "replacement": replacement_bengali})

    # Apply word-replacement and single-word replacements
    word_replacements = dictionaries.get("word_replacement", {})
    single_word_replacements = dictionaries.get("single_word", {})
    enabled_word_repl = {key: val.get("value") for key, val in word_replacements.items() if val.get("enabled", True)}
    enabled_single_repl = {key: val.get("value") for key, val in single_word_replacements.items() if val.get("enabled", True)}
    all_word_replacements = {**enabled_word_repl, **enabled_single_repl}

    # Create a regex pattern for whole word matching
    sorted_keys = sorted(all_word_replacements.keys(), key=len, reverse=True)
    escaped_keys = [re.escape(key) for key in sorted_keys]
    if escaped_keys:
        pattern = r'\b(' + '|'.join(escaped_keys) + r')\b'

        def replace_word(match):
            orig = match.group(0)
            repl = all_word_replacements.get(orig, orig)
            if repl != orig:
                used_entries.append({"type": "word_replacement/single_word", "key": orig, "original": orig, "replacement": repl})
                return f'<span style="color:red">{repl}</span>'
            return repl

        text = re.sub(pattern, replace_word, text)
    
    return text, used_entries

class TranslationRequest(BaseModel):
    text: str
    original_english_text: str

@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    """Root endpoint that serves the main application and acts as a health check"""
    try:
        return templates.TemplateResponse("index.html", {
            "request": request,
            "general_prompt": general_prompt_cache,
            "ai_mode_enabled": dictionaries_cache["settings"].get("ai_mode_enabled", False),
            "api_keys": dictionaries_cache["settings"].get("api_keys", []),
            "model_names": dictionaries_cache["settings"].get("model_names", [])
        })
    except Exception as e:
        print(f"ERROR: Root endpoint error: {e}")
        # Return a simple HTML response if template fails
        return HTMLResponse(
            content="""
            <html>
                <head><title>Fast Translation Webapp</title></head>
                <body>
                    <h1>Fast Translation Webapp</h1>
                    <p>Service is running but template loading failed.</p>
                    <p>Error: """ + str(e) + """</p>
                </body>
            </html>
            """,
            status_code=200
        )

@app.post("/translate")
async def translate_text(translation_request: TranslationRequest):
    translated_text_raw = ""
    used_dictionaries = []
    
    ai_mode_enabled = dictionaries_cache["settings"].get("ai_mode_enabled", False)
    current_api_key = dictionaries_cache["settings"].get("current_api_key", GEMINI_API_KEY)
    current_model_name = dictionaries_cache["settings"].get("current_model_name", "gemini-2.5-flash-preview-05-20")

    if not translation_request.text.strip():
        raise HTTPException(status_code=400, detail="Input text cannot be empty.")

    # Get required modules
    genai = get_genai()
    types = get_types()
    
    if not genai or not types:
        raise HTTPException(status_code=500, detail="Translation services not available.")

    # Initialize Gemini client with the current API key
    if current_api_key:
        genai.configure(api_key=current_api_key)
    else:
        raise HTTPException(status_code=400, detail="No Gemini API key configured.")

    generate_content_config = types.GenerationConfig(
        response_mime_type="text/plain",
    )

    if ai_mode_enabled:
        print("INFO: Using Gemini AI Mode for translation.")
        try:
            gemini_keyword_prompts = dictionaries_cache.get("gemini_keyword_prompts", {})
            matched_gemini_keyword = None
            
            for keyword, entry in gemini_keyword_prompts.items():
                if entry.get("enabled", True) and keyword.lower() in translation_request.original_english_text.lower():
                    matched_gemini_keyword = entry
                    break

            system_instruction_text = general_prompt_cache
            if matched_gemini_keyword:
                keyword_prompt = matched_gemini_keyword.get("prompt", "")
                system_instruction_text = f"{general_prompt_cache}\n\n{keyword_prompt}"
                used_dictionaries.append({"type": "gemini_keyword_prompt", "key": matched_gemini_keyword.get("keyword"), "prompt": keyword_prompt})
            else:
                used_dictionaries.append({"type": "gemini_ai_mode", "prompt": general_prompt_cache})

            # Use GenerativeModel with system_instruction for AI mode
            model_gemini = genai.GenerativeModel(current_model_name, system_instruction=system_instruction_text)
            
            # Send the user's text as content
            response_stream = model_gemini.generate_content(
                contents=[types.Content(role="user", parts=[types.Part.from_text(text=translation_request.text)])],
                generation_config=generate_content_config,
                stream=True
            )
            translated_text_raw = "".join(chunk.text for chunk in response_stream)
            
        except Exception as e:
            print(f"Gemini AI Mode translation error: {e}")
            raise HTTPException(status_code=500, detail="An error occurred during AI Mode translation with Gemini.")
    else:
        # Existing logic for non-AI mode (keyword-based Gemini or Google Cloud Translation)
        gemini_keyword_prompts = dictionaries_cache.get("gemini_keyword_prompts", {})
        matched_gemini_keyword = None
        for keyword, entry in gemini_keyword_prompts.items():
            if entry.get("enabled", True) and keyword.lower() in translation_request.original_english_text.lower():
                matched_gemini_keyword = entry
                break

        if matched_gemini_keyword:
            print("INFO: Using Gemini Keyword Prompt for translation.")
            try:
                keyword_prompt = matched_gemini_keyword.get("prompt", "")
                full_prompt = f"{general_prompt_cache}\n\n{keyword_prompt}\n\nTranslate the following text to Bengali: {translation_request.text}"
                
                # For keyword-based, use the full_prompt as content, not system_instruction
                model_gemini = genai.GenerativeModel(current_model_name)
                response_stream = model_gemini.generate_content(
                    contents=[types.Content(role="user", parts=[types.Part.from_text(text=full_prompt)])],
                    generation_config=generate_content_config,
                    stream=True
                )
                translated_text_raw = "".join(chunk.text for chunk in response_stream)
                used_dictionaries.append({"type": "gemini_keyword_prompt", "key": matched_gemini_keyword.get("keyword"), "prompt": keyword_prompt})
            except Exception as e:
                print(f"Gemini translation error: {e}")
                # Fallback to Google Cloud Translation if Gemini fails
                fallback_client = get_google_cloud_client()
                if fallback_client:
                    try:
                        print("INFO: Falling back to Google Cloud Translation API.")
                        response = fallback_client.translate_text(
                            request={
                                "parent": parent,
                                "contents": [translation_request.text],
                                "mime_type": "text/plain",
                                "source_language_code": "en-US",
                                "target_language_code": "bn",
                                "model": GOOGLE_CLOUD_MODEL,
                            }
                        )
                        translated_text_raw = response.translations[0].translated_text
                    except Exception as e:
                        print(f"Translation error (fallback): {e}")
                        raise HTTPException(status_code=500, detail="An error occurred during translation.")
                else:
                    raise HTTPException(status_code=500, detail="Translation service unavailable.")
        else:
            translation_client = get_google_cloud_client()
            if translation_client:
                print("INFO: Using Google Cloud Translation API for translation.")
                try:
                    response = translation_client.translate_text(
                        request={
                            "parent": parent,
                            "contents": [translation_request.text],
                            "mime_type": "text/plain",
                            "source_language_code": "en-US",
                            "target_language_code": "bn",
                            "model": GOOGLE_CLOUD_MODEL,
                        }
                    )
                    translated_text_raw = response.translations[0].translated_text
                except Exception as e:
                    print(f"Translation error: {e}")
                    raise HTTPException(status_code=500, detail="An error occurred during translation.")
            else:
                raise HTTPException(status_code=500, detail="Translation service unavailable.")

    # Apply dictionaries and get used entries
    translated_text_with_dicts, applied_dicts = apply_dictionaries(
        translated_text_raw,
        dictionaries_cache,
        translation_request.original_english_text
    )
    used_dictionaries.extend(applied_dicts)
    
    return {"translation": translated_text_with_dicts, "used_dictionaries": used_dictionaries}

@app.get("/dictionaries")
async def get_dictionaries():
    return dictionaries_cache

@app.post("/update_dictionary")
async def update_dictionary(dict_type: str = Form(...), key: str = Form(...), value: str = Form(...)):
    global dictionaries_cache
    if dict_type in ["keyword_based", "gemini_keyword_prompts"]:
        entry = json.loads(value)
        entry.setdefault("enabled", True)
        dictionaries_cache[dict_type][key] = entry
    else:
        dictionaries_cache[dict_type][key] = {"value": value, "enabled": True}
    return {"status": "success"}

@app.delete("/delete_dictionary_entry")
async def delete_dictionary_entry(dict_type: str = Form(...), key: str = Form(...)):
    global dictionaries_cache
    if key in dictionaries_cache[dict_type]:
        del dictionaries_cache[dict_type][key]
        return {"status": "success"}
    return {"status": "error", "message": "Key not found"}

@app.post("/toggle_dictionary_entry")
async def toggle_dictionary_entry(dict_type: str = Form(...), key: str = Form(...), enabled: bool = Form(...)):
    global dictionaries_cache
    if key in dictionaries_cache.get(dict_type, {}):
        entry = dictionaries_cache[dict_type]
        if isinstance(entry, dict):
            if key in entry:
                entry[key]["enabled"] = enabled
                return {"status": "success"}
        elif dict_type in ["word_replacement", "single_word"]:
            if key in dictionaries_cache[dict_type]:
                dictionaries_cache[dict_type][key]["enabled"] = enabled
                return {"status": "success"}
    return {"status": "error", "message": "Key not found or invalid dictionary type."}

@app.get("/get_general_prompt")
async def get_general_prompt():
    return {"prompt": general_prompt_cache}

@app.post("/update_general_prompt")
async def update_general_prompt(prompt: str = Form(...)):
    global general_prompt_cache
    general_prompt_cache = prompt
    return {"status": "success"}

@app.get("/get_ai_mode_status")
async def get_ai_mode_status():
    return {"ai_mode_enabled": dictionaries_cache["settings"].get("ai_mode_enabled", False)}

@app.post("/toggle_ai_mode")
async def toggle_ai_mode(enabled: bool = Form(...)):
    global dictionaries_cache
    dictionaries_cache["settings"]["ai_mode_enabled"] = enabled
    return {"status": "success"}

@app.post("/save_settings")
async def save_settings(api_key: str = Form(None), model_name: str = Form(None)):
    global dictionaries_cache
    settings = dictionaries_cache.get("settings", {})

    if api_key:
        if "api_keys" not in settings:
            settings["api_keys"] = []
        if api_key not in settings["api_keys"]:
            settings["api_keys"].insert(0, api_key)
            settings["api_keys"] = settings["api_keys"][:10]
        settings["current_api_key"] = api_key

    if model_name:
        if "model_names" not in settings:
            settings["model_names"] = []
        if model_name not in settings["model_names"]:
            settings["model_names"].insert(0, model_name)
            settings["model_names"] = settings["model_names"][:10]
        settings["current_model_name"] = model_name

    dictionaries_cache["settings"] = settings
    return {"status": "success"}

@app.get("/load_settings")
async def load_settings():
    settings = dictionaries_cache.get("settings", {})
    return {
        "api_keys": settings.get("api_keys", []),
        "model_names": settings.get("model_names", []),
        "current_api_key": settings.get("current_api_key", ""),
        "current_model_name": settings.get("current_model_name", "")
    }

# Health check endpoints for Cloudflare Pages
@app.get("/health")
async def health_check():
    """Fast health check endpoint"""
    return {
        "status": "healthy", 
        "service": "fast-translation-webapp",
        "version": "1.0.0"
    }

@app.get("/ping")
async def ping():
    """Simple ping endpoint for load balancer health checks"""
    return {"message": "pong"}

# Startup event - keep it minimal for fast startup
@app.on_event("startup")
async def startup_event():
    print("INFO: Fast Translation webapp starting up...")
    print("INFO: Server ready to accept connections")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app, 
        host="0.0.0.0", 
        port=int(os.environ.get("PORT", 8000)),
        timeout_keep_alive=30,
        timeout_graceful_shutdown=10
    )