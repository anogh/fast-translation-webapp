let dictionaries = {};
let fireMode = false;
let aiModeEnabled = false;
let lastFocusTime = 0;

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    fetchDictionaries();
    setupEventListeners();
    loadSettings();
});

function setupEventListeners() {
    // Fire mode toggle
    document.getElementById('fireMode').addEventListener('click', function() {
        fireMode = !fireMode;
        this.textContent = `Fire Mode: ${fireMode ? 'On' : 'Off'}`;
        this.style.background = fireMode ? 
            'linear-gradient(135deg, #ef4444, #dc2626)' : 
            'linear-gradient(135deg, #8b5cf6, #7c3aed)';
    });

    // AI mode toggle
    document.getElementById('aiModeToggle').addEventListener('click', toggleAiMode);

    // Input text change handler
    document.getElementById('inputText').addEventListener('input', function() {
        if (fireMode) {
            clearTimeout(window.translationTimeout);
            window.translationTimeout = setTimeout(translateText, 500);
        }
    });

    // Manual translation trigger
    document.getElementById('inputText').addEventListener('keydown', function(e) {
        if (e.key === 'Enter' && e.ctrlKey) {
            translateText();
        }
    });

    // Copy translation button
    document.getElementById('copyTranslation').addEventListener('click', copyTranslation);

    // Settings buttons
    document.getElementById('saveSettings').addEventListener('click', saveSettings);
    document.getElementById('loadSettings').addEventListener('click', loadSettings);
}

async function fetchDictionaries() {
    try {
        const response = await fetch('/dictionaries');
        dictionaries = await response.json();
        
        const generalPromptResponse = await fetch('/get_general_prompt');
        const generalPromptData = await generalPromptResponse.json();
        document.getElementById('generalPromptTextarea').value = generalPromptData.prompt;

        const aiModeStatusResponse = await fetch('/get_ai_mode_status');
        const aiModeStatusData = await aiModeStatusResponse.json();
        aiModeEnabled = aiModeStatusData.ai_mode_enabled;
        updateAiModeButton();

        updateDictionaryLists();
    } catch (error) {
        showMessage('Error fetching dictionaries: ' + error.message, 'error');
    }
}

async function translateText() {
    const inputText = document.getElementById('inputText').value.trim();
    if (!inputText) {
        showMessage('Please enter text to translate', 'error');
        return;
    }

    const originalTranslationDiv = document.getElementById('originalTranslation');
    const finalTranslationDiv = document.getElementById('finalTranslation');
    
    // Show loading state
    originalTranslationDiv.value = 'Translating...';
    finalTranslationDiv.innerHTML = '<div class="loading">Translating...</div>';

    try {
        const response = await fetch('/translate', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                text: inputText,
                original_english_text: inputText
            })
        });

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.detail || 'Translation failed');
        }

        const data = await response.json();
        
        // Remove HTML tags for original translation display
        const plainTranslation = data.translation.replace(/<[^>]*>/g, '');
        originalTranslationDiv.value = plainTranslation;
        
        // Show formatted translation with highlights
        finalTranslationDiv.innerHTML = data.translation;
        
        // Update used dictionaries list
        updateUsedDictionariesList(data.used_dictionaries);
        
        showMessage('Translation completed successfully!', 'success');
    } catch (error) {
        originalTranslationDiv.value = '';
        finalTranslationDiv.innerHTML = `<div class="error">Error: ${error.message}</div>`;
        showMessage('Translation error: ' + error.message, 'error');
    }
}

async function toggleAiMode() {
    try {
        const response = await fetch('/toggle_ai_mode', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: `enabled=${!aiModeEnabled}`
        });

        if (response.ok) {
            aiModeEnabled = !aiModeEnabled;
            updateAiModeButton();
            showMessage(`AI Mode ${aiModeEnabled ? 'enabled' : 'disabled'}`, 'success');
        }
    } catch (error) {
        showMessage('Error toggling AI mode: ' + error.message, 'error');
    }
}

function updateAiModeButton() {
    const button = document.getElementById('aiModeToggle');
    button.textContent = `AI Mode: ${aiModeEnabled ? 'On' : 'Off'}`;
    button.style.background = aiModeEnabled ? 
        'linear-gradient(135deg, #10b981, #059669)' : 
        'linear-gradient(135deg, #8b5cf6, #7c3aed)';
}

function copyTranslation() {
    const finalTranslation = document.getElementById('finalTranslation');
    const text = finalTranslation.innerText || finalTranslation.textContent;
    
    if (!text || text.trim() === '') {
        showMessage('No translation to copy', 'error');
        return;
    }

    navigator.clipboard.writeText(text).then(() => {
        showMessage('Translation copied to clipboard!', 'success');
    }).catch(() => {
        // Fallback for older browsers
        const textArea = document.createElement('textarea');
        textArea.value = text;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
        showMessage('Translation copied to clipboard!', 'success');
    });
}

