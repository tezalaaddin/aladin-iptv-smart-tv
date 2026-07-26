# v2.3.0 +1 Sürüm Güncellemesi ve Dokümantasyon Planı

Bu plan, uygulamanın v2.3.0 sürümüne ait bilgilerin `SKILL.MD` dosyasına eklenmesini, uygulama içindeki sürüm bilgilerinin güncellenmesini ve GitHub senkronizasyonunu içerir.

## Kullanıcı İncelemesi Gerekenler

> [!IMPORTANT]
> - `SKILL.MD` dosyası v2.3.0 sürüm notlarıyla güncellenecek.
> - `README.md` dosyasındaki merge conflict (çakışma) işaretleri temizlenecek ve isimler "Aladin Media Player Pro TV" olarak standartlaştırılacak.
> - `local.properties` dosyasındaki sürüm bilgileri `2.3.0` ve `43` olarak güncellenecek.

## Yapılacak Değişiklikler

### Dokümantasyon

#### [MODIFY] [SKILL.MD](file:///D:/Development/Projects/aladin-iptv-smart-tv/SKILL.md)
- Frontmatter'daki `version` değeri `2.3.0+43` yapılacak.
- Metin içindeki eski sürüm referansları (2.0.0, 2.1.0 vb.) güncellenecek.
- Dosyanın sonuna "V2.3.0 +1 Sürüm Notları" eklenecek.

#### [MODIFY] [README.md](file:///D:/Development/Projects/aladin-iptv-smart-tv/README.md)
- Merge conflict işaretleri temizlenecek.
- Marka ismi "Aladin Media Player Pro TV" olarak güncellenecek.

### Konfigürasyon

#### [MODIFY] [local.properties](file:///D:/Development/Projects/aladin-iptv-smart-tv/android/local.properties)
- `flutter.versionName=2.3.0`
- `flutter.versionCode=43` olarak güncellenecek.

### GitHub Senkronizasyonu
- Değişiklikler commit edilecek (`docs: update versioning to v2.3.0`).
- GitHub'a push yapılacak.

## Doğrulama Planı

### Manuel Doğrulama
- `SKILL.MD` dosyasının doğru göründüğünün kontrolü.
- `README.md` dosyasının temizlendiğinin kontrolü.
- Uygulamanın "Hakkında" sayfasında `2.3.0 (43)` yazdığının (build sonrası) teyit edilmesi.
