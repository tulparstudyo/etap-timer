---
inclusion: always
---

# Tulpar - Proje Yapısı

## Dizin Yapısı

```
tulpar/
├── install.sh                  # Kurulum scripti
├── uninstall.sh                # Kaldırma scripti
├── tulpar-daemon.sh            # Ana daemon — zamanlayıcıları çalıştırır
├── tulpar-settings.sh          # Ayarlar penceresi (Zenity)
├── tulpar-settings.desktop     # Masaüstü kısayolu (ayarlar)
├── tulpar-daemon.desktop       # Autostart dosyası (daemon)
└── README.md                   # Proje dokümantasyonu
```

## Dosya Sorumlulukları

- `install.sh` — Dosyaları doğru konumlara kopyalar, autostart ve masaüstü kısayolunu oluşturur, gerekli paketleri kontrol eder
- `uninstall.sh` — Kurulumu geri alır, oluşturulan dosyaları temizler
- `tulpar-daemon.sh` — Oturum açılınca başlar; SESSION_DURATION, IDLE_DURATION ve TURNOFF_TIME sayaçlarını yönetir
- `tulpar-settings.sh` — Zenity ile ayarlar penceresini açar, `tulpar.conf` dosyasını okur/yazar
- `tulpar-settings.desktop` — Masaüstünde ayarlar kısayolu
- `tulpar-daemon.desktop` — `~/.config/autostart/` altına kopyalanır, oturum açılışında daemon'u başlatır

## Çalışma Zamanı Dosyaları

```
~/.config/tulpar/
├── tulpar.conf     # Kullanıcı ayarları (SESSION_DURATION, IDLE_DURATION, TURNOFF_TIME)
└── tulpar.log      # Çalışma logları
```

## Kurallar

- Proje kök dizininde gereksiz alt klasör oluşturulmamalı, yapı düz tutulmalı
- Her script tek bir sorumluluk taşımalı
- `.desktop` dosyaları freedesktop.org standartlarına uygun olmalı
