import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
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
  final List<XFile> _selectedFiles = [];
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (file != null) {
        setState(() => _selectedFiles.add(file));
      }
    } catch (_) {}
  }

  Future<void> _uploadAll() async {
    if (_selectedFiles.isEmpty) return;
    setState(() => _isUploading = true);

    try {
      for (final file in _selectedFiles) {
        final lower = file.name.toLowerCase();
        final mimeType = lower.endsWith('.mp4')
            ? 'video/mp4'
            : lower.endsWith('.mov')
                ? 'video/quicktime'
                : lower.endsWith('.png')
                    ? 'image/png'
                    : lower.endsWith('.webp')
                        ? 'image/webp'
                        : 'image/jpeg';
        await ref
            .read(evidenceUploadProvider.notifier)
            .uploadEvidence(widget.phaseId, file.path, mimeType);
      }
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          t.uploadTitle(_selectedFiles.length),
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
            child: _selectedFiles.isEmpty
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
                            t.uploadNoPhoto,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter',
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.uploadMinPhotos,
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
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _selectedFiles.length,
                    itemBuilder: (ctx, i) => Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_selectedFiles[i].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedFiles.removeAt(i)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.x,
                                  color: Colors.white, size: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                        onPressed: () => _pickImage(ImageSource.camera),
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
                        onPressed: () => _pickImage(ImageSource.gallery),
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
                OxButton(
                  label: _isUploading
                      ? t.uploadUploading
                      : t.uploadConfirmButton(_selectedFiles.length),
                  icon: LucideIcons.upload,
                  isLoading: _isUploading,
                  onPressed:
                      _selectedFiles.isNotEmpty ? _uploadAll : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
