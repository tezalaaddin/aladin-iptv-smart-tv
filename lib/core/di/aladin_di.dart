import 'package:get_it/get_it.dart';
import '../database/aladin_isar_service.dart';
import '../services/aladin_channel_service.dart';
import '../services/aladin_playlist_service.dart';
import '../services/aladin_epg_engine.dart';
import '../services/aladin_epg_service.dart';
import '../services/aladin_metadata_sync_service.dart';
import '../services/aladin_tmdb_service.dart';
import '../services/aladin_update_service.dart';
import '../services/aladin_parental_service.dart';
import '../state/aladin_app_prefs.dart';
import '../state/aladin_app_state.dart';

final sl = GetIt.instance; // sl: Service Locator

Future<void> initDI() async {
  // ── Preferences ──────────────────────────────────────────────────────────
  sl.registerSingleton<AladinPrefs>(AladinPrefs.instance);

  // ── Database ──────────────────────────────────────────────────────────────
  sl.registerSingleton<IsarService>(IsarService.instance);

  // ── Services ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChannelService>(() => ChannelService.instance);
  sl.registerLazySingleton<PlaylistService>(() => PlaylistService.instance);
  sl.registerLazySingleton<EpgService>(() => EpgService.instance);
  sl.registerLazySingleton<TmdbService>(() => TmdbService.instance);
  sl.registerLazySingleton<UpdateService>(() => UpdateService.instance);
  sl.registerLazySingleton<ParentalService>(() => ParentalService.instance);

  // ── Engines & State ───────────────────────────────────────────────────────
  sl.registerSingleton<AladinEpgEngine>(AladinEpgEngine.instance);
  sl.registerSingleton<MetadataSyncService>(MetadataSyncService.instance);
  sl.registerSingleton<AppState>(AppState.instance);
}
