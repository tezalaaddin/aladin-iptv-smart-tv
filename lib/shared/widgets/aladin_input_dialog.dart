import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/state/aladin_app_state.dart';
import '../theme/aladin_app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AladinField  (veri modeli — değişmedi)
// ─────────────────────────────────────────────────────────────────────────────
class AladinField {
  final String label;
  final String? initialValue;
  final String? hint;
  final bool obscure;
  final IconData icon;
  final String? prefix;

  AladinField({
    required this.label,
    this.initialValue,
    this.hint,
    this.obscure = false,
    required this.icon,
    this.prefix,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// AladinFormDialog  (çok alanlı form diyaloğu)
// ─────────────────────────────────────────────────────────────────────────────
class AladinFormDialog extends StatefulWidget {
  final String title;
  final List<AladinField> fields;
  final String? confirmLabel;
  final String? cancelLabel;

  const AladinFormDialog({
    super.key,
    required this.title,
    required this.fields,
    this.confirmLabel,
    this.cancelLabel,
  });

  @override
  State<AladinFormDialog> createState() => _AladinFormDialogState();
}

class _AladinFormDialogState extends State<AladinFormDialog> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _fieldNodes;
  final FocusNode _confirmNode = FocusNode(debugLabel: 'form_confirm');

  // Debounce — bazı TV'lerde Back tuşu hızlı çift ateşleniyor
  DateTime? _lastBackTime;
  static const _kDebounce = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _controllers = widget.fields
        .map((f) => TextEditingController(text: f.initialValue))
        .toList();
    _fieldNodes = widget.fields.map((_) => FocusNode()).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_fieldNodes.isNotEmpty) _openKeyboard(_fieldNodes[0]);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final n in _fieldNodes) n.dispose();
    _confirmNode.dispose();
    super.dispose();
  }

  // ── Klavye aç ──────────────────────────────────────────────────────────────
  Future<void> _openKeyboard(FocusNode node) async {
    node.requestFocus();
    await Future.delayed(const Duration(milliseconds: 80));
    await SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  // ── Klavyeyi kapat ─────────────────────────────────────────────────────────
  Future<void> _closeKeyboard() async {
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  // ── Herhangi bir alan focused mı? ──────────────────────────────────────────
  bool get _anyFieldFocused => _fieldNodes.any((n) => n.hasFocus);

  // ── Klavye gerçekten açık mı? (OS seviyesi) ───────────────────────────────
  bool _isKeyboardVisible(BuildContext ctx) =>
      MediaQuery.of(ctx).viewInsets.bottom > 50;

  // ──────────────────────────────────────────────────────────────────────────
  // BACK tuşu state-machine  ← Tüm cihazlarda tek tutarlı davranış
  //
  //  Durum 1 → Klavye açık   : klavyeyi kapat, focus değiştirme, dialog açık kal
  //  Durum 2 → Alan focused  : odağı Confirm butonuna taşı, dialog açık kal
  //  Durum 3 → Alan focused değil: dialog kapat
  // ──────────────────────────────────────────────────────────────────────────
  void _onBack(BuildContext ctx) {
    final now = DateTime.now();
    if (_lastBackTime != null && now.difference(_lastBackTime!) < _kDebounce) {
      return; // Çift ateşlenmeyi engelle
    }
    _lastBackTime = now;

    if (_isKeyboardVisible(ctx)) {
      // Durum 1: önce sadece klavyeyi kapat
      _closeKeyboard();
      return;
    }

    if (_anyFieldFocused) {
      // Durum 2: klavye kapandı ama alan hâlâ focused → Confirm'e taşı
      _confirmNode.requestFocus();
      return;
    }

    // Durum 3: Confirm veya Cancel focused → diyaloğu kapat
    if (ctx.mounted) Navigator.of(ctx).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = context.read<AppState>().s;

    return PopScope(
      // canPop: false → Sistemi tamamen devre dışı bırak,
      // her Back olayı onPopInvokedWithResult üzerinden geçer.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack(context);
      },
      child: Focus(
        // Focus katmanı da dinliyor — bazı TV'lerde PopScope'a ulaşmadan
        // KeyEvent seviyesinde tetiklenebiliyor.
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.escape ||
                  event.logicalKey == LogicalKeyboardKey.goBack)) {
            _onBack(context);
            return KeyEventResult.handled; // Her zaman tüket
          }
          return KeyEventResult.ignored;
        },
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.9),
          body: Center(
            child: Container(
              width: 600,
              constraints: BoxConstraints(maxHeight: size.height * 0.95),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Başlık ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 32, 32, 8),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  // ── Alanlar ─────────────────────────────────────────────
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          widget.fields.length,
                          (i) => _buildField(context, i),
                        ),
                      ),
                    ),
                  ),
                  // ── Butonlar ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _DialogBtn(
                          label: widget.cancelLabel ?? s.cancel,
                          isPrimary: false,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 16),
                        _DialogBtn(
                          label: widget.confirmLabel ?? s.save,
                          isPrimary: true,
                          focusNode: _confirmNode,
                          onTap: () => Navigator.of(context)
                              .pop(_controllers.map((c) => c.text).toList()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, int i) {
    final field = widget.fields[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _controllers[i],
            focusNode: _fieldNodes[i],
            onTap: () => _openKeyboard(_fieldNodes[i]),
            obscureText: field.obscure,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: field.hint,
              prefixText: field.prefix,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixStyle: const TextStyle(color: AppTheme.accent),
              prefixIcon:
                  Icon(field.icon, color: Colors.white24, size: 20),
              filled: true,
              fillColor: AppTheme.card,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.accent, width: 2)),
            ),
            onSubmitted: (_) {
              if (i < widget.fields.length - 1) {
                _fieldNodes[i + 1].requestFocus();
              } else {
                _confirmNode.requestFocus();
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AladinInputDialog  (tek alanlı input diyaloğu)
// ─────────────────────────────────────────────────────────────────────────────
class AladinInputDialog extends StatefulWidget {
  final String title;
  final String? initialValue;
  final String? hint;
  final bool obscure;
  final String? confirmLabel;
  final String? cancelLabel;
  final IconData? icon;

  const AladinInputDialog({
    super.key,
    required this.title,
    this.initialValue,
    this.hint,
    this.obscure = false,
    this.confirmLabel,
    this.cancelLabel,
    this.icon,
  });

  @override
  State<AladinInputDialog> createState() => _AladinInputDialogState();
}

class _AladinInputDialogState extends State<AladinInputDialog> {
  late TextEditingController _controller;
  final FocusNode _fieldNode = FocusNode(debugLabel: 'input_field');
  final FocusNode _confirmNode = FocusNode(debugLabel: 'input_confirm');
  final FocusNode _micNode = FocusNode(debugLabel: 'input_mic');

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  DateTime? _lastBackTime;
  static const _kDebounce = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _initSpeech();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _openKeyboard(_fieldNode));
  }

  void _initSpeech() async {
    try {
      await _speech.initialize();
    } catch (_) {}
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _lastWords = val.recognizedWords;
              if (_lastWords.isNotEmpty) {
                _controller.text = _lastWords;
              }
            });
            if (val.finalResult) {
              setState(() => _isListening = false);
            }
          },
        );
      }
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    _fieldNode.dispose();
    _confirmNode.dispose();
    _micNode.dispose();
    super.dispose();
  }

  Future<void> _openKeyboard(FocusNode node) async {
    node.requestFocus();
    await Future.delayed(const Duration(milliseconds: 80));
    await SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  Future<void> _closeKeyboard() async {
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  bool _isKeyboardVisible(BuildContext ctx) =>
      MediaQuery.of(ctx).viewInsets.bottom > 50;

  void _onBack(BuildContext ctx) {
    final now = DateTime.now();
    if (_lastBackTime != null && now.difference(_lastBackTime!) < _kDebounce) {
      return;
    }
    _lastBackTime = now;

    if (_isKeyboardVisible(ctx)) {
      // Durum 1: Klavye açık → sadece klavyeyi kapat
      _closeKeyboard();
      return;
    }

    if (_fieldNode.hasFocus) {
      // Durum 2: Klavye kapandı, alan hâlâ focused → Confirm'e taşı
      _confirmNode.requestFocus();
      return;
    }

    // Durum 3: Confirm/Cancel focused → diyaloğu kapat
    if (ctx.mounted) Navigator.of(ctx).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = context.read<AppState>().s;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack(context);
      },
      child: Focus(
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.escape ||
                  event.logicalKey == LogicalKeyboardKey.goBack)) {
            _onBack(context);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.9),
          body: Center(
            child: Container(
              width: 500,
              constraints: BoxConstraints(maxHeight: size.height * 0.95),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Başlık ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 32, 32, 8),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  // ── Input alanı ─────────────────────────────────────────
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _fieldNode,
                              onTap: () => _openKeyboard(_fieldNode),
                              obscureText: widget.obscure,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                              decoration: InputDecoration(
                                hintText: widget.hint,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                prefixIcon: widget.icon != null
                                    ? Icon(widget.icon,
                                        color: AppTheme.accent, size: 20)
                                    : null,
                                filled: true,
                                fillColor: AppTheme.card,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: AppTheme.accent, width: 2)),
                              ),
                              onSubmitted: (_) => _confirmNode.requestFocus(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _MicBtn(
                            focusNode: _micNode,
                            isListening: _isListening,
                            onTap: _toggleListening,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ── Butonlar ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _DialogBtn(
                          label: widget.cancelLabel ?? s.cancel,
                          isPrimary: false,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 16),
                        _DialogBtn(
                          label: widget.confirmLabel ?? s.done,
                          isPrimary: true,
                          focusNode: _confirmNode,
                          onTap: () =>
                              Navigator.of(context).pop(_controller.text),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MicBtn extends StatefulWidget {
  final FocusNode focusNode;
  final bool isListening;
  final VoidCallback onTap;

  const _MicBtn({
    required this.focusNode,
    required this.isListening,
    required this.onTap,
  });

  @override
  State<_MicBtn> createState() => _MicBtnState();
}

class _MicBtnState extends State<_MicBtn> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (_, event) {
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: widget.isListening
                ? Colors.redAccent
                : (_focused ? Colors.white : AppTheme.card),
            shape: BoxShape.circle,
            border: Border.all(
              color: _focused ? Colors.white : Colors.transparent,
              width: 2,
            ),
            boxShadow: _focused || widget.isListening
                ? [
                    BoxShadow(
                        color: (widget.isListening ? Colors.redAccent : Colors.white)
                            .withOpacity(0.3),
                        blurRadius: 15)
                  ]
                : null,
          ),
          child: Icon(
            widget.isListening ? Icons.stop : Icons.mic,
            color: widget.isListening
                ? Colors.white
                : (_focused ? Colors.black : Colors.white54),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DialogBtn  (paylaşılan buton widget'ı — değişmedi)
// ─────────────────────────────────────────────────────────────────────────────
class _DialogBtn extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;
  final FocusNode? focusNode;

  const _DialogBtn({
    required this.label,
    required this.isPrimary,
    required this.onTap,
    this.focusNode,
  });

  @override
  State<_DialogBtn> createState() => _DialogBtnState();
}

class _DialogBtnState extends State<_DialogBtn> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (_, event) {
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          transform: Matrix4.identity()..scale(_focused ? 1.05 : 1.0),
          decoration: BoxDecoration(
            color: _focused
                ? Colors.white
                : (widget.isPrimary ? AppTheme.accent : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focused
                  ? Colors.white
                  : (widget.isPrimary
                      ? AppTheme.accent
                      : Colors.white24),
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 1)
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _focused ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
