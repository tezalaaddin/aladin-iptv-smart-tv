import 'package:flutter/foundation.dart';

/// AladinManualLogos — GitHub üzerinde barındırılan TV kanal logoları.
///
/// Logolar `aladinTVLogos` reposunun ana dizinindedir (root).
/// Uygulama boyutu küçültülmüş ve logolar dinamik hale getirilmiştir.
///
/// Öncelik sırası (ChannelCard içinde):
///   1. Playlist logoUrl — M3U'dan gelen URL (varsa)
///   2. GitHub logo (bu dosya) — M3U'da logo yoksa devreye girer
///
/// Eşleştirme mantığı:
///   Kanal adı / tvg-id normalize edilir (küçük harf, alfanümerik):
///     "beIN Sports 1" → "beinsports1" → .../beinsportshd1.webp
///     "KANAL D"       → "kanald"      → .../kanald.webp
class AladinManualLogos {
  AladinManualLogos._();

  static const String _base = 'https://raw.githubusercontent.com/tezalaaddin/aladinTVLogos/main/';

  // ─── Dosya adı haritası: normalize_key → webp dosya adı ────────────────
  static const Map<String, String> _files = {
    '24': '24.webp',
    'a2tv': 'a2tv.webp',
    'ahabertv': 'ahabertv.webp',
    'ahaber': 'ahabertv.webp',
    'akittv': 'akittv.webp',
    'aksutv': 'aksutv.webp',
    'altastv': 'altastv.webp',
    'anadoluajansi': 'anadoluajansi.webp',
    'arastv': 'arastv.webp',
    'aspor': 'aspor.webp',
    'astv': 'astv.webp',
    'aturk': 'aturk.webp',
    'atv': 'atv.webp',
    'atvalanya': 'atvalanya.webp',
    'atvavrupa': 'atvavrupa.webp',
    'babytv': 'babytv.webp',
    'beinhaber': 'beinhaber.webp',
    'beinsports1': 'beinsportshd1.webp',
    'beinsports2': 'beinsportshd2.webp',
    'beinsports3': 'beinsportshd3.webp',
    'beinsports4': 'beinsportshd4.webp',
    'beinsports5': 'beinsportshd4.webp', // 5 için ayrı dosya yok, 4 kullan
    'beinsportshd1': 'beinsportshd1.webp',
    'beinsportshd2': 'beinsportshd2.webp',
    'beinsportshd3': 'beinsportshd3.webp',
    'beinsportshd4': 'beinsportshd4.webp',
    'beinsportsmax': 'beinsportsmax1.webp',
    'beinsportsmax1': 'beinsportsmax1.webp',
    'beinsportsmax2': 'beinsportsmax2.webp',
    'beinconnect': 'beinsportshd1.webp',
    'benguturk': 'benguturk.webp',
    'berattv': 'berattv.webp',
    'beyaztv': 'beyaztv.webp',
    'bht': 'bht.webp',
    'bircsatranc': 'bircsatranc.webp',
    'birtv': 'birtv.webp',
    'bizimevtv': 'bizimevtv.webp',
    'bloomberght': 'bloomberght.webp',
    'brt1': 'brt1hd.webp',
    'brt1hd': 'brt1hd.webp',
    'brt2': 'brt2.webp',
    'brt3': 'brt3.webp',
    'brtv': 'brtv.webp',
    'bursatv': 'bursatv.webp',
    'cantv': 'cantv.webp',
    'cartoonnetwork': 'cartoonnetwork.webp',
    'caytv': 'caytv.webp',
    'cekmekoywebtv': 'cekmekoywebtv.webp',
    'cgrt': 'cgrt.webp',
    'cgtndocumentary': 'cgtndocumentary.webp',
    'channelone': 'channelone.webp',
    'ciftcitv': 'ciftcitv.webp',
    'cine1': 'cine1.webp',
    'cine5': 'cine5.webp',
    'cine6': 'cine6.webp',
    'cnnturk': 'cnnturk.webp',
    'cnnt': 'cnnturk.webp',
    'dehatv': 'dehatv.webp',
    'denizpostasitv': 'denizpostasitv.webp',
    'dha': 'dha.webp',
    'dimtv': 'dimtv.webp',
    'disneychannel': 'disneychannel.webp',
    'disneyjr': 'disneyjr.webp',
    'disneyjunior': 'disneyjr.webp',
    'diyanettv': 'diyanettv.webp',
    'diyartv': 'diyartv.webp',
    'dosttv': 'dosttv.webp',
    'dreamturk': 'dreamturk.webp',
    'ebatvilkokul': 'ebatv_ilkokul.webp',
    'ebatvlise': 'ebatv_lise.webp',
    'ekanal': 'ekanal.webp',
    'ekoltv': 'ekoltv.webp',
    'ertv': 'ertv.webp',
    'erzurumtv': 'erzurumtv.webp',
    'estv': 'estv.webp',
    'etvtv': 'etvtv.webp',
    'eurod': 'eurod.webp',
    'eurosport1': 'eurospor1.webp',
    'eurosport2': 'eurospor2.webp',
    'eurospor1': 'eurospor1.webp',
    'eurospor2': 'eurospor2.webp',
    'eurostar': 'eurostar.webp',
    'exxen': 'exxen.webp',
    'fbtv': 'fbtv.webp',
    'finansturk': 'finansturk.webp',
    'finesttv': 'finesttv.webp',
    'flashhaber': 'flashhaber.webp',
    'flashhabert': 'flashhaber.webp',
    'flash': 'flashhaber.webp',
    'flashtv': 'flashtv.webp',
    'fox': 'fox.webp',
    'foxtv': 'fox.webp',
    'fx': 'fx.webp',
    'genctv': 'genctv.webp',
    'gstv': 'gstv.webp',
    'galatasaraytv': 'gstv.webp',
    'gtv': 'gtv.webp',
    'gunestv': 'gunestv.webp',
    'gzt': 'gzt.webp',
    'haber360': 'haber360.webp',
    'haber61': 'haber61.webp',
    'haberglobal': 'haberglobal.webp',
    'globalhaber': 'haberglobal.webp',
    'haberturk': 'haberturk.webp',
    'habertrk': 'haberturk.webp',
    'halktv': 'halk-tv.webp',
    'halk': 'halk-tv.webp',
    'history': 'history.webp',
    'historychannel': 'history.webp',
    'htspor': 'htspor.webp',
    'htsportv': 'htspor.webp',
    'hunat': 'hunat.webp',
    'iceltv': 'iceltv.webp',
    'imamhusseintv': 'imamhusseintv.webp',
    'inattv': 'inattv.webp',
    'isimtv': 'isimtv.webp',
    'justinsports': 'justinsports.webp',
    'kanal12': 'kanal12.webp',
    'kanal15': 'kanal15.webp',
    'kanal23': 'kanal23.webp',
    'kanal24': 'kanal24.webp',
    'kanal26': 'kanal26.webp',
    'kanal3': 'kanal3.webp',
    'kanal32': 'kanal32.webp',
    'kanal33': 'kanal33.webp',
    'kanal34': 'kanal34.webp',
    'kanal38': 'kanal38.webp',
    'kanal58': 'kanal58.webp',
    'kanal68': 'kanal68.webp',
    'kanal7': 'kanal7-.webp',
    'kanal7eu': 'kanal7eu.webp',
    'kanalavrupa': 'kanalavrupa.webp',
    'kanalb': 'kanalb.webp',
    'kanald': 'kanald.webp',
    'kanaldeuro': 'kanaldeuro.webp',
    'kanaldeuropa': 'kanaldeuro.webp',
    'kanaldrama': 'kanaldrama.webp',
    'kanale': 'kanale.webp',
    'kanalfirat': 'kanalfirat.webp',
    'kanalv': 'kanalv.webp',
    'kanalyeni': 'kanalyeni.webp',
    'kanalz': 'kanalz.webp',
    'kaytv': 'kaytv.webp',
    'kentturk': 'kentturk.webp',
    'konyaolaytv': 'konyaolaytv.webp',
    'kralpoptv': 'kralpoptv.webp',
    'kralpop': 'kralpoptv.webp',
    'krt': 'krt.webp',
    'krttv': 'krt.webp',
    'ktv': 'ktv.webp',
    'kudustv': 'kudustv.webp',
    'lalegultv': 'lalegultv.webp',
    'lifetvhd': 'lifetvhd.webp',
    'linetv': 'linetv.webp',
    'lovenature': 'lovenature.webp',
    'mavitv': 'mavitv.webp',
    'mctv': 'mctv.webp',
    'meltemtv': 'meltemtv.webp',
    'mercantv': 'mercantv.webp',
    'metropol': 'metropol.webp',
    'milyontv': 'milyontv.webp',
    'minikago': 'minika-go.webp',
    'minika': 'minika-go.webp',
    'minikacocuk': 'minikacocuk.webp',
    'moviesmarthd': 'moviesmarthd.webp',
    'moviesmart': 'moviesmarthd.webp',
    'mturktv': 'mturktv.webp',
    'myzentv': 'myzentv.webp',
    'natgeo': 'natgeo.webp',
    'natgeowild': 'natgeowild.webp',
    'nationalgeographic': 'natgeo.webp',
    'nickelodeon': 'nickelodeon.webp',
    'nickjr': 'disneyjr.webp',
    'nicktoons': 'nicktoons.webp',
    'nowtv': 'nowtv.webp',
    'now': 'nowtv.webp',
    'nr1': 'nr1.webp',
    'nr1ask': 'nr1ask.webp',
    'nr1damar': 'nr1damar.webp',
    'nr1dance': 'nr1dance.webp',
    'nr1turkhd': 'nr1turkhd.webp',
    'ntv': 'ntv.webp',
    'nurtv': 'nurtv.webp',
    'olayturk': 'olayturk.webp',
    'on4': 'on4.webp',
    'on6': 'on6.webp',
    'ontv': 'ontv.webp',
    'powerdance': 'powerdance.webp',
    'powerhd': 'powerhd.webp',
    'powerlove': 'powerlove.webp',
    'powerslow': 'powerslow.webp',
    'powerturk': 'powerturk.webp',
    'powerturkakustik': 'powerturkakustik.webp',
    'powerturktaptaze': 'powerturktaptaze.webp',
    'rtbaneka': 'rtbaneka.webp',
    'rtgtv': 'rtgtv.webp',
    'sat7turk': 'sat7turk.webp',
    'selcuksports': 'selcuksports.webp',
    'semerkandtv': 'semerkandtv.webp',
    'showmaxtr': 'showmaxtr.webp',
    'showturk': 'showturk.webp',
    'showtv': 'showtv.webp',
    'show': 'showtv.webp',
    'smartspor2': 'smartspor2.webp',
    'sozcutv': 'sozcutv.webp',
    'sozcu': 'sozcutv.webp',
    'sporsmart': 'sporsmart.webp',
    'sportsmart': 'sporsmart.webp',
    'sportstv': 'sportstv.webp',
    'ssport': 'ssport.webp',
    'ssport1': 'ssport.webp',
    'ssport2': 'ssport.webp', // ssport2 için ayrı yok
    'startv': 'startv.webp',
    'star': 'startv.webp',
    'suntv': 'suntv.webp',
    'superturk': 'superturk.webp',
    'tabii1': 'tabii1.webp',
    'tabii2': 'tabii2.webp',
    'tabii3': 'tabii3.webp',
    'tabii4': 'tabii4.webp',
    'tabii5': 'tabii5.webp',
    'tabii6': 'tabii6.webp',
    'tabii': 'tabii1.webp',
    'tabiispor': 'tabiispor6.webp',
    'tabiispor6': 'tabiispor6.webp',
    'tarihtv': 'tarihtv.webp',
    'tarimtv': 'tarimtv.webp',
    'tatlisestv': 'tatlisestv.webp',
    'tele1': 'tele1.webp',
    'tempotv': 'tempotv.webp',
    'teve2': 'teve2.webp',
    'tgrtbelgesel': 'tgrtbelgesel.webp',
    'tgrteu': 'tgrteu.webp',
    'tgrthaber': 'tgrthaber.webp',
    'tgrt': 'tgrthaber.webp',
    'tivibu': 'tivibusp1.webp',
    'tivibu2': 'tivibu2.webp',
    'tivibu3': 'tivibu3.webp',
    'tivibu4': 'tivibu4.webp',
    'tivibuspor': 'tivibusp1.webp',
    'tivibusp1': 'tivibusp1.webp',
    'tiviturk': 'tiviturk.webp',
    'tlc': 'tlc.webp',
    'tontv': 'tontv.webp',
    'topraktv': 'topraktv.webp',
    'trabzonbb': 'trabzonbb.webp',
    'trakyturk': 'trakyturk.webp',
    'trthaber': 'trthaber.webp',
    'trt1': 'trt1.webp',
    'trt2': 'trt2.webp',
    'trt3': 'trt3.webp',
    'trt3trtspor': 'trtspor.webp',
    'trt4k': 'trt4k.webp',
    'trtavaz': 'trtavaz.webp',
    'trtbelgesel': 'trtbelgesel.webp',
    'trtcocuk': 'trtcocuk.webp',
    'trtdiyanetcocuk': 'trtdiyanetcocuk.webp',
    'trteba': 'trteba.webp',
    'trtkurdi': 'trtkurdi.webp',
    'trtmuzik': 'trtmuzik.webp',
    'trtspor': 'trtspor.webp',
    'trtspor2': 'trtspor2.webp',
    'trtsporyildiz': 'trtsporyildiz.webp',
    'trtturk': 'trtturk.webp',
    'trtworld': 'trtworld.webp',
    'turkhaber': 'turkhaber.webp',
    'turkmax': 'turkmax.webp',
    'tvnet': 'tv-net.webp',
    'tvnetwork': 'tv-net.webp',
    'tv1': 'tv1.webp',
    'tv100': 'tv100.webp',
    'tv2020': 'tv2020.webp',
    'tv264': 'tv264.webp',
    'tv360': 'tv360.webp',
    'tv38': 'tv38.webp',
    'tv41': 'tv41.webp',
    'tv52': 'tv52.webp',
    'tv8': 'tv8.webp',
    'tv85': 'tv85.webp',
    'tv8int': 'tv8int.webp',
    'tv8international': 'tv8int.webp',
    'tvden': 'tvden.webp',
    'ulketv': 'ulketv.webp',
    'ulke': 'ulketv.webp',
    'ulusaltv': 'ulusaltv.webp',
    'ulusalkanal': 'ulusaltv.webp',
    'universitetv': 'universitetv.webp',
    'urfanatiktv': 'urfanatiktv.webp',
    'urmiatv': 'urmiatv.webp',
    'varsport': 'varsport.webp',
    'vavtv': 'vavtv.webp',
    'viasatexplore': 'viasatexplore.webp',
    'vizyon58': 'vizyon58.webp',
    'websport': 'websport.webp',
    'womantv': 'womantv.webp',
    'xyzsport': 'xyzsport.webp',
  };

