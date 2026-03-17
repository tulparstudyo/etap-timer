# Technology Stack

## Backend
- **Runtime**: Node.js 16+
- **Framework**: Express.js
- **Authentication**: JWT (jsonwebtoken), bcryptjs
- **Database**: MySQL (mysql2/promise) — AWS RDS
- **Email**: Nodemailer (SMTP — Brevo relay)
- **UUID**: uuid library (QR session IDs)
- **CORS**: cors middleware
- **Environment**: dotenv for configuration

## Frontend
- **Stack**: Vanilla HTML/CSS/JavaScript
- **No build system**: Static files served by Express from `backend/public/`
- **No separate frontend server**: Express handles everything
- **QR Scanning**: Browser-based (unlock.html)

## Desktop Application
- **Language**: Python 3.8+
- **GUI**: GTK 3 with PyGObject
- **HTTP Client**: requests library
- **QR Generation**: qrcode[pil] library
- **Platform**: Pardus Linux

## Data Storage
- **Database**: MySQL (AWS RDS — eu-central-1)
- **Tables**: `institutions`, `users`
- **QR Sessions**: In-memory Map (server.js)
- **Migration**: Auto-create tables on startup (`helper.js`)

## Common Commands

### Backend
```bash
cd backend
npm install          # Install dependencies
npm start           # Start production server (port 3000)
npm run dev         # Start with nodemon (auto-reload)
```

### Desktop
```bash
cd desktop
pip install -r requirements.txt    # Install dependencies
python3 tulpar_lock.py            # Run lock application
python3 tulpar_launcher.py        # Run launcher window
```

### Full System
```bash
./install.sh    # One-time setup (installs all dependencies)
./start.sh      # Start all services (backend + desktop)
./start-backend.sh   # Start only backend
./start-desktop.sh   # Start only desktop
```

### Data Import
```bash
cd backend
node import-json.js ../kurumlar.json   # Import institutions from JSON
```

## Environment Configuration

### Backend (`backend/.env`)
- `PORT`: API server port (default: 3000)
- `JWT_SECRET`: Token encryption key
- `OFFLINE_SECRET`: Offline unlock HMAC key
- `ADMIN_SECRET`: Admin login secret
- `APP_VERSION`: Application version
- `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `DB_PORT`: MySQL connection
- `SMTP_HOST`, `SMTP_USER`, `SMTP_PASS`, `SMTP_PORT`, `SMTP_SENDER`: Email config
- `EMAIL_TO`: Admin notification email

### Desktop (`desktop/.env`)
- `API_URL`: Backend API address
- `INSTITUTION_CODE`: Kurum kodu
- `OFFLINE_SECRET`: Offline unlock secret (must match backend)
- `INSTITUTION_NAME`: Kurum adi (display)
- `UNLOCK_DURATION`: Kilit acma suresi (dakika)

## Security Notes
- CORS currently allows all origins (restrict in production)
- JWT tokens expire in 24 hours
- Three auth levels: user (`authenticate`), institution (`authenticateInstitution`), admin (`authenticateAdmin`)
- Brute-force protection: login attempt tracking with lockout
- QR sessions auto-expire and are cleaned up every 60 seconds
- Offline unlock uses HMAC-SHA256 challenge-response
- Passwords hashed with bcryptjs
