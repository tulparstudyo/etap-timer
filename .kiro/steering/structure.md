---
inclusion: always
---

# Tulpar - Proje Yapısı

## Dizin Yapısı

```
tulpar/
├── install.sh                  # Kurulum scripti (bash)
├── uninstall.sh                # Kaldırma scripti (bash)
├── tulpar_daemon.py            # Ana daemon — zamanlayıcıları çalıştırır
├── tulpar_settings.py          # Ayarlar penceresi (GTK 3 / PyGObject)
├── tulpar-settings.desktop     # Masaüstü kısayolu (ayarlar)
├── tulpar-daemon.desktop       # Autostart dosyası (daemon)
└── README.md                   # Proje dokümantasyonu
```

## Dosya Sorumlulukları

- `install.sh` — Dosyaları doğru konumlara kopyalar, autostart ve masaüstü kısayolunu oluşturur, gerekli paketleri kontrol eder
- `uninstall.sh` — Kurulumu geri alır, oluşturulan dosyaları temizler
- `tulpar_daemon.py` — Oturum açılınca başlar; SESSION_DURATION, IDLE_DURATION ve TURNOFF_TIME sayaçlarını yönetir, masaüstünde kalan süreyi gösteren overlay sayaç penceresi sunar, oturum kapanışında temiz şekilde sonlanır
- `tulpar_settings.py` — PyGObject/GTK 3 ile ayarlar penceresini açar, `tulpar.conf` dosyasını okur/yazar
- `tulpar-settings.desktop` — Masaüstünde ayarlar kısayolu
- `tulpar-daemon.desktop` — `~/.config/autostart/` altına kopyalanır, oturum açılışında daemon'u başlatır

## Çalışma Zamanı Dosyaları

```
/etc/tulpar/
└── tulpar.conf     # Sistem ayarları (SESSION_DURATION, IDLE_DURATION, TURNOFF_TIME)
                    # Sahiplik: root:root, izin: 644
                    # Tüm kullanıcılar okuyabilir, değiştirmek için sudo gerekir

~/.config/tulpar/
└── tulpar.log      # Çalışma logları (kullanıcıya özel)
```

## Kurallar

- Proje kök dizininde gereksiz alt klasör oluşturulmamalı, yapı düz tutulmalı
- Her Python dosyası tek bir sorumluluk taşımalı
- `.desktop` dosyaları freedesktop.org standartlarına uygun olmalı
