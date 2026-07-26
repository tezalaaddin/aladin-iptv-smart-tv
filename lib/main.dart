import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/database/aladin_isar_service.dart';
import 'core/services/aladin_channel_service.dart';
import 'core/di/aladin_di.dart';
import 'core/state/aladin_app_prefs.dart';
import 'core/state/aladin_app_state.dart';
import 'core/state/aladin_app_strings.dart';
import 'core/services/aladin_metadata_sync_service.dart';
import 'core/services/aladin_epg_engine.dart';
import 'features/aladin_main_page.dart';
import 'shared/theme/aladin_app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Hata Yönetimi ─────────────────────────────────────────────────────────
  // Bilinen zararsız render hataları → sessizce yut (SizedBox.shrink).
  // Gerçek hatalar → logla + release'de TV'ye yakışır minimal hata widget'ı göster.
  // Debug modda orijinal Flutter kırmızı ekran korunur.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    final msg = details.exception.toString();

    // ── Sessizce susturulan bilinen zararsız hatalar ───────────────────────
    final silentPatterns = [
      'blur radius',
      'blurRadius',
      'RenderFlex overflowed'
    ];
    if (silentPatterns.any(msg.contains)) {
      return const SizedBox.shrink();
    }

    // ── Loglama (release dahil) ────────────────────────────────────────────
    // Hata tipini ayırt etmek için prefix kullanıyoruz.
    final isLayoutError = msg.contains('RenderBox') || msg.contains('layout');
    final isStateError = msg.contains('setState') || msg.contains('State');
    final prefix = isLayoutError
        ? '[Layout]'
        : isStateError
            ? '[State]'
            : '[Widget]';
    debugPrint('┌─ AladinError $prefix ──────────────────────────');
    debugPrint('│ ${details.exception}');
    debugPrint('│ ${details.context ?? "no context"}');
    if (!kReleaseMode) debugPrint('│ ${details.stack}');
    debugPrint('└────────────────────────────────────────────────');

    // ── Release: TV'ye yakışır minimal hata arayüzü ───────────────────────
    if (kReleaseMode) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        padding: const EdgeInsets.all(16),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white38, size: 28),
            SizedBox(height: 6),
            Text(
              'Görüntülenemiyor',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      );
    }

    // ── Debug: Standart Flutter kırmızı ekran ─────────────────────────────
    return ErrorWidget(details.exception);
  };

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // 🎬 TV PERFORMANS: Image cache'i TV için optimize et
  PaintingBinding.instance.imageCache.maximumSize = 40;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 24 << 20;

  runApp(const AladinApp());
}

class AladinApp extends StatefulWidget {
  const AladinApp({super.key});
  @override
  State<AladinApp> createState() => _AladinAppState();
}