  // ── Public API ────────────────────────────────────────────────

  /// Kanal için remote logo URL döndürür. Bulunamazsa null.
  /// `CachedNetworkImage(imageUrl: url)` ile kullanılır.
  static String? urlFor(String channelName, String? tvgId) {
    String? result;
    
    // 1. tvg-id ile tam eşleşme
    if (tvgId != null && tvgId.isNotEmpty) {
      final file = _files[_norm(tvgId)];
      if (file != null) result = '$_base$file';
    }
    
    // 2. Kanal adı ile eşleşme
    if (result == null) {
      final key = _norm(channelName);
      final file = _files[key];
      if (file != null) result = '$_base$file';
    }

    // 3. Kısmi eşleşme
    if (result == null) {
      final key = _norm(channelName);
      for (final entry in _files.entries) {
        if (key.length < 3 || entry.key.length < 3) continue;
        if (key.contains(entry.key) || entry.key.contains(key)) {
          result = '$_base${entry.value}';
          break;
        }
      }
    }

    return result;
  }

  /// Debug: Kanal için aranan normalize key'i döndürür.
  /// ChannelCard'ın debug placeholder'ında gösterilir.
  static String debugKeyFor(String channelName, String? tvgId) {
    final nameKey = _norm(channelName);
    if (tvgId != null && tvgId.isNotEmpty) {
      final idKey = _norm(tvgId);
      return 'id:$idKey / ad:$nameKey';
    }
    return 'ad:$nameKey';
  }

  // ── Normalizer ────────────────────────────────────────────────

  static String _norm(String raw) {
    var s = raw.trim();
    s = s.replaceAll(RegExp(r'@\S+$'), '');
    s = s.replaceAll(RegExp(r'\s*[\(\[\{][^\)\]\}]*[\)\]\}]'), '');
    s = s.replaceAll(RegExp(r'^[A-Za-z]{1,6}\s*[|:]\s*'), '');
    s = s.replaceAll(RegExp(r'\.[a-zA-Z]{2,3}$'), '');
    s = s.replaceAll(
      RegExp(r'\b(4K|UHD|FHD|1080[PpIi]|HD\+?|720[Pp]|SD|HEVC)\b',
          caseSensitive: false),
      '',
    );
    const tr = {
      'İ': 'I',
      'ı': 'i',
      'Ş': 'S',
      'ş': 's',
      'Ğ': 'G',
      'ğ': 'g',
      'Ü': 'U',
      'ü': 'u',
      'Ö': 'O',
      'ö': 'o',
      'Ç': 'C',
      'ç': 'c',
    };
    for (final e in tr.entries) {
      s = s.replaceAll(e.key, e.value);
    }
    return s.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  }
}
