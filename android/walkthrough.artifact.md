# Target SDK 36 (Android 16) Güncellemesi Tamamlandı

Bu güncelleme ile uygulamanın hedef API düzeyi, Google Play Store'un yeni gereksinimlerine uygun olarak Android 16 (API 36) seviyesine yükseltilmiştir.

## Yapılan Değişiklikler

### Android Modülü

#### [build.gradle.kts](file:///D:/Development/Projects/aladin-iptv-smart-tv/android/app/build.gradle.kts)
- `compileSdk` değeri `35`'ten `36`'ya yükseltildi.
- `targetSdk` değeri `35`'ten `36`'ya yükseltildi.

> [!NOTE]
> Projenin ana `build.gradle.kts` dosyasında tüm alt projeler (kütüphaneler) için zaten SDK 36 zorlaması bulunduğu için ek bir merkezi işlem gerekmemiştir.

## Test ve Doğrulama
- SDK sürümleri dosyada doğru şekilde güncellendi.
- `minSdk` değeri korunarak eski sürüm uyumluluğu muhafaza edildi.

Uygulamanın yeni bir sürümünü (AAB) oluşturup Play Console'a yüklediğinizde uyarı mesajının kaybolması beklenmektedir.
