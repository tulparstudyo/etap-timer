1. Genel Tanım

Tulpar, Pardus işletim sistemi üzerinde çalışan bir masaüstü kilit uygulamasıdır. Bu uygulama, ekran kilitlendiğinde kullanıcıya kilit.dosyamosya.com üzerinde çalışan bir web arayüzü sunar. Sistem, QR kod tabanlı doğrulama ve kullanıcı yetkilendirmesi ile güvenli bir kilit/açma mekanizması sağlar.

2. Masaüstü Uygulaması (Tulpar)

Pardus üzerinde çalışır ve ekranı kilitler.
Kilit ekranında kilit.dosyamosya.com/unlock adresi görüntülenir.
Kullanıcı, QR kod ile kimlik doğrulaması yaparak ekranı açabilir.
Açılan ekran belirli bir süre (x dakika) açık kalır, süre dolunca otomatik olarak yeniden kilitlenir.
3. Web Platformu (Node.js)

Web sitesi kilit.dosyamosya.com üzerinde çalışır ve aşağıdaki modülleri içerir:

Kayıt (Register):
Kullanıcılar kilit.dosyamosya.com/register üzerinden kayıt olabilir.
Kayıtta email, telefon ve kayıtlı kurumlardan birinin seçilmesi zorunludur.
Oturum Açma (Login):
kilit.dosyamosya.com/login üzerinden giriş yapılır.
Kullanıcılar kilit.dosyamosya.com/profile sayfasında email hariç diğer bilgilerini güncelleyebilir.
Kilit Ekranı (Lock):
kilit.dosyamosya.com/lock adresinde bir QR kod üretilir.
Bu QR kod, oturum açmış kullanıcı tarafından okutulur.
Kullanıcının ekran açma yetkisi kontrol edilir. Yetkili ise masaüstü ekranı belirlenen süre boyunca açılır.
4. Güvenlik ve Yetkilendirme

QR kod yalnızca oturum açmış kullanıcıya özeldir.
Yetki kontrolü web platformu üzerinden yapılır.
Süre bitiminde masaüstü otomatik olarak kilitlenir, böylece güvenlik sürekli sağlanır.
5. Beklenen Sonuçlar

Pardus kullanıcıları için güvenli, merkezi yönetilebilir bir ekran kilit sistemi.
Kurumlar için kullanıcı yetkilerini QR kod tabanlı doğrulama ile kontrol edebilme.
Kullanıcı dostu web arayüzü ile kayıt, giriş ve profil yönetimi.
