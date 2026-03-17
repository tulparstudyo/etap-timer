# Project Structure

## Directory Layout

```
TulparKilit/
├── backend/                       # Node.js API + Frontend (static)
│   ├── server.js                 # Express app (API + static serving)
│   ├── helper.js                 # MySQL pool, migration, DB helpers
│   ├── smtp.js                   # Email service (welcome, reset, notification)
│   ├── import-json.js            # Bulk institution import (MEB JSON)
│   ├── package.json              # Dependencies and scripts
│   ├── .env                      # Environment configuration
│   └── public/                   # Frontend static files (Express serves)
│       ├── index.html            # Ana sayfa
│       ├── login.html            # Kullanici girisi
│       ├── register.html         # Kullanici kaydi
│       ├── forgot-password.html  # Sifre sifirlama
│       ├── profile.html          # Profil yonetimi
│       ├── lock.html             # Offline kilit kodu uretme
│       ├── unlock.html           # QR tarama ile kilit acma
│       ├── institution-login.html # Kurum girisi
│       ├── institution-panel.html # Kurum yonetim paneli
│       ├── admin.html            # Admin paneli
│       ├── manuel.html           # Kurulum kilavuzu
│       ├── layout.js             # Ortak header/footer/nav
│       └── style.css             # Paylasilan stiller
├── desktop/                       # Python GTK masaustu kilit uygulamasi
│   ├── tulpar_lock.py            # Kilit ekrani entry point
│   ├── tulpar_launcher.py        # Baslatici penceresi (Kilitle/Vasgec)
│   ├── lock_screen.py            # Tam ekran kilit (QR, offline, polling)
│   ├── helper.py                 # .env okuma ve yapilandirma
│   ├── requirements.txt          # Python bagimliliklari
│   └── .env                      # Desktop yapilandirmasi
├── .kiro/steering/               # Proje rehber belgeleri
├── install.sh                    # Otomatik kurulum
├── kurulum.sh                    # Alternatif kurulum
├── start.sh                      # Tum servisleri baslat
├── start-backend.sh              # Sadece backend baslat
├── start-desktop.sh              # Sadece desktop baslat
├── project.md / README.md        # Proje dokumantasyonu
├── CHANGES.md                    # Degisiklik gunlugu
├── KURULUM.md                    # Kurulum belgeleri
└── TEST.md                       # Test belgeleri
```

## Component Responsibilities

### Backend (`backend/`)
- Express.js API sunucusu + statik dosya sunumu (`public/`)
- MySQL veritabani baglantisi (AWS RDS) — `helper.js`
- JWT tabanli kimlik dogrulama (kullanici, kurum, admin — uc ayri seviye)
- QR kod oturumu olusturma ve durum takibi (in-memory `qrSessions` Map)
- Offline kilit acma destegi (challenge-response, HMAC-SHA256)
- SMTP email servisi: hos geldin, sifre sifirlama, kurum bildirimi — `smtp.js`
- Brute-force korumasi (login attempt tracking)
- HTML dosya onbellekleme (`loadHtmlCache`)
- Kurum verisi toplu aktarimi (JSON → MySQL) — `import-json.js`

### Frontend (`backend/public/`)
- Express tarafindan statik olarak sunulan Vanilla HTML/CSS/JS
- Ayri bir frontend klasoru yok — `backend/public/` icinde
- `layout.js` ile ortak header/footer/nav enjeksiyonu
- Kullanici kayit, giris, profil yonetimi
- QR tarama ile kilit acma (unlock.html)
- Offline kilit kodu uretme (lock.html)
- Kurum giris ve yonetim paneli
- Admin paneli (kurum aktivasyon/deaktivasyon)
- Kurulum kilavuzu sayfasi (manuel.html)

### Desktop (`desktop/`)
- Pardus Linux icin tam ekran kilit arayuzu (GTK 3)
- `tulpar_launcher.py`: Baslatici penceresi (Kilitle/Vasgec butonlari)
- `tulpar_lock.py`: Kilit ekranini baslatan entry point
- `lock_screen.py`: QR kod gosterimi, backend polling, offline unlock, zamanlayici
- `helper.py`: `.env` dosyasindan yapilandirma okuma
- Backend API'ye HTTP ile baglanir

## API Endpoints

### Kullanici
- `POST /register` — Kullanici kaydi
- `POST /login` — Kullanici girisi
- `POST /forgot-password` — Sifre sifirlama (email ile)
- `GET /profile` — Profil bilgisi (authenticated)
- `PUT /profile` — Profil guncelleme (authenticated)

### Kilit (Lock/Unlock)
- `GET /lock/desktop` — Desktop icin QR oturumu olustur
- `POST /unlock` — QR ile kilit ac (authenticated)
- `POST /offline-unlock-key` — Offline unlock key uret (authenticated)
- `GET /lock/status/:sessionId` — Kilit durumu sorgula

### Kurum (Institution)
- `POST /institution/login` — Kurum girisi
- `GET /institution/profile` — Kurum bilgileri
- `GET /institution/email-to` — Dogrulama email adresi
- `GET /institution/users` — Kurum kullanicilari listele
- `PUT /institution/users/:userId/permission` — Kilit acma izni toggle

### Admin
- `POST /admin/login` — Admin girisi (secret key)
- `POST /admin/institution/activate` — Kurum aktiflestir
- `POST /admin/institution/deactivate` — Kurum deaktif et
- `GET /admin/institutions` — Kurum listele (sayfali + arama)

### Genel
- `GET /institutions` — Tum kurumlari listele
- `GET /iller` — Il listesi
- `GET /ilceler` — Ilce listesi (il parametresine gore)
- `GET /institutions/search` — Kurum arama (server-side, il/ilce/q filtre)

## Configuration Files

- `backend/.env` — Backend ortam degiskenleri (DB, JWT, SMTP, Admin)
- `backend/package.json` — Node.js bagimliliklari
- `desktop/.env` — Desktop yapilandirmasi (API_URL, INSTITUTION_CODE, OFFLINE_SECRET)
- `desktop/requirements.txt` — Python bagimliliklari

## Development Workflow

1. Backend port 3000'de calisir (API + frontend statik dosyalar)
2. Frontend ayri sunucu gerektirmez — Express `public/` klasorunu sunar
3. Desktop uygulamasi backend API'ye HTTP ile baglanir
4. Tum bilesenler HTTP/REST uzerinden iletisim kurar
