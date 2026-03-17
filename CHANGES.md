# 🔄 Tulpar Kilit - Sistem Değişikliği

## ✅ Yeni Mimari

### Önceki Sistem (Yanlış)
- ❌ Web: QR kod gösteriyordu
- ❌ Desktop: QR kod okuyordu

### Yeni Sistem (Doğru)
- ✅ **Desktop**: QR kod gösteriyor (Kilit Ekranı)
- ✅ **Web/Mobil**: QR kod okuyor (Anahtar)

## 🎯 Kullanım Akışı

```
1. Desktop Uygulaması Başlatılır
   └─> Tam ekran kilit + QR kod gösterir

2. Kullanıcı Telefonu Alır
   └─> Web'e giriş yapar (localhost:8080/login.html)
   
3. "Kilidi Aç" Butonuna Tıklar
   └─> Kamera açılır
   
4. Desktop'taki QR'ı Tarar
   └─> Backend doğrular
   
5. Kilit Açılır
   └─> Desktop 30 dakika açık kalır
   
6. Süre Bitince Otomatik Kilitlenir
   └─> Yeni QR kod oluşturulur
```

## 📱 Sayfalar

### Desktop (Python GTK)
- `tulpar_lock.py` - Tam ekran kilit + QR gösterici

### Web (HTML/JS)
- `register.html` - Kayıt
- `login.html` - Giriş
- `lock.html` - Ana sayfa (yönlendirme)
- `unlock.html` - **QR Tarayıcı** (Kamera ile)
- `profile.html` - Profil ayarları

## 🔧 API Değişiklikleri

### Yeni Endpoints

```javascript
// Desktop için QR oluşturma (auth gerektirmez)
GET /lock/desktop
Response: { qrCode, sessionId, expiresAt }

// Desktop'un kilit durumunu kontrol etmesi
GET /lock/status/:sessionId
Response: { unlocked: true/false, duration }

// Web'den QR okuyup kilidi açma (auth gerektirir)
POST /unlock
Headers: Authorization: Bearer <token>
Body: { sessionId }
Response: { unlocked: true, message }
```

## 🚀 Test Adımları

1. **Backend Başlat**
```bash
cd backend && npm start
```

2. **Frontend Başlat**
```bash
cd frontend && python3 -m http.server 8080
```

3. **Desktop Başlat**
```bash
cd desktop && python3 tulpar_lock.py
```
→ Tam ekran kilit + QR kod görünecek

4. **Telefondan/Tarayıcıdan**
- http://localhost:8080/register.html → Kayıt ol
- http://localhost:8080/login.html → Giriş yap
- http://localhost:8080/unlock.html → QR tarat
- Desktop'taki QR'ı göster
- ✅ Kilit açılacak!

## 📦 Değişen Dosyalar

- ✅ `backend/server.js` - API endpoints değişti
- ✅ `desktop/tulpar_lock.py` - QR gösterici oldu
- ✅ `frontend/unlock.html` - **YENİ** - QR tarayıcı
- ✅ `frontend/lock.html` - Ana sayfa oldu
- ✅ `frontend/style.css` - Yeni stiller
- ✅ `desktop/requirements.txt` - OpenCV/pyzbar kaldırıldı
- ✅ `install.sh` - Güncellendi

## 🎉 Sonuç

Artık sistem doğru çalışıyor:
- Desktop = Kilit (QR gösterir)
- Telefon/Web = Anahtar (QR okur)
