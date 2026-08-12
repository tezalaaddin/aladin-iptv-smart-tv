# Uygulama Kalite ve Geliştirme Listesi

Bu liste özellikle düşük donanımlı Android TV cihazlarında akıcı oynatma,
kumanda kullanılabilirliği ve yayın güvenilirliği gözetilerek tutulur.

## Tamamlananlar

- **Tamamlandı:** TV kumandası için sağdan açılan, büyük hedefli ve odağı geri yükleyen ikincil oynatıcı paneli.
- **Tamamlandı:** Oynatıcı OSD'sinde aktif çözünürlük, ses dili ve altyazı durumunun görünür sunumu.
- **Tamamlandı:** Tanılamada kullanıcı dostu bağlantı özeti ile isteğe bağlı teknik ayrıntı ayrımı.
- **Tamamlandı:** 1-2 GB TV cihazlarında 16 MB sert medya buffer tavanı ve bellek öncelikli yükleme politikası.
- **Tamamlandı:** Oynatıcı kontrol ve sunum sorumluluklarının ayrı native sınıflara çıkarılması.

- **Tamamlandı:** Telefon, tablet ve yön tuşlu Android TV için merkezi cihaz profili.
- **Tamamlandı:** Yatay telefonların yanlışlıkla TV yan menüsüne geçmesini engelleyen navigasyon ayrımı.
- **Tamamlandı:** Mobil alt navigasyonun beş ana öğeye sadeleştirilmesi ve ek hedeflerin erişilebilir alt menüye taşınması.
- **Tamamlandı:** Native oynatıcıdaki görünür sabit metinlerin sekiz dilde çalışma zamanı lokalizasyonuna bağlanması.
- **Tamamlandı:** Native oynatıcı için ayrı portre kaynak düzeni ve döndürmede oynatma konumunun korunması.
- **Tamamlandı:** Sekme odak kapsamlarının hatırlanması ve D-pad otomatik odak testi.
- **Tamamlandı:** Kart EPG sorgularında TTL önbelleği, eşzamanlı sorgu sınırı ve yinelenen istek birleştirme.
- **Tamamlandı:** TMDB isteklerinde eşzamanlılık sınırı, dile özgü LRU ve negatif sonuç önbelleği.
- **Tamamlandı:** Ayarlar bileşenlerinin ayrı part dosyasına, native lokalizasyon ve buffer politikasının ayrı Kotlin dosyalarına çıkarılması.
- **Tamamlandı:** Telefon/TV profil, RTL golden, D-pad ve deterministik soak test paketi.

- **Tamamlandı:** Canlı TV kartları için Kompakt / Standart / Büyük görünüm seçimi.
- **Tamamlandı:** Kart boyutu değişikliklerinin açık ekranlara yeniden başlatmadan uygulanması.
- **Tamamlandı:** Oynatıcıda gerçek yayın sunucusu HTTP yanıt süresi.
- **Tamamlandı:** Tahmini bant genişliği, medya bitrate, çözünürlük, codec ve FPS bilgileri.
- **Tamamlandı:** Yeniden buffer sayısı, toplam buffer süresi ve hazır video süresi.
- **Tamamlandı:** Tanılama panelinde son oynatma hata kodu ve açıklaması.
- **Tamamlandı:** Media3 AnalyticsListener ile düşürülen video karelerinin ölçülmesi.
- **Tamamlandı:** Playlist bulunmayan ilk açılışta kurulum sihirbazına yönlendirme.
- **Tamamlandı:** Çoklu varyant HLS yayınlarında Media3 adaptif kalite seçimi; düşük
  bellek cihazlarında güvenli 720p sınırı ve tek kaliteli akışlara dokunmama davranışı.
- **Tamamlandı:** Sekiz dilde 199 temel anahtarı ARB başlangıç dosyalarına aktaran
  deterministik migration aracı ve dil anahtarı eşitliği kontrolü.
