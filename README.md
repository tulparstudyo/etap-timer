# Tulpar

Pardus Linux için oturum kilitleme ve bilgisayar kapatma yönetim sistemi.

## Özellikler

- Oturum süresi dolunca otomatik oturum kapatma
- Boşta kalma süresine göre otomatik oturum kapatma
- Belirlenen saatten sonra otomatik bilgisayar kapatma
- Zenity tabanlı ayarlar penceresi
- Masaüstü kısayolu ile kolay erişim

## Kurulum

```bash
git clone https://github.com/tulparstudyo/etap-timer.git
cd etap-timer
chmod +x install.sh
./install.sh
```

Veya doğrudan wget ile:

```bash
wget -qO- https://raw.githubusercontent.com/tulparstudyo/etap-timer/main/install.sh | bash
```

## Kaldırma

```bash
chmod +x uninstall.sh
./uninstall.sh
```

## Ayarlar

Masaüstündeki "Tulpar Ayarları" kısayoluna tıklayarak ayarlar penceresini açabilirsiniz:

| Ayar | Açıklama |
|------|----------|
| SESSION_DURATION | Oturumun açık kalacağı süre (dakika) |
| IDLE_DURATION | Boşta kalma süresi (dakika) |
| TURNOFF_TIME | Otomatik kapanma saati (HH:MM) |

Ayarlar `~/.config/tulpar/tulpar.conf` dosyasında saklanır.

## Gereksinimler

- Pardus Linux / Debian tabanlı dağıtım
- zenity
- xprintidle
