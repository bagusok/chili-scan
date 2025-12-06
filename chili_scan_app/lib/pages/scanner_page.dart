import 'package:chili_scan_app/common/constants/colors.dart';
import 'package:chili_scan_app/providers/get_predict_history_notifier.dart';
import 'package:chili_scan_app/services/predict_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  String? _selectedImageLabel;
  Uint8List? _previewBytes;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final sourceLabel = source == ImageSource.camera ? 'Kamera' : 'Galeri';
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _previewBytes = bytes;
        _selectedImageLabel =
            'Foto dari $sourceLabel (${DateTime.now().hour}:${DateTime.now().minute})';
      });

      _showSnackBar('Berhasil memilih gambar dari $sourceLabel');
    } on PlatformException catch (error) {
      _showSnackBar(
        'Gagal mengakses $sourceLabel: ${error.message ?? 'Coba ulangi'}',
        isError: true,
      );
    } catch (_) {
      _showSnackBar('Pilihan gambar dibatalkan', isError: true);
    }
  }

  Future<void> _sendToServer() async {
    if (_selectedImage == null || _isUploading) return;
    try {
      setState(() {
        _isUploading = true;
      });

      final apiService = ref.read(predictionServiceProvider);
      final response = await apiService.predict(image: _selectedImage!);

      ref.read(getPredictHistoryNotifierProvider.notifier).refresh();

      _showSnackBar('Gambar berhasil dikirim ke server!');
      context.go('/history/detail/${response.id}', extra: response);
    } catch (e) {
      _showSnackBar('Gagal mengirim gambar: $e', isError: true);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unggah Foto Cabai'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => {
            if (context.canPop())
              {context.pop()}
            else
              {context.replace('/home')},
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8F5FF), Color(0xFFFFFBF5)],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              _buildPreviewCard(theme),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 24),
              _buildInfoSteps(theme),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _selectedImage == null || _isUploading
                    ? null
                    : _sendToServer,
                icon: _isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_rounded),
                label: Text(_isUploading ? 'Mengirim...' : 'Kirim ke Server'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(ThemeData theme) {
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        spacing: 16,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.black12,
                style: BorderStyle.solid,
                width: 1.2,
              ),
              image: _previewBytes != null
                  ? DecorationImage(
                      image: MemoryImage(_previewBytes!),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1481396924383-d380ac23929a?auto=format&fit=crop&w=900&q=80',
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black26,
                        BlendMode.darken,
                      ),
                    ),
            ),
            child: _previewBytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.image_search_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Belum ada foto terpilih',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _selectedImageLabel ?? 'Foto siap dikirim',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
          ),
          Column(
            children: [
              Text(
                'Pastikan foto fokus pada cabai dan memiliki pencahayaan baik sebelum dikirimkan.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              if (_selectedImageLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Siap dikirim: $_selectedImageLabel',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.photo_camera_rounded),
            label: const Text('Ambil Foto'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Pilih Galeri'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSteps(ThemeData theme) {
    final steps = [
      _InfoStep(
        icon: Icons.photo_camera_front_rounded,
        title: 'Ambil foto 1 cabai',
        description: 'Pastikan resolusi tinggi dan objek memenuhi frame.',
      ),
      _InfoStep(
        icon: Icons.fact_check_rounded,
        title: 'Periksa ulang',
        description: 'Hapus foto buram atau terkena cahaya berlebih.',
      ),
      _InfoStep(
        icon: Icons.cloud_upload_rounded,
        title: 'Kirim dan tunggu hasil',
        description: 'Server akan menganalisis tingkat kematangan cabai kamu.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Langkah Pengambilan Foto',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...steps,
      ],
    );
  }
}

class _InfoStep extends StatelessWidget {
  const _InfoStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
