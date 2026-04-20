import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/theme/app_colors.dart';

class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({super.key, required this.onResult});

  final void Function(String text) onResult;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final _speech = SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _liveText = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
          if (_liveText.isNotEmpty) widget.onResult(_liveText);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() => _isAvailable = available);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _isListening = true;
        _liveText = '';
      });
      await _speech.listen(
        onResult: (result) {
          setState(() => _liveText = result.recognizedWords);
        },
        localeId: 'tr_TR',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: _isListening ? AppColors.accent : AppColors.primaryDim,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isListening ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
