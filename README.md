# Meditation Assistant

A meditation application built with Flutter and FastAPI that generates personalized meditation guidance based on user emotions.

## Features

- Generate personalized meditation text based on user's emotions
- Convert text to voice guidance using TTS
- Clean and intuitive user interface
- Support multiple emotion selections
- Real-time text-to-speech conversion
- Responsive web design

## Tech Stack

### Frontend
- Flutter Web
- Provider (State Management)
- just_audio (Audio Playback)

### Backend
- FastAPI
- GPT-3.5 (LLM)
- Custom TTS Service

## Getting Started

### Prerequisites

- Flutter SDK
- Python 3.8+
- OpenAI API Key

### Backend Setup

1. Navigate to backend directory:
```bash
cd meditation_app/meditation_backend
```

2. Create and activate virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Create .env file with your OpenAI API key:
```bash
echo "OPENAI_API_KEY=your_key_here" > .env
```

5. Start the server:
```bash
# Development mode with auto-reload
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Production mode
uvicorn main:app --host 0.0.0.0 --port 8000
```

### Frontend Setup

1. Navigate to project root and install dependencies:
```bash
cd meditation_app
flutter pub get
```

2. Run the application (using HTML renderer for better compatibility):
```bash
# Development mode
flutter run -d chrome --web-renderer html

# Production build
flutter build web --web-renderer html
```

## Project Structure

```
meditation_app/
├── lib/
│   ├── config/          # Configuration files
│   ├── models/          # Data models
│   ├── screens/         # UI screens
│   └── services/        # Services
├── meditation_backend/
│   ├── config/          # Backend configuration
│   └── main.py         # FastAPI application
└── web/                # Web related files
```

## API Endpoints

### Generate Meditation
```http
POST /api/meditate
```

Request body:
```json
{
    "moods": ["anxious", "stressed"],
    "description": "Optional description"
}
```

Response:
```json
{
    "status": "success",
    "data": {
        "text": "Meditation text...",
        "audio_url": "/audio/filename.wav"
    }
}
```

### Get Audio File
```http
GET /audio/{filename}
```

## Environment Variables

Backend (.env):
```bash
OPENAI_API_KEY=your_api_key
```

## Development Notes

- The backend server must be running before starting the frontend
- Use HTML renderer for better web compatibility
- TTS service requires proper network connectivity
- Audio files are cached in the backend's cache directory

## License

This project is licensed under the MIT License.
