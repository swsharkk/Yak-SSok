import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/backend_auth_service.dart';

class ParsedDrug {
  const ParsedDrug({
    required this.name,
    required this.dailyFrequency,
    required this.durationDays,
  });

  final String name;
  final int dailyFrequency;
  final int durationDays;

  factory ParsedDrug.fromJson(Map<String, dynamic> json) => ParsedDrug(
        name: json['drug_name']?.toString() ?? '',
        dailyFrequency: (json['daily_frequency'] as num?)?.toInt() ?? 1,
        durationDays: (json['duration_days'] as num?)?.toInt() ?? 0,
      );
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isBusy = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = '사용 가능한 카메라가 없습니다.');
        return;
      }
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _isInitialized = true;
      });
    } catch (e) {
      setState(() => _errorMessage = '카메라를 열 수 없습니다.');
    }
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isBusy) return;

    setState(() => _isBusy = true);
    try {
      final file = await controller.takePicture();
      await _processImage(file.path);
    } catch (_) {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isBusy) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _isBusy = true);
    await _processImage(picked.path);
  }

  Future<void> _processImage(String imagePath) async {
    // ── ML Kit 방식 (실기기에서 사용 가능, iOS 26 시뮬레이터 arm64 미지원) ──
    // import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
    // pubspec.yaml에 google_mlkit_text_recognition: ^0.13.0 추가 후 pod install 필요
    //
    // String rawText;
    // try {
    //   final recognizer = TextRecognizer(script: TextRecognitionScript.korean);
    //   final inputImage = InputImage.fromFilePath(imagePath);
    //   final recognized = await recognizer.processImage(inputImage);
    //   await recognizer.close();
    //   rawText = recognized.text.trim();
    // } catch (e) {
    //   if (mounted) {
    //     _showError('텍스트 인식 중 오류가 발생했습니다.');
    //     setState(() => _isBusy = false);
    //   }
    //   return;
    // }
    // if (rawText.isEmpty) {
    //   if (mounted) {
    //     _showError('텍스트를 인식하지 못했습니다. 다시 촬영해 주세요.');
    //     setState(() => _isBusy = false);
    //   }
    //   return;
    // }
    // → 이후 data: {'raw_text': rawText} 로 전송
    // ────────────────────────────────────────────────────────────────────────

    // 현재 방식: 이미지 → base64 → Gemini Vision (시뮬레이터/실기기 모두 동작)
    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    try {
      final options = await BackendAuthService.authOptions();
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
      ));

      final response = await dio.post<Map<String, dynamic>>(
        '/api/parse-prescription',
        data: {'image_base64': base64Image},
        options: options,
      );

      final body = response.data ?? {};
      if (body['status'] != 'success') {
        throw Exception(body['message'] ?? '파싱 실패');
      }

      final drugs = (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(ParsedDrug.fromJson)
          .where((d) => d.name.isNotEmpty)
          .toList();

      if (!mounted) return;
      Navigator.pop(context, drugs);
    } catch (e) {
      if (mounted) {
        _showError('AI 분석 중 오류가 발생했습니다.\n${e.toString().replaceFirst('Exception: ', '')}');
        setState(() => _isBusy = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.alertPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_errorMessage != null || !_isInitialized)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.no_photography_rounded,
                      color: Colors.white38, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage ?? '카메라를 불러오는 중...',
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '갤러리에서 사진을 선택할 수 있어요',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ],
              ),
            )
          else
            CameraPreview(_controller!),

          if (_isInitialized && !_isBusy)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.width * 0.85 * 0.6,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.progressTeal, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '약 봉투를 네모 안에 맞춰주세요',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ),
            ),

          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: _isBusy
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.progressTeal),
                      SizedBox(height: 12),
                      Text('AI가 분석 중입니다...',
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white54, width: 1.5),
                          ),
                          child: const Icon(Icons.photo_library_rounded,
                              color: Colors.white, size: 26),
                        ),
                      ),
                      const SizedBox(width: 40),
                      GestureDetector(
                        onTap: _isInitialized ? _takePicture : null,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: _isInitialized ? Colors.white : Colors.white24,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Icon(Icons.camera_alt_rounded,
                              color: _isInitialized ? Colors.black : Colors.white38,
                              size: 36),
                        ),
                      ),
                      const SizedBox(width: 92),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
