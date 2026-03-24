# Tulpar

Pardus Linux için oturum kilitleme ve bilgisayar kapatma yönetim sistemi.

Tulpar, belirlenen süre ve saat kurallarına göre kullanıcı oturumunu otomatik kapatır veya bilgisayarı kapatır. Tüm kullanıcılar için geçerli, sistem genelinde çalışır.

## Hızlı Kurulum

```bash
wget https://github.com/tulparstudyo/etap-timer/archive/refs/heads/main.zip -O tulpar.zip && unzip tulpar.zip && cd etap-timer-main && bash install.sh
```

## Özellikler

- **Oturum Süresi (SESSION_DURATION)** — Oturum açıldıktan sonra belirlenen dakika dolunca oturum kapatılır
- **Boşta Kalma Süresi (IDLE_DURATION)** — Kullanıcı işlem yapmazsa belirlenen dakika sonunda oturum kapatılır
- **Kapanma Saati (TURNOFF_TIME)** — Günün belirtilen saatinden (SS:DD) sonra bilgisayar otomatik kapanır. Kapanma saatinden sonra (örn. 16:30–23:59 arası) açılan oturumlarda tüm zamanlayıcılar devre dışı kalır
- Masaüstünde kalan süreyi gösteren sürüklenebilir sayaç penceresi
- Tüm kullanıcılar için otomatik başlatma (autostart)
- Ayarlar sistem genelinde `/etc/tulpar/tulpar.conf` dosyasında saklanır

## Gereksinimler

- Pardus Linux (veya Debian tabanlı dağıtım)
- XFCE masaüstü ortamı
- Python 3
- PyGObject (`python3-gi`, `gir1.2-gtk-3.0`)
- xprintidle

```bash
sudo apt install python3 python3-gi gir1.2-gtk-3.0 xprintidle
```

## Kurulum

### Doğrudan indirme ve kurulum

```bash
wget -qO- https://github.com/tulparstudyo/etap-timer/archive/refs/heads/main.tar.gz | tar xz && cd etap-timer-main && bash install.sh && cd .. && rm -rf etap-timer-main
```

### Git ile kurulum

```bash
git clone https://github.com/tulparstudyo/etap-timer.git
cd etap-timer
bash install.sh
```

Kurulum scripti şunları yapar:
- `tulpar_daemon.py` ve `tulpar_settings.py` dosyalarını `/usr/local/bin/` altına kopyalar
- `/etc/tulpar/tulpar.conf` konfigürasyon dosyasını oluşturur (yoksa)
- `/etc/xdg/autostart/` altına autostart dosyası ekler (tüm kullanıcılar için)
- Masaüstüne ayarlar kısayolu oluşturur

## Kaldırma

```bash
bash uninstall.sh
```

Konfigürasyon dosyasını da silmek için:
```bash
sudo rm -rf /etc/tulpar
```

## Kullanım

### Ayarlar

Masaüstündeki **Kapanma Ayarları** kısayoluna tıklayarak ayarlar penceresini açın. Değerleri girin ve kaydedin. Kaydetme işlemi `pkexec` ile yetki isteyecektir.

| Ayar | Açıklama | Örnek |
|------|----------|-------|
| Oturum Süresi | Oturum açık kalma süresi (dakika). 0 = devre dışı | 60 |
| Boşta Kalma Süresi | İşlem yapılmazsa oturumun kapanma süresi (dakika). 0 = devre dışı | 15 |
| Kapanma Saati | Bilgisayarın kapanacağı saat (SS:DD). Boş = devre dışı | 22:00 |

### Daemon

Daemon oturum açılınca otomatik başlar. Manuel başlatmak için:

```bash
/usr/local/bin/tulpar_daemon.py &
```

### Sayaç

Masaüstünün sağ alt köşesinde kalan süreyi SS:DD formatında gösteren küçük bir pencere belirir. Fare ile sürükleyerek konumunu değiştirebilirsiniz.

## Dosya Yapısı

```
/usr/local/bin/
├── tulpar_daemon.py            # Ana daemon
└── tulpar_settings.py          # Ayarlar penceresi

/etc/tulpar/
└── tulpar.conf                 # Sistem ayarları (root:root, 644)

/etc/xdg/autostart/
└── tulpar-daemon.desktop       # Tüm kullanıcılar için autostart

~/.config/tulpar/
└── tulpar.log                  # Kullanıcıya özel log dosyası
```

## Lisans

Bu proje açık kaynaklıdır.

## Ekran Görüntüsü
<img width="1920" height="921" alt="2026-03-23 20 00 23" src="https://github.com/user-attachments/assets/a67255bc-cc56-420a-852c-4a84b2d6d7de" />
