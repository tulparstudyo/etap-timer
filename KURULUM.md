# Tulpar Kilit — Masaüstü Kurulum Kılavuzu

Bu kılavuz, Tulpar Kilit masaüstü uygulamasını kendi bilgisayarınıza kurup çalıştırmanız için gereken adımları anlatır.

> Tulpar Kilit, QR kod ile ekran kilitleme sistemidir. Masaüstü uygulaması ekranı kilitler ve bir QR kod gösterir; kullanıcı telefonuyla QR kodu okutarak kilidi açar.

---

## Hızlı Kurulum (Tek Komut)

Terminalde aşağıdaki komutu çalıştırın:

```bash
wget -qO kurulum.sh https://raw.githubusercontent.com/tulparstudyo/kilit/main/kurulum.sh && bash kurulum.sh
```

Script sizden kurum kodunu soracak, gerisini otomatik yapacaktır.

---

## Kurulum Ne Yapar?

- Uygulama `/opt/tulpar-kilit` dizinine kurulur
- Bu dizine sadece kurulumu yapan kullanıcı erişebilir (chmod 700)
- Uygulama tüm kullanıcılar için oturum açılışında otomatik başlar (`/etc/xdg/autostart/`)
- Yapılandırma dosyası: `/opt/tulpar-kilit/desktop/.env`

---

## Gereksinimler

- Pardus Linux veya Debian/Ubuntu tabanlı bir dağıtım
- Python 3.8+
- İnternet bağlantısı (kurulum ve QR doğrulama için)

---

## Manuel Kurulum

Otomatik script kullanmak istemezseniz adımlar:

### 1. Sistem bağımlılıklarını kurun

```bash
sudo apt-get update
sudo apt-get install -y python3-gi python3-gi-cairo gir1.2-gtk-3.0 python3-pip git
```

### 2. Projeyi indirin

```bash
sudo mkdir -p /opt/tulpar-kilit
sudo chown $(whoami):$(whoami) /opt/tulpar-kilit
sudo chmod 700 /opt/tulpar-kilit
git clone https://github.com/tulparstudyo/kilit.git /opt/tulpar-kilit
```

### 3. Python bağımlılıklarını kurun

```bash
pip3 install --break-system-packages -r /opt/tulpar-kilit/desktop/requirements.txt
```

### 4. Yapılandırma

`/opt/tulpar-kilit/desktop/.env` dosyasını oluşturun:

```env
API_URL=https://kilit.dosyamosya.com
INSTITUTION_CODE=KURUM_KODUNUZ
UNLOCK_DURATION=1
OFFLINE_SECRET=tulpar_offline_secret_change_in_production
INSTITUTION_NAME=Kurum Adınız
```

| Değişken | Açıklama |
|---|---|
| `API_URL` | Tulpar Kilit sunucu adresi |
| `INSTITUTION_CODE` | Kurumunuza ait kod (yöneticinizden alın) |
| `UNLOCK_DURATION` | Kilit açıldıktan sonra tekrar kilitlenme süresi (dakika) |
| `OFFLINE_SECRET` | Çevrimdışı kilit açma anahtarı (yöneticinizden alın) |
| `INSTITUTION_NAME` | Kilit ekranında görünecek kurum adı (opsiyonel) |

### 5. Tüm kullanıcılar için otomatik başlatma

```bash
sudo tee /etc/xdg/autostart/tulpar-kilit.desktop > /dev/null << 'EOF'
[Desktop Entry]
Type=Application
Name=Tulpar Kilit
Exec=/usr/bin/python3 /opt/tulpar-kilit/desktop/tulpar_lock.py
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Comment=Tulpar QR Kilit Sistemi
Icon=system-lock-screen
EOF
```

### 6. Uygulamayı çalıştırın

```bash
python3 /opt/tulpar-kilit/desktop/tulpar_lock.py
```

---

## Kilidi Açma

### QR Kod ile (Online)
1. Telefonunuzdan `https://kilit.dosyamosya.com/unlock.html` adresine gidin
2. Ekrandaki QR kodu taratın
3. Giriş yapın, kilit otomatik açılacaktır

### Çevrimdışı Mod
İnternet yoksa kilit ekranında bir "Kod" görünür:
1. Bu kodu kurum yöneticinize iletin
2. Aldığınız 6 haneli anahtarı "Unlock Key" alanına girin
3. "Aç" butonuna tıklayın

---

## Kaldırma

```bash
sudo rm -rf /opt/tulpar-kilit
sudo rm -f /etc/xdg/autostart/tulpar-kilit.desktop
sudo rm -f /etc/systemd/system/tulpar-kilit@.service
```

---

## Sorun Giderme

| Sorun | Çözüm |
|---|---|
| `ModuleNotFoundError: No module named 'gi'` | `sudo apt-get install python3-gi python3-gi-cairo gir1.2-gtk-3.0` |
| `ModuleNotFoundError: No module named 'requests'` | `pip3 install requests` |
| QR kod oluşturulamıyor | İnternet bağlantınızı ve `API_URL` değerini kontrol edin |
| Uygulama açılmıyor | `python3 /opt/tulpar-kilit/desktop/tulpar_lock.py` ile terminalde çalıştırıp hatayı görün |