async function saveSettings() {
    const apiKey = document.getElementById('apiKeyInput').value;
    const modelName = document.getElementById('modelNameInput').value;

    if (!apiKey && !modelName) {
        showMessage('Please enter at least one setting to save', 'error');
        return;
    }

    try {
        const formData = new FormData();
        if (apiKey) formData.append('api_key', apiKey);
        if (modelName) formData.append('model_name', modelName);

        const response = await fetch('/save_settings', {
            method: 'POST',
            body: formData
        });

        if (response.ok) {
            showMessage('Settings saved successfully!', 'success');
            loadSettings(); // Refresh the dropdowns
        }
    } catch (error) {
        showMessage('Error saving settings: ' + error.message, 'error');
    }
}

async function loadSettings() {
    try {
        const response = await fetch('/load_settings');
        const settings = await response.json();

        // Update API keys dropdown
        const apiKeysDatalist = document.getElementById('apiKeys');
        apiKeysDatalist.innerHTML = '';
        settings.api_keys.forEach(key => {
            const option = document.createElement('option');
            option.value = key;
            apiKeysDatalist.appendChild(option);
        });

        // Update model names dropdown
        const modelNamesDatalist = document.getElementById('modelNames');
        modelNamesDatalist.innerHTML = '';
        settings.model_names.forEach(name => {
            const option = document.createElement('option');
            option.value = name;
            modelNamesDatalist.appendChild(option);
        });

        // Set current values
        document.getElementById('apiKeyInput').value = settings.current_api_key || '';
        document.getElementById('modelNameInput').value = settings.current_model_name || '';
    } catch (error) {
        showMessage('Error loading settings: ' + error.message, 'error');
    }
}

async function saveGeneralPrompt() {
    const prompt = document.getElementById('generalPromptTextarea').value;
    
    try {
        const formData = new FormData();
        formData.append('prompt', prompt);

        const response = await fetch('/update_general_prompt', {
            method: 'POST',
            body: formData
        });

        if (response.ok) {
            showMessage('General prompt saved successfully!', 'success');
        }
    } catch (error) {
        showMessage('Error saving general prompt: ' + error.message, 'error');
    }
}

async function updateDictionary(dictType) {
    let key, value;

    if (dictType === 'word_replacement') {
        key = document.getElementById('wordReplacementKey').value;
        value = document.getElementById('wordReplacementValue').value;
    } else if (dictType === 'keyword_based') {
        key = document.getElementById('keywordBasedKey').value;
        const original = document.getElementById('keywordBasedOriginal').value;
        const replacement = document.getElementById('keywordBasedReplacement').value;
        value = JSON.stringify({ original, replacement });
    } else if (dictType === 'single_word') {
        key = document.getElementById('singleWordKey').value;
        value = document.getElementById('singleWordValue').value;
    } else if (dictType === 'gemini_keyword_prompts') {
        key = document.getElementById('geminiKeywordPromptKey').value;
        const prompt = document.getElementById('geminiKeywordPromptValue').value;
        value = JSON.stringify({ keyword: key, prompt });
    }

    if (!key || !value) {
        showMessage('Please fill in all fields', 'error');
        return;
    }

    try {
        const formData = new FormData();
        formData.append('dict_type', dictType);
        formData.append('key', key);
        formData.append('value', value);

        const response = await fetch('/update_dictionary', {
            method: 'POST',
            body: formData
        });

        if (response.ok) {
            showMessage('Dictionary updated successfully!', 'success');
            fetchDictionaries(); // Refresh the display
            clearInputFields(dictType);
        }
    } catch (error) {
        showMessage('Error updating dictionary: ' + error.message, 'error');
    }
}

function clearInputFields(dictType) {
    if (dictType === 'word_replacement') {
        document.getElementById('wordReplacementKey').value = '';
        document.getElementById('wordReplacementValue').value = '';
    } else if (dictType === 'keyword_based') {
        document.getElementById('keywordBasedKey').value = '';
        document.getElementById('keywordBasedOriginal').value = '';
        document.getElementById('keywordBasedReplacement').value = '';
    } else if (dictType === 'single_word') {
        document.getElementById('singleWordKey').value = '';
        document.getElementById('singleWordValue').value = '';
    } else if (dictType === 'gemini_keyword_prompts') {
        document.getElementById('geminiKeywordPromptKey').value = '';
        document.getElementById('geminiKeywordPromptValue').value = '';
    }
}

async function deleteDictionaryEntry(dictType, key) {
    if (!confirm('Are you sure you want to delete this entry?')) {
        return;
    }

    try {
        const formData = new FormData();
        formData.append('dict_type', dictType);
        formData.append('key', key);

        const response = await fetch('/delete_dictionary_entry', {
            method: 'DELETE',
            body: formData
        });

        if (response.ok) {
            showMessage('Entry deleted successfully!', 'success');
            fetchDictionaries();
        }
    } catch (error) {
        showMessage('Error deleting entry: ' + error.message, 'error');
    }
}

