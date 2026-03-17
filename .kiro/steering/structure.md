# Project Structure

## Directory Layout

```
TulparKilit/
├── backend/              # Node.js API server
│   ├── server.js        # Main Express application
│   ├── package.json     # Dependencies and scripts
│   └── .env            # Environment configuration
├── frontend/            # Web interface (static HTML/CSS/JS)
│   ├── register.html   # User registration page
│   ├── login.html      # User login page
│   ├── profile.html    # Profile management
│   ├── lock.html       # Main dashboard
│   ├── unlock.html     # QR scanning interface
│   └── style.css       # Shared styles
├── desktop/             # Python GTK desktop lock application
│   ├── tulpar_lock.py  # Main lock screen application
│   └── requirements.txt # Python dependencies
├── .kiro/               # Kiro AI assistant configuration
│   └── steering/       # Project guidance documents
├── install.sh           # Automated setup script
└── start.sh            # Launch all services
```

## Component Responsibilities

### Backend (`backend/`)
- RESTful API endpoints for authentication and QR management
- In-memory data storage (users, institutions, QR sessions)
- JWT token generation and validation
- QR code generation for desktop lock screens
- Session management and cleanup

### Frontend (`frontend/`)
- User registration and login flows
- Profile management interface
- QR code scanning for unlock (mobile/web)
- No build process - served as static files

### Desktop (`desktop/`)
- Full-screen lock interface for Pardus Linux
- QR code display from backend API
- Polling backend for unlock status
- Auto-relock after timeout

## API Structure

Backend follows RESTful conventions:
- `POST /register` - User registration
- `POST /login` - Authentication
- `GET /profile` - Fetch user data (authenticated)
- `PUT /profile` - Update user data (authenticated)
- `GET /lock/desktop` - Generate QR for desktop
- `POST /unlock` - Validate QR and unlock
- `GET /lock/status/:sessionId` - Check unlock status
- `GET /institutions` - List available institutions

## Configuration Files

- `backend/.env` - Backend environment variables
- `backend/package.json` - Node.js dependencies
- `desktop/requirements.txt` - Python dependencies
- Root scripts (`install.sh`, `start.sh`) - System setup and launch

## Development Workflow

1. Backend runs on port 3000
2. Frontend served on port 8080
3. Desktop app connects to backend API
4. All components communicate via HTTP/REST
