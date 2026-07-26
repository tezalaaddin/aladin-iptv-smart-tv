# v2.3.0 Güncelleme, AAB Oluşturma ve GitHub Yayınlama Planı

Bu plan, uygulamanın versiyonunu yükseltmek, Android App Bundle (AAB) oluşturmak ve değişiklikleri GitHub'a göndermek için gerekli adımları içerir.

## Kullanıcı İncelemesi Gerekenler

> [!IMPORTANT]
> - Uygulama versiyonu `2.3.0+43` olarak güncellenecektir.
> - Yerel dizinde Git deposu bulunamadığı için yeni bir depo başlatılacak ve `https://github.com/tezalaaddin/aladin-media-player-pro-tv` adresine bağlanacaktır.
> - `flutter build appbundle` komutu çalıştırılacaktır. Bu işlem bilgisayarınızın performansına bağlı olarak birkaç dakika sürebilir.

## Yapılacak Değişiklikler

### Uygulama Versiyonu

#### [MODIFY] [pubspec.yaml](file:///D:/Development/Projects/aladin-iptv-smart-tv/pubspec.yaml)
- `version` değeri `2.2.0+42`'den `2.3.0+43`'e yükseltilecek.

### Derleme Süreci
- `flutter build appbundle` komutu ile üretim sürümü AAB dosyası oluşturulacak.

### GitHub ve Versiyon Kontrolü
- `git init` ile yerel depo başlatılacak (eğer yoksa).
- `git remote add origin https://github.com/tezalaaddin/aladin-media-player-pro-tv` ile uzak sunucu eklenecek.
- Değişiklikler commit edilecek.
- `v2.3.0` etiketi (tag) eklenecek.
- Kod ve etiketler GitHub'a gönderilecek.

## Doğrulama Planı

### Otomatik Testler
- AAB dosyasının `build/app/outputs/bundle/release/app-release.aab` konumunda oluşup oluşmadığının kontrolü.

### Manuel Doğrulama
- GitHub üzerindeki depoda yeni commit ve etiketin göründüğünün kontrolü.
