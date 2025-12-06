import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ScannerCamera extends StatefulWidget {
  const ScannerCamera({super.key});

  @override
  State<ScannerCamera> createState() => _ScannerCameraState();
}

class _ScannerCameraState extends State<ScannerCamera>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _flashEnabled = false;
  bool _flashSupported = false;
  bool _isInitializingCamera = false;
  String? _cameraError;
  XFile? _capturedImage;
  Uint8List? _capturedPreviewBytes;
  bool _isSending = false;

  bool get _isCameraReady =>
      _controller != null && (_controller?.value.isInitialized ?? false);

  bool get _isFlashSupported => _isCameraReady && _flashSupported;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
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
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      setState(() {
        _controller = null;
        _flashSupported = false;
      });
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializingCamera = true;
      _cameraError = null;
      _flashSupported = false;
    });

    final previousController = _controller;
    _controller = null;
    await previousController?.dispose();

    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        setState(() {
          _cameraError = 'Perangkat tidak memiliki kamera.';
          _isInitializingCamera = false;
        });
        return;
      }

      final cameraDescription = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        cameraDescription,
        kIsWeb ? ResolutionPreset.high : ResolutionPreset.veryHigh,
        imageFormatGroup: kIsWeb
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.jpeg,
        enableAudio: false,
      );

      setState(() => _controller = controller);

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      var flashSupported = false;
      if (!kIsWeb) {
        try {
          await controller.setFlashMode(
            _flashEnabled ? FlashMode.torch : FlashMode.off,
          );
          flashSupported = true;
        } on CameraException {
          flashSupported = false;
          if (_flashEnabled) {
            setState(() => _flashEnabled = false);
          }
        }
      } else if (_flashEnabled) {
        setState(() => _flashEnabled = false);
      }

      setState(() {
        _flashSupported = flashSupported;
        _isInitializingCamera = false;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = e.description ?? 'Gagal membuka kamera (${e.code}).';
        _isInitializingCamera = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cameraError = 'Gagal membuka kamera.';
        _isInitializingCamera = false;
      });
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flash belum tersedia di Flutter Web.')),
      );
      return;
    }

    if (!_flashSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flash tidak tersedia untuk kamera ini.')),
      );
      return;
    }

    final nextState = !_flashEnabled;
    try {
      await controller.setFlashMode(
        nextState ? FlashMode.torch : FlashMode.off,
      );
      if (!mounted) return;
      setState(() => _flashEnabled = nextState);
    } on CameraException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah flash: ${e.description ?? e.code}'),
        ),
      );
    }
  }

  Future<void> _onCapturePressed() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamera belum siap untuk mengambil foto.'),
        ),
      );
      return;
    }

    if (controller.value.isTakingPicture) {
      return;
    }

    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _capturedImage = file;
        _capturedPreviewBytes = bytes;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: ${e.description ?? e.code}'),
        ),
      );
    }
  }

  void _onGalleryPressed() {
    // TODO: open gallery picker.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Buka galeri belum tersedia.')),
    );
  }

  void _retakeCapture() {
    setState(() {
      _capturedImage = null;
      _capturedPreviewBytes = null;
    });
  }

  Future<void> _sendToServer() async {
    final image = _capturedImage;
    if (image == null || _capturedPreviewBytes == null || _isSending) {
      return;
    }

    setState(() => _isSending = true);
    try {
      // TODO: Ganti dengan logika upload ke server.
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto dikirim ke server (dummy).')),
      );
      setState(() {
        _capturedImage = null;
        _capturedPreviewBytes = null;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim ke server.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Capture Cabai'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCameraLayer(),
                  const _CenterGuideOverlay(diameter: 260),
                  const _CaptureHint(),
                  if (_capturedImage != null && _capturedPreviewBytes != null)
                    _CapturedPreviewOverlay(
                      imageBytes: _capturedPreviewBytes!,
                      isSending: _isSending,
                      onRetake: _retakeCapture,
                      onSend: _sendToServer,
                    ),
                ],
              ),
            ),
            _CameraControls(
              flashEnabled: _flashEnabled,
              isFlashAvailable: _isFlashSupported,
              onFlashToggle: _isFlashSupported ? _toggleFlash : null,
              onCapture: _isCameraReady && _capturedImage == null
                  ? _onCapturePressed
                  : null,
              onGallery: _onGalleryPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraLayer() {
    if (_cameraError != null) {
      return _CameraErrorOverlay(
        message: _cameraError!,
        onRetry: () => _initializeCamera(),
      );
    }

    if (_isInitializingCamera) {
      return const _CameraLoadingOverlay();
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const _CameraPreviewPlaceholder();
    }

    return _CameraPreviewFeed(controller: controller);
  }
}

