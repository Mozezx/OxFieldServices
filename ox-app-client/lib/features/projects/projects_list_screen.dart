import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_empty_state.dart';
import '../../core/widgets/ox_loading.dart';
import 'project_provider.dart';
import 'widgets/project_card.dart';

final _filterProvider = StateProvider<String>((ref) => 'all');

class ProjectsListScreen extends ConsumerWidget {
  const ProjectsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final filter = ref.watch(_filterProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.email?.split('@').first ?? 'Usuário';

    return Scaffold(
      appBar: OxAppBar(
        showLogo: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.accent.withValues(alpha: 0.15),
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.bell, size: 20),
            color: AppColors.textSecondary,
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: projectsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => const OxProjectCardSkeleton(),
        ),
        error: (e, _) => const Center(
          child: Text(
            'Erro ao carregar projetos',
            style: TextStyle(color: AppColors.error, fontFamily: 'Inter'),
          ),
        ),
        data: (projects) {
          final filtered = filter == 'all'
              ? projects
              : filter == 'active'
                  ? projects.where((p) => [
                        'in_execution',
                        'active_escrow',
                        'contract_signed',
                        'matched',
                        'in_validation',
                      ].contains(p.status)).toList()
                  : projects.where((p) => p.status == 'closed').toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meus Projetos',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${projects.where((p) => p.status != 'closed').length} projetos ativos',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FilterChips(selected: filter),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? OxEmptyState(
                        icon: LucideIcons.folderOpen,
                        title: 'Nenhum projeto ainda',
                        subtitle: 'Crie seu primeiro projeto para encontrar um profissional.',
                        ctaLabel: 'Criar projeto',
                        onCta: () => context.push('/projects/new'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => ProjectCard(project: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/projects/new'),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus, size: 28),
      ),
    );
  }
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips({required this.selected});

  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = [
      ('all', 'Todos'),
      ('active', 'Ativos'),
      ('closed', 'Fechados'),
    ];

    return Row(
      children: options.map((opt) {
        final isSelected = selected == opt.$1;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => ref.read(_filterProvider.notifier).state = opt.$1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent.withValues(alpha: 0.15) : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.divider,
                ),
              ),
              child: Text(
                opt.$2,
                style: TextStyle(
                  color: isSelected ? AppColors.accent : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
