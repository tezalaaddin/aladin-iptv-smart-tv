import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/state/aladin_app_state.dart';
import '../../shared/theme/aladin_app_theme.dart';

class AladinHelpTopic {
  const AladinHelpTopic(this.icon, this.title, this.summary, this.steps);
  final IconData icon;
  final String title;
  final String summary;
  final List<String> steps;
}

class AladinHelpCatalog {
  static const supportedLanguages = [
    'tr',
    'en',
    'de',
    'fr',
    'es',
    'ru',
    'zh',
    'ar'
  ];

  static Map<String, String> labels(String language) {
    const data = {
      'tr': [
        'Kullanım Rehberi',
        'Özellik veya işlem ara',
        'Kumanda',
        'OK: Seç',
        'Uzun OK: Seçenekler',
        'Geri: Önceki ekran',
        'Konu bulunamadı'
      ],
      'en': [
        'User Guide',
        'Search features or actions',
        'Remote control',
        'OK: Select',
        'Hold OK: Options',
        'Back: Previous screen',
        'No topic found'
      ],
      'de': [
        'Benutzerhandbuch',
        'Funktion oder Aktion suchen',
        'Fernbedienung',
        'OK: Auswählen',
        'OK halten: Optionen',
        'Zurück: Vorheriger Bildschirm',
        'Kein Thema gefunden'
      ],
      'fr': [
        "Guide d’utilisation",
        'Rechercher une fonction',
        'Télécommande',
        'OK : Sélectionner',
        'OK long : Options',
        'Retour : Écran précédent',
        'Aucun sujet trouvé'
      ],
      'es': [
        'Guía de uso',
        'Buscar función o acción',
        'Mando a distancia',
        'OK: Seleccionar',
        'OK largo: Opciones',
        'Atrás: Pantalla anterior',
        'No se encontró ningún tema'
      ],
      'ru': [
        'Руководство пользователя',
        'Поиск функции или действия',
        'Пульт',
        'OK: выбрать',
        'Удерживать OK: параметры',
        'Назад: предыдущий экран',
        'Раздел не найден'
      ],
      'zh': [
        '使用指南',
        '搜索功能或操作',
        '遥控器',
        'OK：选择',
        '长按 OK：选项',
        '返回：上一页',
        '未找到相关主题'
      ],
      'ar': [
        'دليل الاستخدام',
        'ابحث عن ميزة أو إجراء',
        'جهاز التحكم',
        'موافق: تحديد',
        'ضغط مطول: خيارات',
        'رجوع: الشاشة السابقة',
        'لم يتم العثور على موضوع'
      ],
    };
    final v = data[language] ?? data['en']!;
    return {
      'title': v[0],
      'search': v[1],
      'remote': v[2],
      'ok': v[3],
      'hold': v[4],
      'back': v[5],
      'empty': v[6]
    };
  }

  static List<AladinHelpTopic> topics(String language) {
    final lang = supportedLanguages.contains(language) ? language : 'en';
    final source = _localized[lang]!;
    return List.generate(
        _icons.length,
        (i) => AladinHelpTopic(
            _icons[i], source[i][0], source[i][1], source[i].skip(2).toList()));
  }

  static const _icons = <IconData>[
    Icons.rocket_launch_outlined,
    Icons.settings_input_antenna,
    Icons.home_outlined,
    Icons.live_tv_outlined,
    Icons.movie_filter_outlined,
    Icons.grid_view_rounded,
    Icons.play_circle_outline,
    Icons.favorite_border,
    Icons.search,
    Icons.child_care_outlined,
    Icons.tune,
    Icons.backup_outlined,
    Icons.update,
    Icons.health_and_safety_outlined,
  ];