class _CameraPreviewPlaceholder extends StatelessWidget {
  const _CameraPreviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F2F2F), Color(0xFF0D0D0D)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: _gradientCircle(
              240,
              const Color(0xFFB71C1C).withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -10,
            child: _gradientCircle(
              200,
              const Color(0xFFFFEB3B).withOpacity(0.25),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.camera_alt_rounded, color: Colors.white54, size: 64),
                SizedBox(height: 12),
                Text(
                  'Tampilan kamera akan muncul di sini',
                  style: TextStyle(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _CaptureHint extends StatelessWidget {
  const _CaptureHint();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Posisikan cabai di dalam lingkaran',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Pastikan cabai memenuhi area lingkaran agar hasil scan akurat.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraControls extends StatelessWidget {
  const _CameraControls({
    required this.flashEnabled,
    required this.isFlashAvailable,
    required this.onFlashToggle,
    required this.onCapture,
    required this.onGallery,
  });

  final bool flashEnabled;
  final bool isFlashAvailable;
  final VoidCallback? onFlashToggle;
  final VoidCallback? onCapture;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final captureEnabled = onCapture != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundedIconButton(
            icon: Icons.photo_library_outlined,
            label: 'Galeri',
            onTap: onGallery,
          ),
          GestureDetector(
            onTap: onCapture,
            child: Opacity(
              opacity: captureEnabled ? 1 : 0.35,
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.45),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.camera, color: Colors.white, size: 36),
              ),
            ),
          ),
          _RoundedIconButton(
            icon: flashEnabled ? Icons.flash_on : Icons.flash_off,
            label: 'Flash',
            onTap: onFlashToggle,
            enabled: isFlashAvailable,
          ),
        ],
      ),
    );
  }
}

class _RoundedIconButton extends StatelessWidget {
  const _RoundedIconButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = enabled ? onTap : null;
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: GestureDetector(
        onTap: effectiveOnTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterGuideOverlay extends StatelessWidget {
  const _CenterGuideOverlay({required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _HoleOverlayPainter(diameter: diameter)),
          Center(
            child: Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a dimmed overlay while punching a transparent hole in the middle.
class _HoleOverlayPainter extends CustomPainter {
  _HoleOverlayPainter({required this.diameter});

  final double diameter;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.55);

    final rect = Offset.zero & size;
    final path = Path()..addRect(rect);
    final circlePath = Path()
      ..addOval(
        Rect.fromCircle(center: size.center(Offset.zero), radius: diameter / 2),
      );

    canvas.saveLayer(rect, Paint());
    canvas.drawPath(path, overlayPaint);
    canvas.drawPath(circlePath, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HoleOverlayPainter oldDelegate) {
    return oldDelegate.diameter != diameter;
  }
}

class _CameraPreviewFeed extends StatelessWidget {
  const _CameraPreviewFeed({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final previewSize = controller.value.previewSize;
        final width = previewSize != null
            ? previewSize.height
            : constraints.maxWidth;
        final height = previewSize != null
            ? previewSize.width
            : constraints.maxHeight;
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: width,
            height: height,
            child: CameraPreview(controller),
          ),
        );
      },
    );
  }
}

class _CameraLoadingOverlay extends StatelessWidget {
  const _CameraLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.deepOrangeAccent),
      ),
    );
  }
}

class _CameraErrorOverlay extends StatelessWidget {
  const _CameraErrorOverlay({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapturedPreviewOverlay extends StatelessWidget {
  const _CapturedPreviewOverlay({
    required this.imageBytes,
    required this.onSend,
    required this.onRetake,
    required this.isSending,
  });

  final Uint8List imageBytes;
  final Future<void> Function() onSend;
  final VoidCallback onRetake;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Image.memory(imageBytes, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Pastikan hasil foto sudah sesuai sebelum mengirimnya.',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSending ? null : onRetake,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                  ),
                  child: const Text('Ganti Gambar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSending ? null : onSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Kirim ke Server'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
