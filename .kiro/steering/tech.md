# Technology Stack

## Backend
- **Runtime**: Node.js 16+
- **Framework**: Express.js
- **Authentication**: JWT (jsonwebtoken), bcryptjs
- **QR Generation**: qrcode library
- **CORS**: cors middleware
- **Environment**: dotenv for configuration

## Frontend
- **Stack**: Vanilla HTML/CSS/JavaScript
- **No build system**: Static files served directly
- **QR Scanning**: Browser-based (implementation needed)

## Desktop Application
- **Language**: Python 3.8+
- **GUI**: GTK 3 with PyGObject
- **HTTP Client**: requests library
- **Platform**: Pardus Linux

## Data Storage
- **Current**: In-memory (development only)
- **Production TODO**: MongoDB or PostgreSQL

## Common Commands

### Backend
```bash
cd backend
npm install          # Install dependencies
npm start           # Start production server (port 3000)
npm run dev         # Start with nodemon (auto-reload)
```

### Frontend
```bash
cd frontend
python3 -m http.server 8080    # Serve on port 8080
```

### Desktop
```bash
cd desktop
pip install -r requirements.txt    # Install dependencies
python3 tulpar_lock.py            # Run lock application
```

### Full System
```bash
./install.sh    # One-time setup (installs all dependencies)
./start.sh      # Start all services (backend + frontend + desktop)
```

## Environment Configuration

Backend uses `.env` file with:
- `PORT`: API server port (default: 3000)
- `JWT_SECRET`: Token encryption key
- `LOCK_DURATION_MINUTES`: Screen unlock duration (default: 30)

## Security Notes
- CORS currently allows all origins (restrict in production)
- JWT tokens expire in 24 hours
- QR sessions auto-expire and are cleaned up every 60 seconds
