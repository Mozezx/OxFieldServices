import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_badge.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_empty_state.dart';
import '../../core/widgets/ox_loading.dart';
import '../../l10n/app_localizations.dart';
import '../notifications/notifications_provider.dart';
import '../profile/profile_provider.dart';
import 'jobs_provider.dart';

/// UI flag: when `false`, workers only see jobs already assigned to them.
/// Set to `true` to show the "available jobs for you" list again.
const bool kShowAvailableJobsForWorker = false;

class JobsDashboardScreen extends ConsumerWidget {
  const JobsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final activeAsync = ref.watch(activeJobsProvider);
    final workerAsync = ref.watch(workerProfileProvider);
    final unreadAsync = ref.watch(unreadNotificationsCountProvider);
    final unread =
        unreadAsync.maybeWhen(data: (c) => c, orElse: () => 0);
    final user = Supabase.instance.client.auth.currentUser;
    final w = workerAsync.valueOrNull;
    final name = (w?.name?.isNotEmpty == true
            ? w!.name
            : w?.email?.isNotEmpty == true
                ? w!.email
                : user?.email) ??
        t.defaultWorkerName;

    return Scaffold(
      appBar: OxAppBar(
        showLogo: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ProfileAvatar(
              radius: 20,
              imageUrl: w?.avatarUrl,
              label: name,
              onTap: () => context.go('/profile'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              offset: const Offset(-10, -2),
              child: IconButton(
                icon: const Icon(LucideIcons.bell, size: 24),
                color: AppColors.textSecondary,
                onPressed: () => context.push('/notifications'),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          if (kShowAvailableJobsForWorker) {
            ref.invalidate(availableJobsProvider);
          }
          ref.invalidate(activeJobsProvider);
          ref.invalidate(workerProfileProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.jobsActiveSection,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              activeAsync.when(
                loading: () => const OxJobCardSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
                data: (jobs) => jobs.isEmpty
                    ? OxEmptyState(
                        icon: LucideIcons.zap,
                        title: t.jobsNoActive,
                        subtitle: t.jobsNoActiveSubtitle,
                      )
                    : Column(
                        children: jobs
                            .map((j) => _ActiveJobCard(job: j))
                            .toList(),
                      ),
              ),
              if (kShowAvailableJobsForWorker) const _AvailableJobsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailableJobsSection extends ConsumerWidget {
  const _AvailableJobsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final availableAsync = ref.watch(availableJobsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Text(
          t.jobsAvailableSection,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),
        availableAsync.when(
          loading: () => Column(
            children: List.generate(
                2,
                (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: OxJobCardSkeleton(),
                    )),
          ),
          error: (_, __) => OxEmptyState(
            icon: LucideIcons.briefcase,
            title: t.jobsNoAvailable,
            subtitle: t.jobsNoAvailableSubtitle,
          ),
          data: (jobs) => jobs.isEmpty
              ? OxEmptyState(
                  icon: LucideIcons.briefcase,
                  title: t.jobsNoAvailable,
                  subtitle: t.jobsNoAvailableSubtitle,
                )
              : Column(
                  children:
                      jobs.map((j) => _AvailableJobCard(job: j)).toList(),
                ),
        ),
      ],
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  const _ActiveJobCard({required this.job});

  final JobModel job;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final activePhase = job.activePhase;

    return GestureDetector(
      onTap: () => context.push('/jobs/${job.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                OxBadge(
                  label: _jobStatusLabel(t, job.status),
                  status: phaseStatusToBadge(job.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.mapPin,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  job.location,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            if (activePhase != null) ...[
              const SizedBox(height: 12),
              Text(
                t.phaseOrderAndName(activePhase.order, activePhase.name),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
            ],
            const SizedBox(height: 16),
            OxButton(
              label: t.jobContinueExecution,
              icon: LucideIcons.zap,
              onPressed: activePhase != null
                  ? () => context.go('/execution')
                  : () => context.push('/jobs/${job.id}'),
            ),
          ],
        ),
      ),
    );
  }

  String _jobStatusLabel(AppLocalizations t, String status) {
    switch (status) {
      case 'in_execution': return t.statusInExecution;
      case 'active_escrow': return t.statusActiveEscrow;
      case 'contract_signed': return t.statusContractSigned;
      default: return status;
    }
  }
}

class _AvailableJobCard extends StatelessWidget {
  const _AvailableJobCard({required this.job});

  final JobModel job;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final fmt = DateFormat('dd/MM/yyyy');
    final matchScore = job.matchScore ?? 85;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.mapPin,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                job.location,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(width: 16),
              const Icon(LucideIcons.euro,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                job.budget.toStringAsFixed(0),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
              if (job.deadline != null) ...[
                const SizedBox(width: 16),
                const Icon(LucideIcons.calendar,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  fmt.format(job.deadline!),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                t.jobCompatibility,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: matchScore / 100,
                  backgroundColor: AppColors.divider,
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$matchScore%',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OxButton(
            label: t.jobViewDetails,
            variant: OxButtonVariant.secondary,
            onPressed: () => context.push('/jobs/${job.id}'),
          ),
        ],
      ),
    );
  }
}
