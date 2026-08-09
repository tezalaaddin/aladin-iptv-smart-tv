import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/aladin_channel_model.dart';
import '../../core/services/aladin_channel_service.dart';
import '../../core/services/aladin_parental_service.dart';
import '../../core/services/aladin_content_visibility_service.dart';
import '../../core/services/aladin_favorite_collection_service.dart';
import '../../core/state/aladin_app_prefs.dart';
import '../../core/state/aladin_app_state.dart';
import '../theme/aladin_app_theme.dart';
import 'aladin_parental_gate.dart';

Future<bool> showAladinChannelOptions(
    BuildContext context, ChannelModel channel) async {
  final s = context.read<AppState>().s;
  final scope = '${channel.playlistId}_${channel.id}';
  final changed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      backgroundColor: AppTheme.card,
      title: Text(channel.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      children: [
        SimpleDialogOption(
          onPressed: () async {
            Navigator.pop(dialogContext);
            final controller = TextEditingController();
            final name = await showDialog<String>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.card,
                title: Text(s.v52('favoriteCollection')),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration:
                      InputDecoration(hintText: s.v52('collectionHint')),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(s.cancel)),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, controller.text),
                      child: Text(s.save)),
                ],
              ),
            );
            if (name != null && name.trim().isNotEmpty) {
              if (!channel.isFavorite) {
                await ChannelService.instance.toggleFavorite(channel.id);
                channel.isFavorite = true;
              }
              await FavoriteCollectionService.instance.add(name, channel);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        s.v52('collectionAdded').replaceAll('{name}', name))));
              }
            }
          },
          child: ListTile(
            leading: const Icon(Icons.create_new_folder_outlined),
            title: Text(s.v52('addToCollection')),
          ),
        ),
        SimpleDialogOption(
          onPressed: () async {
            await ContentVisibilityService.instance.hideChannel(channel);
            if (dialogContext.mounted) Navigator.pop(dialogContext, true);
          },
          child: ListTile(
            leading: const Icon(Icons.visibility_off_outlined),
            title: Text(s.v49('hideContent')),
          ),
        ),
        SimpleDialogOption(
          onPressed: () async {
            Navigator.pop(dialogContext);
            final parental = ParentalService.instance;
            if (!parental.isEnabled) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${s.v49('parental')}: ${s.off}')));
              }
              return;
            }
            final allowed = await requestParentalUnlock(context,
                protectedContent: true, title: s.v49('parental'));
            if (!allowed) return;
            final locked = await parental.toggleChannelLock(channel);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(locked ? s.v49('lockedContent') : s.v49('unlock'))));
            }
          },
          child: ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(s.v49('parental')),
          ),
        ),
        SimpleDialogOption(
          onPressed: () async {
            await ChannelService.instance.toggleFavorite(channel.id);
            if (dialogContext.mounted) Navigator.pop(dialogContext, true);
          },
          child: ListTile(
            leading: Icon(
                channel.isFavorite ? Icons.favorite : Icons.favorite_border),
            title: Text(s.favorites),
          ),
        ),
        SimpleDialogOption(
          onPressed: () async {
            final current =
                AladinPrefs.instance.getString('channel_decoder_$scope') ??
                    'auto';
            const values = ['auto', 'hw', 'sw'];
            final next = values[(values.indexOf(current) + 1) % values.length];
            await AladinPrefs.instance
                .setString('channel_decoder_$scope', next);
            if (dialogContext.mounted) Navigator.pop(dialogContext, false);
          },
          child: ListTile(
            leading: const Icon(Icons.memory),
            title: Text(s.decoderMode),
            subtitle: const Text('Auto → HW → SW'),
          ),
        ),
        SimpleDialogOption(
          onPressed: () async {
            final current =
                AladinPrefs.instance.getString('channel_quality_$scope') ??
                    'auto';
            const values = ['auto', '4k', 'fhd', 'hd', 'sd'];
            final next = values[(values.indexOf(current) + 1) % values.length];
            await AladinPrefs.instance
                .setString('channel_quality_$scope', next);
            if (dialogContext.mounted) Navigator.pop(dialogContext, false);
          },
          child: ListTile(
            leading: const Icon(Icons.high_quality),
            title: Text(s.quality),
            subtitle: const Text('Auto → 4K → FHD → HD → SD'),
          ),
        ),
      ],
    ),
  );
  return changed ?? false;
}