class _AladinAppState extends State<AladinApp>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _phase = 0; // 0=splash, 1=language, 2=main
  late AnimationController _animCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
    _setupNativeListener();
    _boot();
  }

  void _setupNativeListener() {
    const MethodChannel('aladin/exoplayer').setMethodCallHandler((call) async {
      if (call.method == 'onFavoriteToggled') {
        final url = call.arguments['url'] as String?;
        final isFavorite = call.arguments['isFavorite'] as bool?;
        if (url != null && isFavorite != null) {
          await ChannelService.instance.setFavoriteByUrl(url, isFavorite);
          AppState.instance.refreshFavorites();
        }
      } else if (call.method == 'onProgressUpdate') {
        final url = call.arguments['url'] as String?;
        final pos = call.arguments['position'] as int? ?? 0;
        final dur = call.arguments['duration'] as int? ?? 0;
        if (url != null) {
          await ChannelService.instance.updateProgressByUrl(
            url,
            (pos / 1000).round(),
            (dur / 1000).round(),
          );
          final channel = await ChannelService.instance.getByUrl(url);
          if (channel != null && channel.contentType != 'tv') {
            await ChannelService.instance.addToWatchNext(channel);
          }
        }
      } else if (call.method == 'openSettings') {
        AppState.instance.navigateToPage(6);
      } else if (call.method == 'playUrl') {
        final url = call.arguments['url'] as String?;
        if (url != null) {
          AppState.instance.playByUrl(url);
        }
      } else if (call.method == 'playChannelId') {
        final rawId = call.arguments['id'];
        final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
        if (id != null) AppState.instance.playById(id);
      }
      return null;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      AladinPrefs.instance.flush();
    }
  }

  Future<void> _boot() async {
    // ⚡ BOOT SIRASI (Madde 3 — Race Condition fix):
    // AladinPrefs mutlaka ilk önce tamamlanmalı; AppState.init() ve IsarService
    // ona bağlı olduğundan sıralı başlatma zorunlu. Isar paralel başlatılabilir
    // çünkü Prefs'e bağımlı değil.
    await AladinPrefs.instance.load();
    AladinPrefs.instance.beginLaunchSession();
    await initDI();
    await Future.wait([
      IsarService.instance.init(),
      AppState.instance.init(), // Artık içinde load() yok, sadece okuma yapıyor
    ]);

    await ChannelService.instance.migrateParentalLocks();

    await AppState.instance.loadPlaylists();

    final hasLang = AladinPrefs.instance.getString('lang') != null;
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _phase = hasLang ? 2 : 1);
  }

  void _onLangSelected(String lang) async {
    await AppState.instance.setLang(lang);
    if (mounted) setState(() => _phase = 2);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AppState.instance),
        ChangeNotifierProvider.value(value: MetadataSyncService.instance),
        ChangeNotifierProvider.value(value: AladinEpgEngine.instance),
      ],
      child: ValueListenableBuilder<int>(
        valueListenable: AladinPrefs.instance.accessibilityRevision,
        builder: (context, _, __) {
          final highContrast =
              AladinPrefs.instance.getBool('accessibility_high_contrast');
          return MaterialApp(
            title: 'aladin IPTV Player Pro TV',
            debugShowCheckedModeBanner: false,
            theme:
                highContrast ? AppTheme.highContrastTheme : AppTheme.darkTheme,
            builder: (context, child) {
              final media = MediaQuery.of(context);
              final largeText =
                  AladinPrefs.instance.getBool('accessibility_large_text');
              return MediaQuery(
                data: media.copyWith(
                  textScaler: TextScaler.linear(largeText ? 1.16 : 1.0),
                  highContrast: highContrast,
                ),
                child: child!,
              );
            },
            home: FocusScope(
              autofocus: true,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: switch (_phase) {
                  1 => _LangSelect(onSelect: _onLangSelected),
                  2 => const MainPage(),
                  _ => _Splash(fade: _fade),
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  final Animation<double> fade;
  const _Splash({required this.fade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: FractionallySizedBox(
                  widthFactor: 0.72,
                  child: Image.asset(
                    'assets/images/app_logo_text_transparent.png',
                    fit: BoxFit.contain,
                    semanticLabel: 'aladin IPTV Player Pro TV',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangSelect extends StatelessWidget {
  final void Function(String) onSelect;
  const _LangSelect({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final langs = AppStrings.getLanguageNames();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF000000),
              Color(0xFF0A0A0A),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Süsleme amaçlı arka plan deseni (opsiyonel)
            Positioned(
              right: -100,
              top: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withValues(alpha: 0.05),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Premium Logo Alanı
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Image.asset(
                        'assets/images/app_logo_text_transparent.png',
                        fit: BoxFit.contain,
                        semanticLabel: 'aladin IPTV Player Pro TV',
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'Select Language / Dil Seçiniz',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Buton Izgarası
                    SizedBox(
                      width: 800, // TV genişliği için sınırla
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: langs.entries.map((e) {
                          final parts = e.value.split(' ');
                          final flag = parts[0];
                          final label = parts.skip(1).join(' ');

                          return _LangBtn(
                            flag: flag,
                            label: label,
                            autofocus: e.key ==
                                'en', // Kullanıcının isteği: İngilizce başta ve odaklı
                            onTap: () => onSelect(e.key),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangBtn extends StatefulWidget {
  final String flag, label;
  final VoidCallback onTap;
  final bool autofocus;

  const _LangBtn({
    required this.flag,
    required this.label,
    required this.onTap,
    this.autofocus = false,
  });

  @override
  State<_LangBtn> createState() => _LangBtnState();
}

class _LangBtnState extends State<_LangBtn>
    with SingleTickerProviderStateMixin {
  bool _focused = false;
  late AnimationController _scaleCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onFocus(bool v) {
    setState(() => _focused = v);
    if (v) {
      _scaleCtrl.forward();
    } else {
      _scaleCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: _onFocus,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 240, // Biraz daha daraltıp yan yana daha çok sığdıralım
            height: 72,
            decoration: BoxDecoration(
              color: _focused
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _focused ? Colors.white : Colors.white24,
                width: _focused ? 0 : 1,
              ),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.flag,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 14),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: _focused ? Colors.black : Colors.white,
                    fontSize: 18,
                    fontWeight: _focused ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