  // Each entry: title, summary, then actionable steps. Kept beside the UI so
  // the guide always ships offline and follows the selected app language.
  static const Map<String, List<List<String>>> _localized = {
    'tr': [
      [
        'Hızlı başlangıç',
        'İlk kurulumdan izlemeye üç adımda başlayın.',
        'Ayarlar > Yeni Oynatma Listesi Ekle bölümünü açın.',
        'M3U URL, Xtream Codes veya cihazdaki yerel M3U dosyasını seçin.',
        'Bilgileri kaydedip “Şimdi etkinleştir” seçeneğini onaylayın. Uygulama içerikleri otomatik sınıflandırır.',
        'Uygulama içerik sağlamaz; yalnızca size ait yasal oynatma listeleriyle çalışır.'
      ],
      [
        'Liste ekleme ve yönetim',
        'M3U, Xtream ve yerel listelerinizi yönetin.',
        'Sunucu alanında http:// hazır gelir; kısayol düğmeleriyle https://, .com ve yaygın portları ekleyebilirsiniz.',
        'Kayıtlı listeyi etkinleştirebilir, yenileyebilir, yeniden adlandırabilir, sağlık raporunu açabilir veya silebilirsiniz.',
        'Liste yenileme favorileri ve izleme durumunu korur. Xtream parolası güvenli depolamada tutulur.'
      ],
      [
        'Ana Sayfa',
        'Kişisel raflar ve kaldığınız yerden devam.',
        'Kaldığınız Yerden, Favoriler, Yeni Eklenenler, En Sık İzlenenler, Film, Dizi ve Keşfet raflarında D-pad ile gezin.',
        'Bir karta OK ile girin; uzun OK ile favori, kilit, gizleme ve kanal profili seçeneklerini açın.',
        'Ana sayfa özelleştirmesinden rafları açıp kapatabilir ve sıralarını değiştirebilirsiniz.'
      ],
      [
        'Canlı TV ve EPG',
        'Kanallar, şimdi/sonraki bilgisi ve program rehberi.',
        'Kategori satırlarında sağ/sol, satırlar arasında yukarı/aşağı ile ilerleyin; OK kanalı açar.',
        'EPG işareti program rehberini açar. Günler arasında geçebilir ve ortak zaman çizelgesini yatay kaydırabilirsiniz.',
        'Kanal kartında uzun OK; favori, kilit, gizleme, decoder ve kalite profilini açar.'
      ],
      [
        'Filmler ve Diziler',
        'Afişler, sezonlar ve izleme ilerlemesi.',
        'Film kartında OK oynatır. Dizi kartında OK sezon ve bölüm ekranını açar.',
        'Yarım kalan film ve bölümler Kaldığınız Yerden rafına eklenir; tamamlananlar bu raftan çıkar.',
        'Afiş, özet ve puanlar TMDB anahtarı kullanılabildiğinde arka planda zenginleştirilir.'
      ],
      [
        'Kategoriler',
        'Binlerce içerik arasında doğrudan geçiş.',
        'Canlı TV, Film veya Dizi ekranında üstteki Tüm Kategoriler düğmesini açın.',
        'Panelde arama yapın; kategori yanındaki sayı o bölümdeki içerik miktarıdır.',
        'Uzun OK kategoriyi sabitler. Son açılan beş kategori otomatik hatırlanır.',
        'Gizlenenleri Yönet ile gizli kategori ve içerikleri geri getirebilirsiniz.'
      ],
      [
        'Oynatıcı ve kumanda',
        'Yayın sırasında tüm temel kontroller.',
        'OK oynatıcı menüsünü; Geri önce açık paneli, sonra oynatıcıyı kapatır.',
        'Yukarı/aşağı canlı kanalı değiştirir. Sağ/sol VOD içeriğinde ileri/geri sarar.',
        'Menüden kanal listesi, altyazı, ses, kalite, ekran oranı, favori, uyku zamanlayıcısı ve tanılamayı açabilirsiniz.',
        'Otomatik decoder sorun yaşarsa güvenli fallback dener; kanal özelindeki tercihler hatırlanır.'
      ],
      [
        'Favoriler ve içerik seçenekleri',
        'İçeriğinizi size göre düzenleyin.',
        'Favoriler ekranı canlı, film ve dizileri ayrı gruplar halinde gösterir.',
        'Her içerik yüzeyinde uzun OK ile favoriye ekleme/çıkarma, gizleme ve kilitleme işlemlerine ulaşılır.',
        'Gizlenen içerikler arama, ana sayfa ve Android TV önerilerinde gösterilmez.'
      ],
      [
        'Arama ve hızlı tuşlar',
        'İçeriğe ve ana bölümlere hızlı ulaşın.',
        'Arama; kanal, film ve dizileri adından bulur. Sonucu OK ile açın.',
        'Kumandadaki 0 Ana Sayfa, 1 Canlı TV, 2 Filmler, 3 Diziler, 4 Arama, 5 Favoriler, 6 Ayarlar kısayoludur.',
        'Renkli tuşlar desteklenen kumandalarda ana bölümlere hızlı geçiş sağlar.'
      ],
      [
        'Ebeveyn kontrolü',
        'PIN ile kategori ve içerik koruması.',
        'Ayarlar > Ebeveyn Kontrolü bölümünde 4-6 rakamlı PIN oluşturun.',
        'Kategori başlığında veya içerikte uzun OK ile kilidi yönetin.',
        'Kilitli içerikleri gizleyebilir ve kilit açma oturum süresini seçebilirsiniz.',
        'PIN ve Xtream parolaları yedeğe eklenmez. PIN unutulursa güvenlik nedeniyle geri okunamaz.'
      ],
      [
        'Görüntü, ses ve performans',
        'TV’nize uygun oynatma davranışını seçin.',
        'Decoder için Otomatik önerilir; yalnızca uyumsuz yayınlarda Donanım/Yazılım seçimini değiştirin.',
        'Kalite sınırı yalnız adaptif, çok kaliteli yayınlarda uygulanabilir.',
        'Kare hızı eşleştirme desteklenen Android TV’lerde daha akıcı hareket sağlar; ekran kısa süre kararabilir.',
        'Her açılışta karıştır seçeneği film/dizi kategori ve içerik sırasını yeni oturumda değiştirir.'
      ],
      [
        'Yedekleme ve gizlilik',
        'Ayarlarınızı güvenli biçimde taşıyın.',
        'Ayarlar bölümünden parola korumalı .aladin yedeği oluşturabilir ve geri yükleyebilirsiniz.',
        'Yedek; favori, ilerleme, ayar ve kilitleri taşır; Xtream parolası ile ebeveyn PIN’ini taşımaz.',
        'Uygulama IPTV içeriği sunmaz. Yayın adresleri release günlüklerinde ve hata ekranlarında gösterilmez.'
      ],
      [
        'Güncelleme ve Hakkında',
        'Uygulamanın güncel olup olmadığını kontrol edin.',
        'Ayarlar > Hakkında > Güncellemeleri Kontrol Et, kurulu sürümü mağazadaki sürümle karşılaştırır.',
        'Yeni sürüm varsa Google Play sayfası açılır; uygulama dışarıdan sessiz APK kurmaz.',
        'Hakkında ekranında sürüm, Watch Next durumu, yeniden deneme ve gizlilik bağlantıları bulunur.'
      ],
      [
        'Sorun giderme',
        'Yayın veya liste açılmadığında izlenecek yol.',
        'Önce interneti ve sağlayıcı hesabınızın aktif/bağlantı sınırını kontrol edin.',
        'Liste Sağlık Raporu ile boş URL, yinelenen kayıt, eksik logo ve EPG kimliklerini inceleyin.',
        'Tek kanalda sorun varsa uzun OK > kanal profili ile Otomatik veya farklı decoder deneyin.',
        'EPG yoksa Ayarlar’dan EPG kaynağını ve son eşitleme durumunu kontrol edin. Sunucu hataları çoğunlukla sağlayıcı kaynaklıdır.'
      ],
    ],
    'en': [
      [
        'Quick start',
        'Go from setup to playback in three steps.',
        'Open Settings > Add New Playlist.',
        'Choose M3U URL, Xtream Codes, or a local M3U file.',
        'Save, then confirm Activate now. Content is classified automatically.',
        'The app provides no content; use only playlists you are authorized to access.'
      ],
      [
        'Playlists',
        'Manage M3U, Xtream, and local playlists.',
        'The server field starts with http://; shortcut chips add https://, domains, and common ports.',
        'Activate, refresh, rename, inspect the health report, or delete a saved playlist.',
        'Refresh preserves favorites and watch state. Xtream passwords use secure storage.'
      ],
      [
        'Home',
        'Personal shelves and Continue Watching.',
        'Browse Continue Watching, Favorites, Recently Added, Most Watched, Movies, Series, and Discover.',
        'Press OK to open; hold OK for favorite, lock, hide, and channel-profile actions.',
        'Use dashboard customization to show, hide, and reorder shelves.'
      ],
      [
        'Live TV & EPG',
        'Channels, now/next data, and the programme guide.',
        'Use left/right within a row and up/down between rows; OK starts the channel.',
        'Open EPG to change day and move across the shared timeline.',
        'Hold OK on a channel for favorite, lock, hide, decoder, and quality options.'
      ],
      [
        'Movies & Series',
        'Posters, seasons, episodes, and progress.',
        'OK plays a movie; on a series it opens seasons and episodes.',
        'Part-watched movies and episodes appear in Continue Watching.',
        'Posters, summaries, and ratings are enriched in the background when TMDB is available.'
      ],
      [
        'Categories',
        'Jump directly through large libraries.',
        'Open All Categories at the top of Live TV, Movies, or Series.',
        'Search the panel; the number beside a category is its item count.',
        'Hold OK to pin a category. The five most recent categories are remembered.',
        'Manage Hidden restores hidden categories or titles.'
      ],
      [
        'Player & remote',
        'All essential playback controls.',
        'OK opens player controls; Back closes the active panel first, then the player.',
        'Up/down changes live channels. Left/right seeks in on-demand video.',
        'Controls include channel list, subtitles, audio, quality, aspect, favorite, sleep timer, and diagnostics.',
        'Automatic decoder fallback and per-channel preferences improve compatibility.'
      ],
      [
        'Favorites & item options',
        'Organize content around your preferences.',
        'Favorites groups live channels, movies, and series.',
        'Hold OK anywhere on content for favorite, hide, lock, and profile actions.',
        'Hidden content is removed from search, Home, and Android TV recommendations.'
      ],
      [
        'Search & shortcuts',
        'Reach content and sections faster.',
        'Search finds channels, movies, and series by name.',
        'Remote keys: 0 Home, 1 Live TV, 2 Movies, 3 Series, 4 Search, 5 Favorites, 6 Settings.',
        'Supported color keys also jump to primary sections.'
      ],
      [
        'Parental controls',
        'Protect categories and titles with a PIN.',
        'Create a 4–6 digit PIN in Settings > Parental Controls.',
        'Hold OK on a category or title to manage its lock.',
        'Choose whether locked content is hidden and set the unlock-session duration.',
        'PINs and Xtream passwords are never included in backups.'
      ],
      [
        'Picture, sound & performance',
        'Match playback to your TV.',
        'Automatic decoder is recommended; change hardware/software only for incompatible streams.',
        'The quality limit applies only to adaptive multi-quality streams.',
        'Frame-rate matching improves motion on supported TVs and may briefly blank the screen.',
        'Shuffle on launch changes movie/series categories and items each new session.'
      ],
      [
        'Backup & privacy',
        'Move settings securely.',
        'Create or restore a password-protected .aladin backup in Settings.',
        'Backups include favorites, progress, settings, and locks—not Xtream passwords or the parental PIN.',
        'The app supplies no IPTV content and hides stream addresses from release logs and errors.'
      ],
      [
        'Updates & About',
        'Check whether the app is current.',
        'Settings > About > Check for updates compares the installed and store versions.',
        'When available, the Play Store page opens; the app never silently installs external APKs.',
        'About also shows version, Watch Next status, retry, and privacy links.'
      ],
      [
        'Troubleshooting',
        'Steps for streams or lists that do not open.',
        'Check internet access, account status, and your provider connection limit.',
        'Use Playlist Health for empty URLs, duplicates, missing logos, and missing EPG IDs.',
        'For one failing channel, hold OK and try Automatic or another decoder profile.',
        'If EPG is empty, check its source and last sync in Settings. Server failures are usually provider-side.'
      ],
    ],
    'de': [
      [
        'Schnellstart',
        'In drei Schritten zur Wiedergabe.',
        'Öffnen Sie Einstellungen > Neue Wiedergabeliste.',
        'Wählen Sie M3U-URL, Xtream Codes oder eine lokale M3U-Datei.',
        'Speichern und Jetzt aktivieren bestätigen. Die App liefert keine Inhalte.'
      ],
      [
        'Wiedergabelisten',
        'Listen hinzufügen und verwalten.',
        'http:// ist vorbereitet; Schaltflächen ergänzen Protokoll, Domain und Port.',
        'Listen aktivieren, aktualisieren, umbenennen, prüfen oder löschen.',
        'Favoriten und Fortschritt bleiben beim Aktualisieren erhalten.'
      ],
      [
        'Startseite',
        'Persönliche Reihen und Wiedergabefortschritt.',
        'Mit dem Steuerkreuz durch Fortsetzen, Favoriten, Neu, Häufig und Entdecken navigieren.',
        'OK öffnet; langes OK zeigt Favorit, Sperre, Ausblenden und Profil.',
        'Reihen lassen sich ein-/ausblenden und sortieren.'
      ],
      [
        'Live-TV und EPG',
        'Sender und gemeinsamer Programmzeitplan.',
        'Links/rechts in einer Reihe, oben/unten zwischen Reihen; OK startet.',
        'Im EPG Tag wechseln und die Zeitachse horizontal bewegen.',
        'Langes OK öffnet Senderoptionen.'
      ],
      [
        'Filme und Serien',
        'Poster, Staffeln, Folgen und Fortschritt.',
        'OK spielt Filme oder öffnet Staffeln und Folgen.',
        'Angefangene Titel erscheinen unter Weiterschauen.',
        'TMDB ergänzt verfügbare Poster und Informationen.'
      ],
      [
        'Kategorien',
        'Direkter Zugriff auf große Bibliotheken.',
        'Alle Kategorien oben in Live-TV, Filme oder Serien öffnen.',
        'Suchen; die Zahl zeigt die Inhaltsmenge.',
        'Langes OK fixiert, fünf zuletzt verwendete Kategorien werden gespeichert.'
      ],
      [
        'Player und Fernbedienung',
        'Zentrale Wiedergabesteuerung.',
        'OK öffnet das Menü; Zurück schließt zuerst das aktive Panel.',
        'Oben/unten wechselt Live-Sender, links/rechts spult VOD.',
        'Menü: Senderliste, Untertitel, Audio, Qualität, Format, Favorit, Timer, Diagnose.'
      ],
      [
        'Favoriten und Optionen',
        'Inhalte persönlich organisieren.',
        'Favoriten gruppiert Live-TV, Filme und Serien.',
        'Langes OK öffnet Favorit, Ausblenden, Sperre und Profil.',
        'Ausgeblendete Inhalte fehlen auch in Suche und Empfehlungen.'
      ],
      [
        'Suche und Kurztasten',
        'Inhalte schneller erreichen.',
        'Die Suche findet Sender, Filme und Serien nach Namen.',
        '0 Start, 1 Live, 2 Filme, 3 Serien, 4 Suche, 5 Favoriten, 6 Einstellungen.',
        'Farbtasten werden auf unterstützten Fernbedienungen erkannt.'
      ],
      [
        'Kindersicherung',
        'Kategorien und Titel per PIN schützen.',
        'Unter Einstellungen eine 4–6-stellige PIN erstellen.',
        'Langes OK verwaltet die Sperre; Sichtbarkeit und Sitzungsdauer sind wählbar.',
        'PIN und Xtream-Passwort werden nie gesichert.'
      ],
      [
        'Bild, Ton und Leistung',
        'Wiedergabe an den Fernseher anpassen.',
        'Automatischen Decoder bevorzugen; Hardware/Software nur bei Problemen ändern.',
        'Qualitätslimit gilt nur für adaptive Streams.',
        'Bildratenanpassung und Mischen beim Start sind optional.'
      ],
      [
        'Sicherung und Datenschutz',
        'Einstellungen sicher übertragen.',
        'Eine passwortgeschützte .aladin-Datei erstellen oder wiederherstellen.',
        'Favoriten, Fortschritt, Einstellungen und Sperren werden gesichert; Passwörter und PIN nicht.',
        'Stream-Adressen erscheinen nicht in Release-Protokollen.'
      ],
      [
        'Updates und Info',
        'Installierte Version prüfen.',
        'Einstellungen > Info > Nach Updates suchen vergleicht mit dem Store.',
        'Bei neuer Version öffnet sich Google Play; keine stille APK-Installation.',
        'Info zeigt Version, Watch Next und Datenschutz.'
      ],
      [
        'Fehlerbehebung',
        'Wenn Liste oder Stream nicht startet.',
        'Internet, Konto und Verbindungslimit des Anbieters prüfen.',
        'Gesundheitsbericht auf leere URLs, Duplikate, Logos und EPG-IDs prüfen.',
        'Bei einem Sender Decoderprofil wechseln; EPG-Quelle und Synchronisierung prüfen.'
      ],
    ],
    'fr': [
      [
        'Démarrage rapide',
        'Commencez à regarder en trois étapes.',
        'Ouvrez Paramètres > Ajouter une playlist.',
        'Choisissez URL M3U, Xtream Codes ou fichier M3U local.',
        'Enregistrez puis activez. L’application ne fournit aucun contenu.'
      ],
      [
        'Playlists',
        'Ajouter et gérer vos listes.',
        'http:// est prérempli ; les raccourcis ajoutent protocole, domaine et port.',
        'Activez, actualisez, renommez, analysez ou supprimez une liste.',
        'L’actualisation conserve favoris et progression.'
      ],
      [
        'Accueil',
        'Rangées personnelles et reprise de lecture.',
        'Parcourez Reprendre, Favoris, Nouveautés, Fréquents et Découvrir.',
        'OK ouvre ; OK long affiche favori, verrou, masquer et profil.',
        'Affichez, masquez et réorganisez les rangées.'
      ],
      [
        'TV en direct et EPG',
        'Chaînes et guide horaire commun.',
        'Gauche/droite dans une rangée, haut/bas entre rangées ; OK lance.',
        'Changez de jour et déplacez la chronologie EPG.',
        'OK long ouvre les options de chaîne.'
      ],
      [
        'Films et séries',
        'Affiches, saisons, épisodes et progression.',
        'OK lit un film ou ouvre saisons et épisodes.',
        'Les titres commencés apparaissent dans Reprendre.',
        'TMDB enrichit les informations disponibles.'
      ],
      [
        'Catégories',
        'Accès direct aux grandes bibliothèques.',
        'Ouvrez Toutes les catégories en haut des sections.',
        'Recherchez ; le nombre indique la quantité de contenus.',
        'OK long épingle ; les cinq dernières catégories sont mémorisées.'
      ],
      [
        'Lecteur et télécommande',
        'Toutes les commandes de lecture.',
        'OK ouvre le menu ; Retour ferme d’abord le panneau actif.',
        'Haut/bas change de chaîne ; gauche/droite avance ou recule la VOD.',
        'Liste, sous-titres, audio, qualité, format, favori, veille et diagnostic sont disponibles.'
      ],
      [
        'Favoris et options',
        'Organisez vos contenus.',
        'Les favoris regroupent direct, films et séries.',
        'OK long ouvre favori, masquer, verrou et profil.',
        'Le contenu masqué disparaît aussi de la recherche et des recommandations.'
      ],
      [
        'Recherche et raccourcis',
        'Accédez plus vite aux contenus.',
        'La recherche trouve chaînes, films et séries par nom.',
        '0 Accueil, 1 Direct, 2 Films, 3 Séries, 4 Recherche, 5 Favoris, 6 Paramètres.',
        'Les touches colorées compatibles servent aussi de raccourcis.'
      ],
      [
        'Contrôle parental',
        'Protégez catégories et titres par PIN.',
        'Créez un PIN de 4 à 6 chiffres dans Paramètres.',
        'OK long gère le verrou ; visibilité et durée de session sont réglables.',
        'PIN et mot de passe Xtream ne sont jamais sauvegardés.'
      ],
      [
        'Image, son et performances',
        'Adaptez la lecture à votre TV.',
        'Le décodeur Auto est conseillé ; changez-le seulement en cas d’incompatibilité.',
        'La limite de qualité concerne les flux adaptatifs.',
        'Fréquence d’image et mélange au démarrage sont optionnels.'
      ],
      [
        'Sauvegarde et confidentialité',
        'Transférez vos réglages en sécurité.',
        'Créez ou restaurez un fichier .aladin protégé par mot de passe.',
        'Favoris, progression, réglages et verrous sont inclus, jamais mots de passe ni PIN.',
        'Les adresses de flux sont masquées des journaux de production.'
      ],
      [
        'Mises à jour et À propos',
        'Vérifiez la version installée.',
        'Paramètres > À propos > Rechercher les mises à jour compare avec le Store.',
        'Google Play s’ouvre si nécessaire ; aucune installation APK silencieuse.',
        'À propos affiche version, Watch Next et confidentialité.'
      ],
      [
        'Dépannage',
        'Si une liste ou un flux ne s’ouvre pas.',
        'Vérifiez Internet, le compte et la limite de connexions du fournisseur.',
        'Utilisez le rapport de santé pour URL vides, doublons, logos et EPG.',
        'Essayez un autre décodeur pour une chaîne ; vérifiez source et synchro EPG.'
      ],
    ],
    'es': [
      [
        'Inicio rápido',
        'Empieza a reproducir en tres pasos.',
        'Abre Ajustes > Añadir lista nueva.',
        'Elige URL M3U, Xtream Codes o archivo M3U local.',
        'Guarda y activa. La aplicación no proporciona contenido.'
      ],
      [
        'Listas',
        'Añade y administra tus listas.',
        'http:// viene preparado; los atajos añaden protocolo, dominio y puerto.',
        'Activa, actualiza, renombra, analiza o elimina listas.',
        'Actualizar conserva favoritos y progreso.'
      ],
      [
        'Inicio',
        'Filas personales y continuar viendo.',
        'Navega por Continuar, Favoritos, Nuevos, Frecuentes y Descubrir.',
        'OK abre; OK largo muestra favorito, bloqueo, ocultar y perfil.',
        'Puedes mostrar, ocultar y ordenar las filas.'
      ],
      [
        'TV en directo y EPG',
        'Canales y guía con línea temporal común.',
        'Izquierda/derecha en filas, arriba/abajo entre ellas; OK reproduce.',
        'Cambia el día y desplaza horizontalmente la guía.',
        'OK largo abre las opciones del canal.'
      ],
      [
        'Películas y series',
        'Carteles, temporadas, episodios y progreso.',
        'OK reproduce una película o abre temporadas y episodios.',
        'Los títulos empezados aparecen en Continuar viendo.',
        'TMDB completa la información disponible.'
      ],
      [
        'Categorías',
        'Acceso directo a bibliotecas grandes.',
        'Abre Todas las categorías arriba de cada sección.',
        'Busca; el número indica cuántos contenidos hay.',
        'OK largo fija; se recuerdan las últimas cinco categorías.'
      ],
      [
        'Reproductor y mando',
        'Todos los controles de reproducción.',
        'OK abre el menú; Atrás cierra primero el panel activo.',
        'Arriba/abajo cambia canal; izquierda/derecha busca en VOD.',
        'Lista, subtítulos, audio, calidad, formato, favorito, temporizador y diagnóstico.'
      ],
      [
        'Favoritos y opciones',
        'Organiza el contenido a tu gusto.',
        'Favoritos agrupa directo, películas y series.',
        'OK largo abre favorito, ocultar, bloquear y perfil.',
        'El contenido oculto desaparece de búsqueda y recomendaciones.'
      ],
      [
        'Búsqueda y atajos',
        'Llega antes a contenidos y secciones.',
        'Busca canales, películas y series por nombre.',
        '0 Inicio, 1 Directo, 2 Películas, 3 Series, 4 Buscar, 5 Favoritos, 6 Ajustes.',
        'Los botones de color compatibles también son atajos.'
      ],
      [
        'Control parental',
        'Protege categorías y títulos con PIN.',
        'Crea un PIN de 4–6 dígitos en Ajustes.',
        'OK largo gestiona bloqueos; elige visibilidad y duración de sesión.',
        'El PIN y la contraseña Xtream nunca se copian.'
      ],
      [
        'Imagen, sonido y rendimiento',
        'Adapta la reproducción al televisor.',
        'Se recomienda decodificador Auto; cambia solo si hay incompatibilidad.',
        'El límite de calidad solo funciona en streams adaptativos.',
        'La frecuencia de imagen y mezcla al iniciar son opcionales.'
      ],
      [
        'Copia y privacidad',
        'Traslada ajustes con seguridad.',
        'Crea o restaura un archivo .aladin protegido por contraseña.',
        'Incluye favoritos, progreso, ajustes y bloqueos; no contraseñas ni PIN.',
        'Las direcciones de stream se ocultan en registros de producción.'
      ],
      [
        'Actualizaciones y Acerca de',
        'Comprueba si la app está al día.',
        'Ajustes > Acerca de > Buscar actualizaciones compara con la tienda.',
        'Si existe una versión abre Google Play; no instala APK en silencio.',
        'Acerca de muestra versión, Watch Next y privacidad.'
      ],
      [
        'Solución de problemas',
        'Cuando una lista o stream no abre.',
        'Comprueba Internet, cuenta y límite de conexiones del proveedor.',
        'Usa Salud de lista para URL vacías, duplicados, logos y EPG.',
        'Prueba otro decodificador por canal y revisa fuente/sincronización EPG.'
      ],
    ],
    'ru': [
      [
        'Быстрый старт',
        'Начните просмотр за три шага.',
        'Откройте Настройки > Добавить плейлист.',
        'Выберите URL M3U, Xtream Codes или локальный M3U.',
        'Сохраните и активируйте. Приложение не предоставляет контент.'
      ],
      [
        'Плейлисты',
        'Добавление и управление списками.',
        'http:// уже введён; кнопки добавляют протокол, домен и порт.',
        'Активируйте, обновляйте, переименовывайте, проверяйте или удаляйте списки.',
        'Обновление сохраняет избранное и прогресс.'
      ],
      [
        'Главная',
        'Персональные полки и продолжение просмотра.',
        'Перемещайтесь по Продолжить, Избранное, Новинки, Часто и Открытия.',
        'OK открывает; долгое OK — избранное, блокировка, скрытие и профиль.',
        'Полки можно скрывать и менять местами.'
      ],
      [
        'Прямой эфир и EPG',
        'Каналы и общая шкала телепрограммы.',
        'Влево/вправо внутри ряда, вверх/вниз между рядами; OK запускает.',
        'Меняйте день и двигайте шкалу EPG.',
        'Долгое OK открывает параметры канала.'
      ],
      [
        'Фильмы и сериалы',
        'Постеры, сезоны, серии и прогресс.',
        'OK запускает фильм или открывает сезоны и серии.',
        'Незавершённое появляется в Продолжить просмотр.',
        'TMDB дополняет доступные сведения.'
      ],
      [
        'Категории',
        'Быстрый переход по большой библиотеке.',
        'Откройте Все категории вверху раздела.',
        'Используйте поиск; число показывает количество элементов.',
        'Долгое OK закрепляет; сохраняются пять последних категорий.'
      ],
      [
        'Плеер и пульт',
        'Основные элементы управления.',
        'OK открывает меню; Назад сначала закрывает активную панель.',
        'Вверх/вниз меняет канал; влево/вправо перематывает VOD.',
        'Доступны список, субтитры, звук, качество, формат, избранное, таймер и диагностика.'
      ],
      [
        'Избранное и действия',
        'Настройте библиотеку под себя.',
        'Избранное разделяет эфир, фильмы и сериалы.',
        'Долгое OK: избранное, скрыть, заблокировать и профиль.',
        'Скрытое исчезает из поиска и рекомендаций.'
      ],
      [
        'Поиск и клавиши',
        'Быстрый доступ к разделам.',
        'Поиск находит каналы, фильмы и сериалы по имени.',
        '0 Главная, 1 Эфир, 2 Фильмы, 3 Сериалы, 4 Поиск, 5 Избранное, 6 Настройки.',
        'Цветные клавиши также работают на совместимых пультах.'
      ],
      [
        'Родительский контроль',
        'Защита категорий и контента PIN-кодом.',
        'Создайте PIN из 4–6 цифр в Настройках.',
        'Долгое OK управляет блокировкой; настройте скрытие и время сессии.',
        'PIN и пароль Xtream не попадают в резервную копию.'
      ],
      [
        'Изображение, звук, скорость',
        'Настройте воспроизведение под телевизор.',
        'Рекомендуется Авто; меняйте декодер только при несовместимости.',
        'Ограничение качества работает лишь с адаптивными потоками.',
        'Сопоставление частоты и перемешивание при запуске включаются отдельно.'
      ],
      [
        'Резервная копия и приватность',
        'Безопасный перенос настроек.',
        'Создайте или восстановите защищённый паролем файл .aladin.',
        'Сохраняются избранное, прогресс, настройки и блокировки — не пароли и PIN.',
        'Адреса потоков скрыты из журналов релиза.'
      ],
      [
        'Обновления и О программе',
        'Проверка актуальности приложения.',
        'Настройки > О программе > Проверить обновления сравнивает со Store.',
        'При наличии версии откроется Google Play; скрытой установки APK нет.',
        'Здесь также видны версия, Watch Next и приватность.'
      ],
      [
        'Устранение проблем',
        'Если список или поток не открывается.',
        'Проверьте интернет, аккаунт и лимит подключений провайдера.',
        'Отчёт о здоровье покажет пустые URL, дубли, логотипы и EPG ID.',
        'Для канала смените декодер; проверьте источник и синхронизацию EPG.'
      ],
    ],
    'zh': [
      [
        '快速开始',
        '三步开始播放。',
        '打开“设置 > 添加新播放列表”。',
        '选择 M3U URL、Xtream Codes 或本地 M3U 文件。',
        '保存并立即启用。本应用不提供任何频道内容。'
      ],
      [
        '播放列表',
        '添加并管理列表。',
        '服务器栏预填 http://，快捷按钮可添加协议、域名和端口。',
        '可启用、刷新、重命名、检查或删除列表。',
        '刷新会保留收藏与观看进度。'
      ],
      [
        '主页',
        '个性化内容架与继续观看。',
        '用方向键浏览继续观看、收藏、最新、常看和发现。',
        'OK 打开；长按 OK 显示收藏、锁定、隐藏与频道配置。',
        '可显示、隐藏并调整内容架顺序。'
      ],
      [
        '直播与节目单',
        '频道和统一时间轴节目单。',
        '行内左右移动，行间上下移动；OK 播放。',
        '在 EPG 中切换日期并横向移动时间轴。',
        '长按 OK 打开频道选项。'
      ],
      [
        '电影与剧集',
        '海报、季、集和观看进度。',
        'OK 播放电影，或打开剧集的季与集。',
        '未看完的内容显示在继续观看。',
        'TMDB 可在后台补充海报和资料。'
      ],
      [
        '分类',
        '快速浏览大型内容库。',
        '打开直播、电影或剧集顶部的“所有分类”。',
        '可搜索；数字表示该分类的内容数量。',
        '长按 OK 固定分类，并记住最近五个分类。'
      ],
      [
        '播放器与遥控器',
        '常用播放控制。',
        'OK 打开菜单；返回键先关闭当前面板。',
        '上下切换直播频道；左右在点播中快退快进。',
        '可用频道列表、字幕、音轨、质量、画面比例、收藏、睡眠定时和诊断。'
      ],
      [
        '收藏与内容选项',
        '按喜好整理内容。',
        '收藏按直播、电影和剧集分组。',
        '在内容上长按 OK 可收藏、隐藏、锁定和设置配置。',
        '隐藏内容不会出现在搜索和推荐中。'
      ],
      [
        '搜索与快捷键',
        '更快到达内容和页面。',
        '按名称搜索频道、电影和剧集。',
        '0 主页、1 直播、2 电影、3 剧集、4 搜索、5 收藏、6 设置。',
        '兼容遥控器的彩色键也可快速跳转。'
      ],
      [
        '家长控制',
        '用 PIN 保护分类和内容。',
        '在设置中创建 4–6 位 PIN。',
        '长按 OK 管理锁定，并设置隐藏方式与解锁时长。',
        'PIN 和 Xtream 密码不会写入备份。'
      ],
      [
        '画面、声音与性能',
        '让播放适合您的电视。',
        '推荐自动解码；仅在不兼容时更改硬件/软件解码。',
        '质量限制只适用于自适应多码率流。',
        '帧率匹配和启动时随机排列均可选。'
      ],
      [
        '备份与隐私',
        '安全迁移设置。',
        '创建或恢复受密码保护的 .aladin 文件。',
        '备份包含收藏、进度、设置和锁定，不含密码与 PIN。',
        '正式版日志不会显示播放地址。'
      ],
      [
        '更新与关于',
        '检查应用是否为最新版。',
        '设置 > 关于 > 检查更新会与商店版本比较。',
        '有新版本时打开 Google Play，不会静默安装 APK。',
        '关于页还显示版本、Watch Next 和隐私信息。'
      ],
      [
        '故障排除',
        '列表或播放无法打开时。',
        '检查网络、账号状态和服务商连接数限制。',
        '用列表健康报告检查空 URL、重复项、台标和 EPG ID。',
        '单频道可尝试其他解码器；EPG 缺失时检查来源和同步。'
      ],
    ],
    'ar': [
      [
        'بدء سريع',
        'ابدأ المشاهدة في ثلاث خطوات.',
        'افتح الإعدادات > إضافة قائمة تشغيل جديدة.',
        'اختر رابط M3U أو Xtream Codes أو ملف M3U محلي.',
        'احفظ ثم فعّل الآن. التطبيق لا يوفر أي محتوى.'
      ],
      [
        'قوائم التشغيل',
        'إضافة القوائم وإدارتها.',
        'يظهر http:// مسبقاً وتضيف الأزرار البروتوكول والنطاق والمنفذ.',
        'يمكنك التفعيل والتحديث وإعادة التسمية والفحص والحذف.',
        'يحافظ التحديث على المفضلة وتقدم المشاهدة.'
      ],
      [
        'الرئيسية',
        'صفوف شخصية ومتابعة المشاهدة.',
        'تنقل بين المتابعة والمفضلة والجديد والأكثر مشاهدة والاستكشاف.',
        'موافق للفتح؛ ضغط مطول للمفضلة والقفل والإخفاء والملف.',
        'يمكن إظهار الصفوف وإخفاؤها وترتيبها.'
      ],
      [
        'البث المباشر وEPG',
        'قنوات ودليل برامج بخط زمني موحد.',
        'يمين/يسار داخل الصف وأعلى/أسفل بين الصفوف؛ موافق للتشغيل.',
        'غيّر اليوم وحرّك الخط الزمني أفقياً.',
        'الضغط المطول يفتح خيارات القناة.'
      ],
      [
        'الأفلام والمسلسلات',
        'ملصقات ومواسم وحلقات وتقدم.',
        'موافق يشغّل الفيلم أو يفتح المواسم والحلقات.',
        'يظهر المحتوى غير المكتمل في متابعة المشاهدة.',
        'تضيف TMDB المعلومات المتاحة في الخلفية.'
      ],
      [
        'الفئات',
        'انتقال سريع داخل المكتبات الكبيرة.',
        'افتح كل الفئات أعلى البث أو الأفلام أو المسلسلات.',
        'ابحث؛ الرقم يبين عدد العناصر.',
        'ضغط مطول لتثبيت الفئة وتُحفظ آخر خمس فئات.'
      ],
      [
        'المشغل والريموت',
        'كل عناصر التحكم الأساسية.',
        'موافق يفتح القائمة؛ رجوع يغلق اللوحة النشطة أولاً.',
        'أعلى/أسفل يغير قناة البث ويمين/يسار يقدم أو يرجع الفيديو.',
        'تتوفر القائمة والترجمة والصوت والجودة والنسبة والمفضلة والمؤقت والتشخيص.'
      ],
      [
        'المفضلة وخيارات المحتوى',
        'نظم المحتوى حسب رغبتك.',
        'تجمع المفضلة البث والأفلام والمسلسلات.',
        'ضغط مطول يفتح المفضلة والإخفاء والقفل والملف.',
        'المحتوى المخفي لا يظهر في البحث أو التوصيات.'
      ],
      [
        'البحث والاختصارات',
        'وصول أسرع إلى المحتوى والأقسام.',
        'ابحث عن القنوات والأفلام والمسلسلات بالاسم.',
        '0 الرئيسية، 1 البث، 2 الأفلام، 3 المسلسلات، 4 البحث، 5 المفضلة، 6 الإعدادات.',
        'الأزرار الملونة تعمل أيضاً في الأجهزة المدعومة.'
      ],
      [
        'الرقابة الأبوية',
        'حماية الفئات والعناوين برقم PIN.',
        'أنشئ PIN من 4–6 أرقام في الإعدادات.',
        'ضغط مطول لإدارة القفل واختيار الإخفاء ومدة الجلسة.',
        'لا يُحفظ PIN أو كلمة مرور Xtream في النسخ الاحتياطي.'
      ],
      [
        'الصورة والصوت والأداء',
        'اضبط التشغيل ليتناسب مع التلفاز.',
        'يوصى بفك الترميز التلقائي؛ غيّره فقط عند عدم التوافق.',
        'حد الجودة يعمل فقط مع البث المتكيف.',
        'مطابقة الإطارات والخلط عند البدء خياران اختياريان.'
      ],
      [
        'النسخ والخصوصية',
        'انقل الإعدادات بأمان.',
        'أنشئ أو استعد ملف .aladin محمياً بكلمة مرور.',
        'يشمل المفضلة والتقدم والإعدادات والأقفال ولا يشمل كلمات المرور أو PIN.',
        'لا تظهر روابط البث في سجلات الإصدار.'
      ],
      [
        'التحديثات وحول',
        'تحقق من حداثة التطبيق.',
        'الإعدادات > حول > فحص التحديثات يقارن بإصدار المتجر.',
        'يفتح Google Play عند توفر إصدار ولا يثبت APK بصمت.',
        'تعرض الصفحة الإصدار وWatch Next والخصوصية.'
      ],
      [
        'حل المشكلات',
        'عند تعذر فتح قائمة أو بث.',
        'تحقق من الإنترنت والحساب وحد اتصالات المزود.',
        'استخدم تقرير الصحة لفحص الروابط الفارغة والتكرار والشعارات وEPG.',
        'جرّب ملف فك ترميز آخر للقناة وافحص مصدر ومزامنة EPG.'
      ],
    ],
  };
}

