import 'package:flutter/foundation.dart';
import '../models/aladin_playlist_model.dart';
import '../models/aladin_channel_model.dart';
import '../services/aladin_playlist_service.dart';
import '../services/aladin_channel_service.dart';
import 'aladin_app_prefs.dart';
import 'aladin_app_strings.dart';

const aladinDemoPlaylists = <Map<String, String>>[];

class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  List<PlaylistModel> _playlists = [];
  PlaylistModel? _active;
  String _lang = 'tr';

  // Dizi bölümleri arasında paylaşılan metadata
  String? _activeSeriesPoster;
  String? _activeSeriesName;
  String? _activeSeriesOverview;

  List<PlaylistModel> get playlists => List.unmodifiable(_playlists);
  PlaylistModel? get active => _active;
  String get lang => _lang;
  bool get isTurkish => _lang == 'tr';
  AppStrings get s => AppStrings.of(_lang);

  String? get activeSeriesPoster => _activeSeriesPoster;
  String? get activeSeriesName => _activeSeriesName;
  String? get activeSeriesOverview => _activeSeriesOverview;

  Future<void> init() async {
    // ⚠️ Madde 3: Burada AladinPrefs.instance.load() ÇAĞRILMAZ.
    // main.dart'ta await ile önceden yüklendiği garanti edilmiştir.
    // Çift yükleme race condition'ına neden oluyordu.
    _lang = AladinPrefs.instance.getString('lang') ?? 'tr';
  }

  void setActiveSeriesMeta({String? poster, String? name, String? overview}) {
    _activeSeriesPoster = poster;
    _activeSeriesName = name;
    _activeSeriesOverview = overview;
  }

  Future<void> setLang(String l) async {
    _lang = l;
    await AladinPrefs.instance.setString('lang', l);
    notifyListeners();
  }

  Future<void> loadPlaylists() async {
    _playlists = await PlaylistService.instance.getAll();
    if (_active == null && _playlists.isNotEmpty) {
      _active = _playlists.first;
    } else if (_active != null) {
      final still = _playlists.firstWhere(
        (p) => p.id == _active!.id,
        orElse: () => _playlists.isNotEmpty ? _playlists.first : _active!,
      );
      _active = still;
    }
    if (_active == null || _playlists.isEmpty) {
      final savedId = AladinPrefs.instance.getInt('activePlaylistId');
      if (savedId != 0 && _playlists.isNotEmpty) {
        _active = _playlists.firstWhere(
          (p) => p.id == savedId,
          orElse: () => _playlists.first,
        );
      }
    }
    notifyListeners();
  }

  void selectPlaylist(PlaylistModel p) {
    _active = p;
    AladinPrefs.instance.setInt('activePlaylistId', p.id);
    notifyListeners();
  }

  void refreshFavorites() {
    notifyListeners();
  }

  int? _requestedIndex;
  int? get requestedIndex => _requestedIndex;

  ChannelModel? _requestedChannel;
  ChannelModel? get requestedChannel => _requestedChannel;

  void playByUrl(String url) async {
    final ch = await ChannelService.instance.getByUrl(url);
    if (ch != null) {
      _requestedChannel = ch;
      notifyListeners();
    }
  }

  void playById(int id) async {
    final ch = await ChannelService.instance.getById(id);
    if (ch != null) {
      _requestedChannel = ch;
      notifyListeners();
    }
  }

  void clearPlayRequest() {
    _requestedChannel = null;
  }

  void navigateToPage(int index) {
    _requestedIndex = index;
    notifyListeners();
  }

  void clearNavigationRequest() {
    _requestedIndex = null;
    // notifyListeners() ÇAĞIRILMAZ - rebuild döngüsünü engeller
  }

  Future<void> refresh() => loadPlaylists();

  ChannelModel? _focusedChannel;
  ChannelModel? get focusedChannel => _focusedChannel;

  void setFocusedChannel(ChannelModel? ch) {
    if (_focusedChannel?.id == ch?.id) return;
    _focusedChannel = ch;
    notifyListeners();
  }
}
