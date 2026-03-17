# Product Overview

Tulpar, Pardus Linux icin QR kod tabanli ekran kilitleme sistemidir. Web tabanli kimlik dogrulama ile guvenli masaustu kilitleme saglar.

## Core Functionality

- Masaustu uygulamasi ekrani kilitler ve QR kod gosterir
- Kullanicilar web arayuzu uzerinden QR kodu tarayarak kilidi acar
- Oturum tabanli kilit acma, yapilandirilabilir zaman asimi (varsayilan: 30 dk)
- Zaman asimi sonrasi otomatik yeniden kilitleme
- Offline kilit acma destegi (challenge-response, internet olmadan)

## User Flow

1. Kurum admin tarafindan sisteme eklenir ve aktiflestirilir
2. Kullanici web arayuzu uzerinden email, telefon ve kurum bilgisiyle kayit olur
3. Kurum panelinden kullaniciya kilit acma izni verilir
4. Masaustu uygulamasi kilitlendiginde benzersiz QR kod uretir
5. Kullanici mobil/web uzerinden QR kodu tarayarak kimlik dogrular
6. Masaustu yapilandirilan sure boyunca acilir
7. Sure dolunca sistem otomatik kilitlenir
8. Internet yoksa offline challenge kodu ile de acilabilir

## Key Features

- JWT tabanli kimlik dogrulama (kullanici, kurum, admin)
- Tek kullanimlik, zaman sinirli QR kodlar
- Kurum tabanli kullanici yonetimi
- Kurum paneli: kullanici listesi, kilit acma izni yonetimi
- Admin paneli: kurum aktivasyon/deaktivasyon, arama, sayfalama
- Profil yonetimi (telefon, kurum degisikligi)
- Sifre sifirlama (email ile)
- SMTP email bildirimleri (hos geldin, sifre sifirlama, yeni kayit)
- Offline kilit acma (HMAC-SHA256 challenge-response)
- Brute-force korumasi
- Il/ilce bazli kurum arama ve filtreleme
- Toplu kurum verisi aktarimi (MEB JSON)

## Target Users

Pardus Linux kullanan ve merkezi, guvenli ekran kilidi yonetimi ile mobil tabanli kimlik dogrulama ihtiyaci olan kurumlar (okullar, kamu kurumlari vb.).

## Roles

- **Kullanici**: Kayit olur, QR tarayarak kilit acar, profil yonetir
- **Kurum**: Kurum panelinden kullanicilari gorur, kilit acma izni verir/alir
- **Admin**: Kurumlari aktiflestirir/deaktif eder, sistem genelini yonetir