class AladinHelpPage extends StatefulWidget {
  const AladinHelpPage({super.key});
  @override
  State<AladinHelpPage> createState() => _AladinHelpPageState();
}

class _AladinHelpPageState extends State<AladinHelpPage> {
  int _selected = 0;
  String _query = '';
  final _searchNode = FocusNode(debugLabel: 'help_search');

  @override
  void dispose() {
    _searchNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().lang;
    final labels = AladinHelpCatalog.labels(lang);
    var topics = AladinHelpCatalog.topics(lang);
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      topics = topics
          .where((t) => '${t.title} ${t.summary} ${t.steps.join(' ')}'
              .toLowerCase()
              .contains(q))
          .toList();
    }
    if (_selected >= topics.length) _selected = 0;
    final active = topics.isEmpty ? null : topics[_selected];
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(42, 26, 42, 30),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _FocusIcon(
                  icon: Icons.arrow_back,
                  tooltip: labels['back']!,
                  onPressed: () => Navigator.pop(context)),
              const SizedBox(width: 18),
              const Icon(Icons.help_outline_rounded,
                  color: AppTheme.accent, size: 34),
              const SizedBox(width: 12),
              Text(labels['title']!,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800)),
              const Spacer(),
              _RemoteLegend(labels: labels),
            ]),
            const SizedBox(height: 22),
            TextField(
              focusNode: _searchNode,
              onChanged: (value) => setState(() {
                _query = value;
                _selected = 0;
              }),
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: labels['search'],
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close))),
            ),
            const SizedBox(height: 20),
            Expanded(
                child: topics.isEmpty
                    ? Center(
                        child: Text(labels['empty']!,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 20)))
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                            SizedBox(
                                width: 350,
                                child: ListView.separated(
                                  itemCount: topics.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (_, i) => _TopicTile(
                                      topic: topics[i],
                                      selected: i == _selected,
                                      autofocus: i == 0 && _query.isEmpty,
                                      onTap: () =>
                                          setState(() => _selected = i)),
                                )),
                            const SizedBox(width: 24),
                            Expanded(child: _TopicDetail(topic: active!)),
                          ])),
          ]),
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile(
      {required this.topic,
      required this.selected,
      required this.autofocus,
      required this.onTap});
  final AladinHelpTopic topic;
  final bool selected, autofocus;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
      color: selected ? AppTheme.accent.withOpacity(.16) : AppTheme.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        autofocus: autofocus,
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: selected ? AppTheme.accent : Colors.white12,
                    width: selected ? 2 : 1)),
            child: Row(children: [
              Icon(topic.icon,
                  color: selected ? AppTheme.accent : AppTheme.textSecondary),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(topic.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500)))
            ])),
      ));
}