- **Tamamlandı:** Yeni ayar ve tanılama metinlerinin sekiz dilde karşılıkları.
- **Tamamlandı:** Lokalizasyon anahtarı ve TV kart ölçüsü otomatik testleri.
- **Tamamlandı:** Dikey oynatıcı kontrol metinlerinin taşmasını önleyen kompakt yerleşim.
- **Tamamlandı:** API 36 hedefi ve Android TV banner/simge derleme doğrulamaları.

## Eksik / sonraki çalışmalar

- **Kısmen tamamlandı:** Tüm eski çeviri matrislerinin Flutter ARB/gen-l10n sistemine
  taşınması. Sekiz dilin temel 199 anahtarı ARB olarak üretildi ve anahtar eşitliği
  doğrulandı. `v49-v52` çağrı noktalarının runtime geçişi ekran ekran yapılmalıdır.
- **Eksik:** Gerçek Android TV cihazında uzun süreli soak testi ve kumanda odak testi.
- **Eksik:** Built-in Kotlin geçişi. Kullanılan Flutter eklentilerinin tamamı yeni yapıyı
  desteklediğinde uygulanmalıdır; `package_info_plus`, `speech_to_text` ve
  `url_launcher_android` halen KGP uyguladığı için mevcut sürümde zorlamak derlemeyi bozabilir.
- **Eksik:** Farklı üreticilerde düşük bellek/decoder uyumluluk cihaz matrisi.

## Bu geliştirme turunun doğrulamaları

- **Tamamlandı:** Değiştirilen Dart dosyalarında statik analiz; yeni derleme hatası yok.
- **Tamamlandı:** Android release APK derlemesi; Kotlin ve kaynak bağlama başarılı.
- **Tamamlandı:** USB bağlı gerçek telefona release güncellemesi kurulumu.
- **Tamamlandı:** Telefonda uygulama başlatma, çalışan işlem ve FATAL/ANR log kontrolü.
- **Eksik:** `flutter test` çalıştırmasının bu sandbox içinde tamamlanması. Sistem Flutter
  SDK kilit dosyasına yazma izni vermiyor; çalışma alanı kopyasındaki eksik cache de
  Flutter aracının başlamasını engelliyor. Test kaynakları eklendi ve statik analizden geçti,
  ancak test koşusu normal kullanıcı terminalinde ayrıca çalıştırılmalıdır.
- **Eksik:** Telefon otomasyonunda kart boyutu ayarının görsel doğrulaması. Telefon yatay
  TV düzeninde senkronizasyon ekranında kaldığı için ayar satırına otomatik odaklanılamadı.
# Product completion follow-up

- [Tamamlandı] Android Automotive ve K2401 sınıfı direksiyon kumandalarında önceki/sonraki kanal kontrolü
- [Tamamlandı] Android Automotive ve K2401 sınıfı sabit araç ekranlarında uygulama genelinde yatay yön kilidi
- [Tamamlandı] Yatay tablet ve araç ekranlarında alt menü yerine TV tipi sol yan navigasyon
- [Tamamlandı] Tüm oynatma giriş noktalarında seçilen içeriğin kategori kuyruğunu merkezi olarak oluşturma
- [Tamamlandı] Canlı TV ve native kanal geçişleri dahil gerçek son izlenen içeriği başlangıçta oynatma
- [Tamamlandı] Hareketli araç ve kesintili mobil internet için bellek sınırlı Yolculuk buffer profili
- [Tamamlandı] Favoriler, ana sayfa rafları, arama, geçmiş ve oynatma kuyrukları için ortak mantıksal içerik kimliği
- [Tamamlandı] Dizi favorilerini tek karta indirme; oynatma sırasında sezon/bölüm ayrımını koruma
- [Tamamlandı] Alternatif URL ve HD/FHD/Yedek kaynaklarını veri silmeden tekilleştirme
- [Tamamlandı] Favori durumunu aynı içeriğin bütün kaynaklarına düşük bellekli, toplu taramayla uygulama
- [Tamamlandı] Film yeniden yapımlarını yıl bilgisiyle birbirinden ayırma
