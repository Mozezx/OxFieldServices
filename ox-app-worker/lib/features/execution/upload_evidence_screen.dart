import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/widgets/ox_button.dart';
import '../../l10n/app_localizations.dart';
import 'execution_provider.dart';

class UploadEvidenceScreen extends ConsumerStatefulWidget {
  const UploadEvidenceScreen({super.key, required this.phaseId});

  final String phaseId;

  @override
  ConsumerState<UploadEvidenceScreen> createState() =>
      _UploadEvidenceScreenState();
}

class _UploadEvidenceScreenState extends ConsumerState<UploadEvidenceScreen> {
  final _picker = ImagePicker();
  XFile? _selectedPhoto;
  XFile? _selectedVideo;
  Duration? _selectedVideoDuration;
  bool _isUploading = false;

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (file != null) {
        setState(() => _selectedPhoto = file);
      }
    } catch (_) {}
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final file = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 90),
      );
      if (file == null) return;

      final duration = await _readVideoDuration(file.path);
      if (!mounted) return;

      if (duration < const Duration(seconds: 30) ||
          duration > const Duration(seconds: 90)) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.uploadVideoDurationInvalid),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() {
        _selectedVideo = file;
        _selectedVideoDuration = duration;
      });
    } catch (_) {}
  }

  Future<Duration> _readVideoDuration(String path) async {
    final controller = VideoPlayerController.file(File(path));
    try {
      await controller.initialize();
      return controller.value.duration;
    } finally {
      await controller.dispose();
    }
  }

  Future<void> _uploadAll() async {
    if (_selectedPhoto == null || _selectedVideo == null) return;
    setState(() => _isUploading = true);

    try {
      await ref.read(evidenceUploadProvider.notifier).uploadEvidence(
            widget.phaseId,
            _selectedPhoto!.path,
            _resolveMimeType(_selectedPhoto!, fallback: 'image/jpeg'),
          );
      await ref.read(evidenceUploadProvider.notifier).uploadEvidence(
            widget.phaseId,
            _selectedVideo!.path,
            _resolveMimeType(_selectedVideo!, fallback: 'video/mp4'),
          );
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.uploadSuccess),
            backgroundColor: AppColors.accent,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.uploadError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  String _resolveMimeType(XFile file, {required String fallback}) {
    final lower = file.name.toLowerCase();
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return fallback;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final padded = seconds.toString().padLeft(2, '0');
    return '$minutes:$padded';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final selectedCount =
        (_selectedPhoto != null ? 1 : 0) + (_selectedVideo != null ? 1 : 0);
    final hasRequiredMedia = _selectedPhoto != null && _selectedVideo != null;
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          t.uploadTitle(selectedCount),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        children: [
          // Preview grid
          Expanded(
            child: selectedCount == 0
                ? Container(
                    decoration: const BoxDecoration(
                        gradient: AppGradients.surface),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.camera,
                              color: AppColors.textDisabled, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            t.uploadNoMediaSelected,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter',
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.uploadNeedPhotoAndVideo,
                            style: const TextStyle(
                              color: AppColors.textDisabled,
                              fontFamily: 'Inter',
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      if (_selectedPhoto != null)
                        _MediaPreviewCard(
                          title: t.uploadSelectedPhoto,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_selectedPhoto!.path),
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          onRemove: () => setState(() => _selectedPhoto = null),
                        ),
                      if (_selectedVideo != null)
                        _MediaPreviewCard(
                          title: _selectedVideoDuration == null
                              ? t.uploadSelectedVideo
                              : t.uploadSelectedVideoWithDuration(
                                  _formatDuration(_selectedVideoDuration!),
                                ),
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.surface2,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: const Center(
                              child: Icon(
                                LucideIcons.video,
                                color: AppColors.textSecondary,
                                size: 36,
                              ),
                            ),
                          ),
                          onRemove: () => setState(() {
                            _selectedVideo = null;
                            _selectedVideoDuration = null;
                          }),
                        ),
                    ],
                  ),
          ),

          // Bottom controls
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                  top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.camera),
                        icon: const Icon(LucideIcons.camera, size: 18),
                        label: Text(t.uploadTakePhoto),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.divider),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.gallery),
                        icon: const Icon(LucideIcons.image, size: 18),
                        label: Text(t.uploadFromGallery),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.divider),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickVideo(ImageSource.camera),
                        icon: const Icon(LucideIcons.video, size: 18),
                        label: Text(t.uploadRecordVideo),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.divider),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickVideo(ImageSource.gallery),
                        icon: const Icon(LucideIcons.folder, size: 18),
                        label: Text(t.uploadVideoFromGallery),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.divider),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OxButton(
                  label: _isUploading
                      ? t.uploadUploading
                      : t.uploadConfirmRequired,
                  icon: LucideIcons.upload,
                  isLoading: _isUploading,
                  onPressed: hasRequiredMedia ? _uploadAll : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaPreviewCard extends StatelessWidget {
  const _MediaPreviewCard({
    required this.title,
    required this.child,
    required this.onRemove,
  });

  final String title;
  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  LucideIcons.trash2,
                  size: 16,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}
