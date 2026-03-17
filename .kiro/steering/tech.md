---
inclusion: always
---

# Tulpar - Teknoloji ve Geliştirme Kuralları

## Platform

- Hedef işletim sistemi: Pardus Linux (Debian tabanlı)
- Masaüstü ortamı: XFCE (Pardus varsayılanı)

## Teknoloji Seçimleri

- Dil: Bash script (ana mantık ve servis yönetimi)
- Ayarlar arayüzü: Zenity (GTK tabanlı diyalog pencereleri)
- Zamanlayıcı: systemd timer veya cron
- Idle algılama: xprintidle
- Oturum yönetimi: xfce4-session-logout, loginctl
- Kapatma: systemctl poweroff

## Konfigürasyon

- Ayarlar dosyası: `~/.config/tulpar/tulpar.conf`
- Format: Bash source edilebilir key=value çiftleri
- Varsayılan değerler scriptte tanımlı olmalı, conf dosyası yoksa oluşturulmalı

## Kodlama Kuralları

- Tüm scriptler `#!/bin/bash` shebang ile başlamalı
- Değişken isimleri UPPER_SNAKE_CASE (ayarlar) ve lower_snake_case (yerel değişkenler)
- Hata durumları loglanmalı: `~/.config/tulpar/tulpar.log`
- Single instance kontrolü: lock dosyası veya `pgrep` ile sağlanmalı
- Scriptler POSIX uyumluluğa yakın tutulmalı, bash-specific özellikler gerektiğinde kullanılabilir

## Kurulum

- Kurulum scripti `install.sh` ile yapılmalı
- wget ile uzaktan indirme desteklenmeli
- Autostart için `~/.config/autostart/` altına `.desktop` dosyası oluşturulmalı
- Masaüstü kısayolu için `~/Masaüstü/` veya `~/Desktop/` altına `.desktop` dosyası oluşturulmalı
