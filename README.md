# Tulpar Kilit Sistemi

Pardus Linux için QR kod tabanlı ekran kilitleme ve merkezi yönetim uygulaması.

## � Nasıl Çalışır?

1. Masaüstü uygulaması ekranı kilitler ve QR kod gösterir
2. Kullanıcı telefonundan/tarayıcısından QR kodu taratır
3. Backend doğrulama yapar, kilit açılır
4. Belirlenen süre sonunda ekran otomatik kilitlenir

## �📁 Proje Yapısı

```
TulparKilit/
├── backend/              # Node.js API sunucusu + Web arayüzü
│   ├── server.js         # Express API uygulaması
│   ├── helper.js         # Yardımcı fonksiyonlar
│   ├── smtp.js           # E-posta gönderim modülü
│   ├── import-schools.js # Kurum verisi aktarımı
│   ├── public/           # Web arayüzü (statik dosyalar)
│   │   ├── login.html    # Giriş sayfası
│   │   ├── register.html # Kayıt sayfası
│   │   ├── profile.html  # Profil yönetimi
│   │   ├── unlock.html   # QR tarayıcı (kamera ile)
│   │   ├── lock.html     # Ana sayfa
│   │   ├── forgot-password.html # Şifre sıfırlama
│   │   ├── layout.js     # Ortak sayfa düzeni
│   │   └── style.css     # Paylaşılan stiller
│   └── .env              # Ortam değişkenleri
├── desktop/              # Python GTK masaüstü uygulaması
│   ├── tulpar_lock.py    # Tam ekran kilit + QR gösterici
│   ├── tulpar_launcher.py # Masaüstü başlatıcı penceresi
│   ├── lock_screen.py    # Kilit ekranı modülü
│   ├── helper.py         # Yardımcı fonksiyonlar
│   └── requirements.txt  # Python bağımlılıkları
├── kurulum.sh            # Pardus otomatik kurulum scripti
├── install.sh            # Geliştirici kurulum scripti
├── start.sh              # Tüm servisleri başlat
├── start-backend.sh      # Sadece backend başlat
└── start-desktop.sh      # Sadece desktop başlat
```

## 🚀 Kurulum

### Pardus Bilgisayarlara Kurulum (Üretim)

```bash
# Tek komutla kurulum — tüm kullanıcılar için yapılandırır
sudo ./kurulum.sh
```

Bu script şunları yapar:
- Sistem bağımlılıklarını kurar (Python GTK, pip, git)
- Projeyi `/opt/tulpar-kilit` dizinine indirir
- Python bağımlılıklarını yükler
- Kurum kodu ve API yapılandırmasını ayarlar
- Systemd servisi ve autostart kaydı oluşturur
- Tüm mevcut ve yeni kullanıcılar için masaüstü kısayolu oluşturur

### Geliştirici Kurulumu

```bash
# Bağımlılıkları kur
./install.sh

# Tüm servisleri başlat
./start.sh

# Veya ayrı ayrı:
./start-backend.sh
./start-desktop.sh
```

### Manuel Başlatma

```bash
# Backend (port 3000)
cd backend && npm start

# Desktop kilit uygulaması
cd desktop && python3 tulpar_lock.py
```

## ⚙️ Yapılandırma

### Backend (`backend/.env`)

| Değişken | Açıklama | Varsayılan |
|----------|----------|------------|
| `PORT` | API sunucu portu | `3000` |
| `JWT_SECRET` | Token şifreleme anahtarı | — |
| `LOCK_DURATION_MINUTES` | Kilit açık kalma süresi (dk) | `3` |
| `OFFLINE_SECRET` | Çevrimdışı kilit açma anahtarı | — |
| `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `DB_PORT` | MySQL bağlantı bilgileri | — |
| `SMTP_HOST`, `SMTP_USER`, `SMTP_PASS`, `SMTP_PORT`, `SMTP_SENDER` | E-posta (SMTP) ayarları | — |

### Desktop (`desktop/.env`)

| Değişken | Açıklama | Varsayılan |
|----------|----------|------------|
| `API_URL` | Backend API adresi | `https://kilit.dosyamosya.com` |
| `INSTITUTION_CODE` | Kurum kodu | — |
| `UNLOCK_DURATION` | Kilit açık kalma süresi (dk) | `1` |
| `OFFLINE_SECRET` | Çevrimdışı kilit açma anahtarı | — |
| `INSTITUTION_NAME` | Kurum adı (opsiyonel) | — |

## 🔐 API Endpoints

### Kimlik Doğrulama
- `POST /register` — Kullanıcı kaydı (email, telefon, kurum)
- `POST /login` — Giriş
- `POST /forgot-password` — Şifre sıfırlama e-postası

### Profil
- `GET /profile` — Profil bilgileri (auth gerekli)
- `PUT /profile` — Profil güncelleme (auth gerekli)

### Kilit Yönetimi
- `GET /lock/desktop` — Desktop için QR kod üretimi (`?institutionCode=...`)
- `POST /unlock` — QR kod ile kilit açma (auth gerekli)
- `POST /offline-unlock-key` — Çevrimdışı kilit açma anahtarı üretimi (auth gerekli)
- `GET /lock/status/:sessionId` — Kilit durumu sorgulama

### Kurum ve Konum
- `GET /institutions` — Kurum listesi
- `GET /institutions/search` — Kurum arama (`?q=...&il=...&ilce=...`)
- `GET /iller` — İl listesi
- `GET /ilceler` — İlçe listesi (`?il=...`)

## 📋 Gereksinimler

### Backend
- Node.js 16+
- MySQL veritabanı (AWS RDS veya yerel)

### Desktop
- Python 3.8+
- GTK 3 + PyGObject
- Pardus Linux

### Web Arayüzü
- Modern web tarayıcı (kamera erişimi için HTTPS gerekli)

## 🛠️ Teknoloji

| Katman | Teknoloji |
|--------|-----------|
| Backend | Node.js, Express.js, JWT, bcryptjs |
| Veritabanı | MySQL (AWS RDS) |
| Web | Vanilla HTML/CSS/JS |
| Desktop | Python 3, GTK 3, PyGObject |
| E-posta | SMTP (Brevo/Yandex) |
| QR | qrcode (backend), tarayıcı kamera (frontend) |

## 🔒 Güvenlik Notları

- JWT tokenlar 24 saatte sona erer
- QR oturumları tek kullanımlık ve süreli (60 saniyede temizlenir)
- Şifreler bcrypt ile hashlenir
- Çevrimdışı kilit açma challenge-response mekanizması kullanır
- Production'da CORS kısıtlanmalıdır

## 📝 TODO

- [ ] HTTPS desteği
- [ ] Çoklu monitör desteği
- [ ] Mobil uygulama (QR okuma için)
- [ ] Admin paneli (kurum yönetimi)
- [ ] Log sistemi
- [ ] Bildirim sistemi

## 📄 Lisans

MIT
