import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../l10n/app_localizations.dart';
import 'invite_provider.dart';

class RedeemInviteScreen extends ConsumerStatefulWidget {
  const RedeemInviteScreen({super.key, this.initialToken});

  final String? initialToken;

  @override
  ConsumerState<RedeemInviteScreen> createState() => _RedeemInviteScreenState();
}

class _RedeemInviteScreenState extends ConsumerState<RedeemInviteScreen> {
  final _controller = TextEditingController();
  InvitePreview? _preview;
  String? _error;
  bool _loadingPreview = false;
  bool _redeeming = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialToken != null) {
      _controller.text = widget.initialToken!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPreview());
    } else {
      _tryPasteFromClipboard();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _extractToken(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    Uri? uri = Uri.tryParse(trimmed);
    if (uri != null && uri.host.isEmpty && trimmed.startsWith('/')) {
      uri = Uri.tryParse('https://placeholder.invalid$trimmed');
    }
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      final idx = uri.pathSegments.indexOf('i');
      if (idx >= 0 && idx + 1 < uri.pathSegments.length) {
        final token = uri.pathSegments[idx + 1];
        if (token.isNotEmpty) return token;
      }
    }
    return trimmed;
  }

  Future<void> _tryPasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text ?? '';
      if (text.contains('/i/')) {
        setState(() => _controller.text = text.trim());
        await _loadPreview();
      }
    } catch (_) {}
  }

  Future<void> _loadPreview() async {
    final token = _extractToken(_controller.text);
    if (token == null) return;

    setState(() {
      _loadingPreview = true;
      _error = null;
      _preview = null;
    });

    try {
      final notifier = ref.read(inviteNotifierProvider.notifier);
      final preview = await notifier.preview(token);
      setState(() {
        _preview = preview;
        _loadingPreview = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyError(e);
        _loadingPreview = false;
      });
    }
  }

  Future<void> _redeem() async {
    final token = _extractToken(_controller.text);
    if (token == null) return;

    setState(() {
      _redeeming = true;
      _error = null;
    });

    try {
      final notifier = ref.read(inviteNotifierProvider.notifier);
      final projectId = await notifier.redeem(token);
      if (mounted) context.go('/projects/$projectId');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyError(e);
        _redeeming = false;
      });
    }
  }

  String _friendlyError(Object e) {
    final l = AppLocalizations.of(context)!;
    if (e is DioException) {
      final code = e.response?.statusCode;
      final body = e.response?.data;
      String? msg;
      if (body is Map) {
        final m = body['message'];
        if (m is String) {
          msg = m;
        } else if (m is List && m.isNotEmpty) {
          msg = m.first.toString();
        }
      }
      final lower = '${e.message ?? ''} ${msg ?? ''}'.toLowerCase();

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return l.redeemErrorNetwork;
      }

      if (code == 404) return l.redeemErrorNotFound;

      if (code == 410 ||
          lower.contains('gone') ||
          lower.contains('expirado') ||
          lower.contains('expired') ||
          lower.contains('utilizado')) {
        return l.redeemErrorExpired;
      }

      if (code == 403) {
        if (lower.contains('revogado') || lower.contains('revoked')) return l.redeemErrorRevoked;
        if (lower.contains('email') || lower.contains('outro')) return l.redeemErrorWrongEmail;
        if (lower.contains('permissão') ||
            lower.contains('papel') ||
            lower.contains('permission') ||
            lower.contains('role') ||
            lower.contains('client')) {
          return l.redeemErrorRoleMustBeClient;
        }
        return l.redeemErrorRevoked;
      }
    }

    final raw = e.toString();
    if (raw.contains('410') || raw.contains('Gone') || raw.contains('expirado') || raw.contains('expired')) {
      return l.redeemErrorExpired;
    }
    if (raw.contains('403') || raw.contains('revogado') || raw.contains('revoked')) {
      return l.redeemErrorRevoked;
    }
    if (raw.contains('email')) {
      return l.redeemErrorWrongEmail;
    }
    return l.redeemErrorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: OxAppBar(title: l.redeemTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.redeemSubtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 24),

            // Token / URL input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter', fontSize: 13),
                    decoration: InputDecoration(
                      hintText: l.redeemInputHint,
                      hintStyle: const TextStyle(color: AppColors.textDisabled, fontFamily: 'Inter'),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.accent),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (_) => _loadPreview(),
                  ),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  onTap: _loadingPreview ? null : _loadPreview,
                  icon: LucideIcons.search,
                  loading: _loadingPreview,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Preview card
            if (_preview != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.briefcase, size: 16, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _preview!.projectTitle,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.redeemPreviewClient(_preview!.clientName),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.redeemPreviewExpires(_formatDate(_preview!.expiresAt)),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Inter'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _redeeming ? null : _redeem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _redeeming
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : Text(
                          l.redeemButton,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                        ),
                ),
              ),
            ],

            // Error
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertCircle, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13, fontFamily: 'Inter'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _error = null),
                      child: Text(
                        l.redeemRetry,
                        style: const TextStyle(color: AppColors.accent, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.onTap, required this.icon, this.loading = false});

  final VoidCallback? onTap;
  final IconData icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                )
              : Icon(icon, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }
}
