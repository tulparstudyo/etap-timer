# Tulpar Kilit Sistemi - Test Rehberi

## 🧪 Sistem Testi

### 1. Backend Testi
```bash
cd backend
npm start
```
Çıktı: `Tulpar Backend çalışıyor: http://localhost:3000`

### 2. API Endpoint Testleri

#### Kurumları Listele
```bash
curl http://localhost:3000/institutions
```

#### Kullanıcı Kaydı
```bash
curl -X POST http://localhost:3000/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "phone": "05551234567",
    "institutionId": 1,
    "password": "test123"
  }'
```

#### Giriş Yap
```bash
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123"
  }'
```

Token'ı kaydedin ve aşağıdaki testlerde kullanın.

#### QR Kod Oluştur
```bash
curl http://localhost:3000/lock \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 3. Web Arayüzü Testi

1. Frontend'i başlat:
```bash
cd frontend
python3 -m http.server 8080
```

2. Tarayıcıda aç: http://localhost:8080/register.html

3. Test adımları:
   - Kayıt ol (email, telefon, kurum seç)
   - Giriş yap
   - QR kod oluştur
   - Profil güncelle

### 4. Desktop Uygulaması Testi

1. Backend ve Frontend'in çalıştığından emin ol

2. Desktop uygulamasını başlat:
```bash
cd desktop
python3 tulpar_lock.py
```

3. Test adımları:
   - Uygulama tam ekran açılmalı
   - "QR Kod Okut" butonuna tıkla
   - Web'den oluşturduğun QR'ı kameraya göster
   - Ekran açılmalı (30 dakika)
   - 30 dakika sonra otomatik kilitlenmeli

## 🐛 Sorun Giderme

### Backend başlamıyor
- Node.js kurulu mu? `node --version`
- Port 3000 kullanımda mı? `lsof -i :3000`

### Frontend açılmıyor
- Python3 kurulu mu? `python3 --version`
- Port 8080 kullanımda mı? `lsof -i :8080`

### Desktop kamera açmıyor
- OpenCV kurulu mu? `python3 -c "import cv2; print(cv2.__version__)"`
- Kamera izni var mı?
- Kamera başka uygulama tarafından kullanılıyor mu?

### QR kod okumuyor
- pyzbar kurulu mu? `python3 -c "import pyzbar; print('OK')"`
- QR kod net görünüyor mu?
- Işık yeterli mi?

## ✅ Başarı Kriterleri

- [ ] Backend başarıyla başlıyor
- [ ] Kullanıcı kaydı yapılabiliyor
- [ ] Giriş yapılabiliyor
- [ ] QR kod oluşturuluyor
- [ ] Desktop uygulaması açılıyor
- [ ] QR kod okunabiliyor
- [ ] Ekran kilidi açılıyor
- [ ] Otomatik kilit çalışıyor
