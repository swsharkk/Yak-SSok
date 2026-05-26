import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isTaking = false;
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
        ResolutionPreset.high,
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
    if (controller == null || !controller.value.isInitialized || _isTaking) return;

    setState(() => _isTaking = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      Navigator.pop(context, file.path);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isTaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_errorMessage != null)
            Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          else if (!_isInitialized)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            CameraPreview(_controller!),
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
          if (_isInitialized)
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _isTaking ? null : _takePicture,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: _isTaking
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: AppColors.progressTeal,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.camera_alt_rounded,
                            color: Colors.black, size: 36),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
