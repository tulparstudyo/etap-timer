---
inclusion: always
---

# Tulpar - Pardus Linux Oturum ve Kapatma Yönetim Sistemi

Tulpar, Pardus Linux için oturum kilitleme ve bilgisayar kapatma sistemidir.

## Proje Bilgileri

- Repo: https://github.com/tulparstudyo/etap-timer
- Kurulum: Konsol komutları ve wget ile kurulabilir

## Ayarlar Penceresi

Masaüstünde bir kısayol ile ayarlar penceresi açılır. Aşağıdaki değerler ayarlanır ve kaydedilir:

- **SESSION_DURATION** — Oturum açıldıktan sonra oturumun açık kalacağı süre (dakika)
- **IDLE_DURATION** — Herhangi bir işlem yapılmazsa oturumun açık kalabileceği süre (dakika)
- **TURNOFF_TIME** — Günün belirtilen saatinden (HH:MM) sonra bilgisayarın otomatik kapanacağı zaman

> Bu ayarlar yalnızca kurulumu yapan kullanıcı hesabından değiştirilebilir.

## Çalışma Davranışı

- Masaüstü uygulaması oturum açılınca otomatik başlar ve single instance olarak çalışır
- Oturum açılınca SESSION_DURATION sayacı başlar, süre dolunca oturum kapatılır
- Kullanıcı işlem yapmazsa IDLE_DURATION sayacı çalışır, süre dolunca oturum kapatılır
- Bilgisayar saati TURNOFF_TIME değerini geçerse bilgisayar sorgusuz ve onaysız kapanır
