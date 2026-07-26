import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/aladin_parental_service.dart';
import '../theme/aladin_app_theme.dart';

/// Requests the parental PIN when [protectedContent] is true.
Future<bool> requestParentalUnlock(
  BuildContext context, {
  required bool protectedContent,
  String? title,
}) async {
  final parental = ParentalService.instance;
  if (!protectedContent || parental.isSessionUnlocked) return true;
  final controller = TextEditingController();
  final confirmNode = FocusNode(debugLabel: 'parental_confirm');
  String? error;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        Future<void> verify() async {
          final cooldown = parental.remainingCooldown;
          if (cooldown != null) {
            setDialogState(() => error =
                '${cooldown.inSeconds + 1} saniye sonra tekrar deneyin.');
            return;
          }
          if (await parental.verifyPin(controller.text)) {
            if (dialogContext.mounted) Navigator.pop(dialogContext, true);
          } else {
            controller.clear();
            setDialogState(() => error = 'PIN yanlış.');
          }
        }

        return AlertDialog(
          backgroundColor: AppTheme.card,
          title: Text(title ?? 'Kilitli içerik'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Devam etmek için ebeveyn PIN kodunu girin.'),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onSubmitted: (_) => verify(),
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    errorText: error,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('İptal'),
            ),
            FilledButton(
              focusNode: confirmNode,
              autofocus: true,
              onPressed: verify,
              style: FilledButton.styleFrom(backgroundColor: AppTheme.accent),
              child: const Text('Kilidi Aç'),
            ),
          ],
        );
      },
    ),
  );
  controller.dispose();
  confirmNode.dispose();
  return result ?? false;
}
