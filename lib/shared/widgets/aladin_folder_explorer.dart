// lib/shared/widgets/aladin_folder_explorer.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../core/state/aladin_app_state.dart';
import '../theme/aladin_app_theme.dart';

/// 📁 TV UYUMLU: Gelişmiş Dosya Gezgini
/// Tüm depolama birimlerinde (USB, SD Kart vb.) gezinme desteği
class AladinFolderExplorer extends StatefulWidget {
  const AladinFolderExplorer({super.key});

  @override
  State<AladinFolderExplorer> createState() => _AladinFolderExplorerState();
}

class _AladinFolderExplorerState extends State<AladinFolderExplorer> {
  List<FileSystemEntity> _items = [];
  bool _loading = true;
  String _currentPath = '';
  String? _error;
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
      await Permission.storage.request();
      
      // USB sürücüleri de görmek için /storage dizininden başla
      _browse('/storage');
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      _browse(appDir.path);
    }
  }

  Future<void> _browse(String path) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        if (path == '/storage') {
          _browse('/storage/emulated/0');
          return;
        }
        throw Exception('Dizin bulunamadı: $path');
      }

      final List<FileSystemEntity> entities = await dir.list().toList();
      
      final List<FileSystemEntity> dirs = [];
      final List<FileSystemEntity> files = [];

      for (var entity in entities) {
        try {
          final name = entity.path.split('/').last;
          if (name == 'self' || name == 'knox-emulated' || name.startsWith('.')) continue;

          if (entity is Directory) {
            dirs.add(entity);
          } else if (entity is File) {
            final ext = entity.path.toLowerCase();
            if (ext.endsWith('.m3u') || ext.endsWith('.m3u8')) {
              files.add(entity);
            }
          }
        } catch (_) {}
      }

      dirs.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
      files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

      setState(() {
        _currentPath = path;
        _items = [...dirs, ...files];
        _loading = false;
        _focusedIndex = 0;
      });
    } catch (e) {
      debugPrint('Folder Explorer Error: $e');
      if (path == '/storage') {
        _browse('/storage/emulated/0');
        return;
      }
      setState(() {
        _error = 'Erişim Hatası: $e';
        _loading = false;
      });
    }
  }

  void _goUp() {
    if (_currentPath == '/storage' || _currentPath == '/') return;
    final parent = Directory(_currentPath).parent;
    _browse(parent.path);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>().s;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.card,
        elevation: 0,
        title: Text(
          _currentPath == '/storage' ? s.allDrives : (_currentPath.split('/').last.isEmpty ? s.deviceFiles : _currentPath.split('/').last),
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.storage, color: AppTheme.accent),
            tooltip: s.allDrives,
            onPressed: () => _browse('/storage'),
          ),
          IconButton(
            icon: const Icon(Icons.home, color: AppTheme.textSecondary),
            tooltip: s.internalStorage,
            onPressed: () => _browse('/storage/emulated/0'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.card.withValues(alpha:0.5),
            child: Row(
              children: [
                const Icon(Icons.folder_open, color: AppTheme.textMuted, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentPath,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _loading 
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
              : _error != null
                ? _buildErrorView()
                : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    final s = context.read<AppState>().s;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () => _browse(_currentPath), child: Text(s.retry)),
          const SizedBox(height: 12),
          TextButton(onPressed: () => _browse('/storage/emulated/0'), child: Text(s.goInternal)),
        ],
      ),
    );
  }

  Widget _buildListView() {
    final s = context.read<AppState>().s;
    final isRoot = _currentPath == '/storage' || _currentPath == '/';

    return ListView.builder(
      itemCount: _items.length + (isRoot ? 0 : 1),
      itemBuilder: (context, index) {
        if (!isRoot && index == 0) {
          return _buildItem(
            title: s.upFolder,
            icon: Icons.drive_file_move_rtl,
            isFocused: _focusedIndex == 0,
            onTap: _goUp,
            onFocus: () => setState(() => _focusedIndex = 0),
          );
        }

        final itemIndex = isRoot ? index : index - 1;
        final item = _items[itemIndex];
        final isDir = item is Directory;
        final name = item.path.split('/').last;

        return _buildItem(
          title: name,
          icon: isDir ? Icons.folder : Icons.playlist_play,
          isFocused: _focusedIndex == index,
          onTap: () {
            if (isDir) {
              _browse(item.path);
            } else {
              Navigator.pop(context, item.path);
            }
          },
          onFocus: () => setState(() => _focusedIndex = index),
        );
      },
    );
  }

  Widget _buildItem({
    required String title,
    required IconData icon,
    required bool isFocused,
    required VoidCallback onTap,
    required VoidCallback onFocus,
  }) {
    return Focus(
      onFocusChange: (focused) {
        if (focused) onFocus();
      },
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.select)) {
          onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isFocused ? AppTheme.accent : AppTheme.card,
            borderRadius: BorderRadius.circular(8),
            border: isFocused ? Border.all(color: Colors.white, width: 2) : null,
            boxShadow: isFocused ? [BoxShadow(color: AppTheme.accent.withValues(alpha:0.4), blurRadius: 8)] : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: isFocused ? Colors.white : AppTheme.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isFocused ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (icon == Icons.folder)
                Icon(Icons.chevron_right, color: isFocused ? Colors.white : AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