class _TopicDetail extends StatelessWidget {
  const _TopicDetail({required this.topic});
  final AladinHelpTopic topic;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: AppTheme.card.withOpacity(.94),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white12)),
        child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(.16),
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(topic.icon, color: AppTheme.accent, size: 31)),
          const SizedBox(height: 20),
          Text(topic.title,
              style:
                  const TextStyle(fontSize: 29, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(topic.summary,
              style: const TextStyle(
                  fontSize: 17, color: AppTheme.textSecondary, height: 1.45)),
          const SizedBox(height: 25),
          ...List.generate(
              topic.steps.length,
              (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 17),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: AppTheme.accent, shape: BoxShape.circle),
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800))),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Text(topic.steps[i],
                                style: const TextStyle(
                                    fontSize: 17, height: 1.5))),
                      ]))),
        ])),
      );
}

class _RemoteLegend extends StatelessWidget {
  const _RemoteLegend({required this.labels});
  final Map<String, String> labels;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12)),
      child: Row(children: [
        const Icon(Icons.gamepad_outlined, color: AppTheme.accent),
        const SizedBox(width: 10),
        Text('${labels['ok']}  •  ${labels['hold']}  •  ${labels['back']}',
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      ]));
}

class _FocusIcon extends StatelessWidget {
  const _FocusIcon(
      {required this.icon, required this.tooltip, required this.onPressed});
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => IconButton(
      autofocus: false,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
          backgroundColor: AppTheme.card,
          foregroundColor: Colors.white,
          focusColor: AppTheme.accent));
}
