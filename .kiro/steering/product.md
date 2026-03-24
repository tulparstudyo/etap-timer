---
inclusion: always
---

# Tulpar - Pardus Linux Oturum ve Kapatma Yönetim Sistemi

Tulpar, Pardus Linux için Python 3 ve GTK 3 tabanlı oturum kilitleme ve bilgisayar kapatma sistemidir.

## Proje Bilgileri

- Repo: https://github.com/tulparstudyo/etap-timer
- Kurulum: Konsol komutları ve wget ile kurulabilir
- Dil: Python 3
- GUI: PyGObject (GTK 3)

## Ayarlar Penceresi

Masaüstünde bir kısayol ile ayarlar penceresi açılır. Aşağıdaki değerler ayarlanır ve kaydedilir:

- **SESSION_DURATION** — Oturum açıldıktan sonra oturumun açık kalacağı süre (dakika)
- **IDLE_DURATION** — Herhangi bir işlem yapılmazsa oturumun açık kalabileceği süre (dakika)
- **TURNOFF_TIME** — Günün belirtilen saatinden (HH:MM) sonra bilgisayarın otomatik kapanacağı zaman

> Bu ayarlar `/etc/tulpar/tulpar.conf` dosyasında saklanır. Tüm kullanıcılar okuyabilir, değiştirmek için sudo yetkisi gerekir.

## Çalışma Davranışı

- Masaüstü uygulaması oturum açılınca otomatik başlar ve single instance olarak çalışır
- Aynı anda birden fazla instance çalışamaz (lock dosyası ile kontrol)
- Kullanıcı oturumu kapattığında uygulama otomatik olarak kill edilmeli (SIGTERM/SIGHUP sinyallerini yakalamalı)
- Oturum açılınca SESSION_DURATION sayacı başlar, süre dolunca oturum kapatılır
- Kullanıcı işlem yapmazsa IDLE_DURATION sayacı çalışır, süre dolunca oturum kapatılır
- Bilgisayar saati TURNOFF_TIME değerini geçerse bilgisayar sorgusuz ve onaysız kapanır
- TURNOFF_TIME sonrası bypass: Daemon, TURNOFF_TIME saatinden sonra başlatıldıysa (aynı gün içinde, yani TURNOFF_TIME ile 23:59 arası) tüm zamanlayıcılar (SESSION_DURATION, IDLE_DURATION, TURNOFF_TIME) devre dışı kalır. Bu sayede kapatma saatinden sonra yapılan oturum açılışlarında kısıtlama uygulanmaz.

## Masaüstü Sayacı

- Masaüstünde kalan süreyi SS:DD (saat:dakika) formatında gösteren küçük bir sayaç penceresi bulunur
- Sayaç her dakika güncellenir
- Sayaç her zaman üstte (always-on-top) ve dekorasyon olmadan gösterilir
- Aktif sayaçlardan (SESSION_DURATION, IDLE_DURATION, TURNOFF_TIME) en yakın olanının kalan süresi gösterilir