async function toggleDictionaryEntry(dictType, key, enabled) {
    try {
        const formData = new FormData();
        formData.append('dict_type', dictType);
        formData.append('key', key);
        formData.append('enabled', enabled);

        const response = await fetch('/toggle_dictionary_entry', {
            method: 'POST',
            body: formData
        });

        if (response.ok) {
            fetchDictionaries();
        }
    } catch (error) {
        showMessage('Error toggling entry: ' + error.message, 'error');
    }
}

function updateDictionaryLists() {
    updateWordReplacementList();
    updateKeywordBasedList();
    updateSingleWordList();
    updateGeminiKeywordPromptsList();
}

function updateWordReplacementList() {
    const container = document.getElementById('wordReplacementList');
    container.innerHTML = '';

    Object.entries(dictionaries.word_replacement || {}).forEach(([key, entry]) => {
        const div = createDictionaryEntryDiv(key, entry.value, entry.enabled, 'word_replacement');
        container.appendChild(div);
    });
}

function updateKeywordBasedList() {
    const container = document.getElementById('keywordBasedList');
    container.innerHTML = '';

    Object.entries(dictionaries.keyword_based || {}).forEach(([key, entry]) => {
        const displayText = `${key} → ${entry.original} → ${entry.replacement}`;
        const div = createDictionaryEntryDiv(key, displayText, entry.enabled, 'keyword_based');
        container.appendChild(div);
    });
}

function updateSingleWordList() {
    const container = document.getElementById('singleWordList');
    container.innerHTML = '';

    Object.entries(dictionaries.single_word || {}).forEach(([key, entry]) => {
        const div = createDictionaryEntryDiv(key, entry.value, entry.enabled, 'single_word');
        container.appendChild(div);
    });
}

function updateGeminiKeywordPromptsList() {
    const container = document.getElementById('geminiKeywordPromptsList');
    container.innerHTML = '';

    Object.entries(dictionaries.gemini_keyword_prompts || {}).forEach(([key, entry]) => {
        const displayText = `${key}: ${entry.prompt.substring(0, 50)}...`;
        const div = createDictionaryEntryDiv(key, displayText, entry.enabled, 'gemini_keyword_prompts');
        container.appendChild(div);
    });
}

function createDictionaryEntryDiv(key, displayText, enabled, dictType) {
    const div = document.createElement('div');
    div.className = 'dictionary-entry';
    
    const textSpan = document.createElement('span');
    textSpan.textContent = `${key} → ${displayText}`;
    textSpan.style.opacity = enabled ? '1' : '0.5';
    
    const buttonsDiv = document.createElement('div');
    buttonsDiv.className = 'action-buttons';
    
    const toggleBtn = document.createElement('button');
    toggleBtn.textContent = enabled ? 'Disable' : 'Enable';
    toggleBtn.className = `toggle-button ${enabled ? 'enabled' : ''}`;
    toggleBtn.onclick = () => toggleDictionaryEntry(dictType, key, !enabled);
    
    const deleteBtn = document.createElement('button');
    deleteBtn.textContent = 'Delete';
    deleteBtn.className = 'delete-button';
    deleteBtn.onclick = () => deleteDictionaryEntry(dictType, key);
    
    buttonsDiv.appendChild(toggleBtn);
    buttonsDiv.appendChild(deleteBtn);
    
    div.appendChild(textSpan);
    div.appendChild(buttonsDiv);
    
    return div;
}

function updateUsedDictionariesList(usedDictionaries) {
    const container = document.getElementById('usedDictionariesList');
    container.innerHTML = '';

    if (!usedDictionaries || usedDictionaries.length === 0) {
        const li = document.createElement('li');
        li.textContent = 'No dictionary entries used.';
        li.className = 'text-gray-500';
        container.appendChild(li);
        return;
    }

    usedDictionaries.forEach(entry => {
        const li = document.createElement('li');
        li.className = 'mb-2 p-2 bg-blue-50 rounded border-l-4 border-blue-400';
        
        if (entry.type === 'gemini_ai_mode') {
            li.innerHTML = `<strong>AI Mode:</strong> Used general prompt`;
        } else if (entry.type === 'gemini_keyword_prompt') {
            li.innerHTML = `<strong>Keyword Prompt:</strong> ${entry.key}`;
        } else {
            li.innerHTML = `<strong>${entry.type}:</strong> ${entry.key} → ${entry.replacement || entry.original}`;
        }
        
        container.appendChild(li);
    });
}

function showMessage(message, type) {
    // Remove existing messages
    const existingMessages = document.querySelectorAll('.message');
    existingMessages.forEach(msg => msg.remove());

    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${type}`;
    messageDiv.textContent = message;

    // Insert at the top of the container
    const container = document.querySelector('.container');
    container.insertBefore(messageDiv, container.firstChild);

    // Auto-remove after 5 seconds
    setTimeout(() => {
        messageDiv.remove();
    }, 5000);
}