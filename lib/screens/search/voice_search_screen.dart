import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/theme.dart';

class VoiceSearchScreen extends StatefulWidget {
  const VoiceSearchScreen({super.key});

  @override
  State<VoiceSearchScreen> createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen>
    with TickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;
  String _recognizedText = '';
  String _statusText = '마이크를 탭해서 시작하세요';

  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: _onStatus,
      onError: (e) {
        setState(() {
          _isListening = false;
          _statusText = '오류가 발생했습니다. 다시 시도해주세요.';
        });
        _stopAnimations();
      },
    );
    setState(() {
      _isInitialized = available;
      if (!available) _statusText = '음성 인식을 사용할 수 없습니다';
    });
  }

  void _onStatus(String status) {
    if (status == 'notListening' || status == 'done') {
      if (mounted) {
        setState(() => _isListening = false);
        _stopAnimations();
        if (_recognizedText.isEmpty) {
          setState(() => _statusText = '인식된 내용이 없습니다. 다시 시도해주세요.');
        }
      }
    }
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) return;

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      _stopAnimations();
    } else {
      setState(() {
        _recognizedText = '';
        _statusText = '듣고 있어요...';
        _isListening = true;
      });
      _startAnimations();

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            if (_recognizedText.isNotEmpty) {
              _statusText = '인식된 내용을 확인해주세요';
            }
          });
        },
        localeId: 'ko-KR',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _pulseController.animateTo(0);
    _waveController.stop();
    _waveController.reset();
  }

  void _onSearch() {
    if (_recognizedText.isEmpty) return;
    Navigator.pop(context, _recognizedText);
  }

  @override
  void dispose() {
    _speech.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '음성 검색',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          _StatusText(text: _statusText, isListening: _isListening),
          const SizedBox(height: 48),
          Center(
            child: _MicButton(
              isListening: _isListening,
              isInitialized: _isInitialized,
              pulseAnim: _pulseAnim,
              waveController: _waveController,
              onTap: _toggleListening,
            ),
          ),
          const SizedBox(height: 40),
          _RecognizedTextArea(text: _recognizedText),
          const Spacer(flex: 3),
          if (_recognizedText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXxl),
              child: _SearchButton(onTap: _onSearch),
            ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// ─── 상태 텍스트 ────────────────────────────────────────────
class _StatusText extends StatelessWidget {
  const _StatusText({required this.text, required this.isListening});
  final String text;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: TextStyle(
          fontSize: 16,
          color: isListening
              ? AppColors.searchVoicePrimary
              : Colors.white.withValues(alpha: 0.6),
          fontWeight: isListening ? FontWeight.w600 : FontWeight.w400,
        ),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}

// ─── 마이크 버튼 ────────────────────────────────────────────
class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.isListening,
    required this.isInitialized,
    required this.pulseAnim,
    required this.waveController,
    required this.onTap,
  });

  final bool isListening;
  final bool isInitialized;
  final Animation<double> pulseAnim;
  final AnimationController waveController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isInitialized ? onTap : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isListening) ...[
            _WaveRing(controller: waveController, delay: 0.0, size: 160),
            _WaveRing(controller: waveController, delay: 0.33, size: 140),
            _WaveRing(controller: waveController, delay: 0.66, size: 120),
          ],
          ScaleTransition(
            scale: isListening ? pulseAnim : const AlwaysStoppedAnimation(1.0),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isListening
                    ? AppColors.searchVoicePrimary
                    : (isInitialized
                        ? const Color(0xFF2D2D4E)
                        : Colors.grey.shade800),
                boxShadow: isListening
                    ? [
                        BoxShadow(
                          color:
                              AppColors.searchVoicePrimary.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        )
                      ]
                    : null,
              ),
              child: Icon(
                isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveRing extends StatelessWidget {
  const _WaveRing({
    required this.controller,
    required this.delay,
    required this.size,
  });
  final AnimationController controller;
  final double delay;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final progress = (controller.value + delay) % 1.0;
        final opacity = (1.0 - progress).clamp(0.0, 0.35);
        final scale = 1.0 + progress * (200 / size - 1);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.searchVoicePrimary.withValues(alpha: opacity),
            ),
          ),
        );
      },
    );
  }
}

// ─── 인식된 텍스트 ──────────────────────────────────────────
class _RecognizedTextArea extends StatelessWidget {
  const _RecognizedTextArea({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXxl),
      padding: text.isEmpty
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingXxl,
              vertical: AppDimensions.paddingLg,
            ),
      decoration: BoxDecoration(
        color: text.isEmpty
            ? Colors.transparent
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: text.isEmpty
          ? const SizedBox.shrink()
          : Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.4,
              ),
            ),
    );
  }
}

// ─── 검색 버튼 ──────────────────────────────────────────────
class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.search_rounded, size: 20),
        label: const Text(
          '이 내용으로 검색',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.searchVoicePrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

