import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/dashboard_ui.dart';
import '../bloc/campaign_list_cubit.dart';
import '../widgets/campaign_card.dart';

class CampaignListPage extends StatelessWidget {
  const CampaignListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign List'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
      ),
      body: BlocBuilder<CampaignListCubit, CampaignListState>(
        builder: (context, state) {
          if (state.isLoading && state.filtered.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null && state.filtered.isEmpty) {
            return _ErrorState(
              message: state.errorMessage!,
              onRetry: () => context.read<CampaignListCubit>().refresh(),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: state.filter == CampaignFilter.all,
                      onTap: () => context
                          .read<CampaignListCubit>()
                          .setFilter(CampaignFilter.all),
                    ),
                    _FilterChip(
                      label: 'Active',
                      selected: state.filter == CampaignFilter.active,
                      onTap: () => context
                          .read<CampaignListCubit>()
                          .setFilter(CampaignFilter.active),
                    ),
                    _FilterChip(
                      label: 'Paused',
                      selected: state.filter == CampaignFilter.paused,
                      onTap: () => context
                          .read<CampaignListCubit>()
                          .setFilter(CampaignFilter.paused),
                    ),
                    _FilterChip(
                      label: 'Ended',
                      selected: state.filter == CampaignFilter.ended,
                      onTap: () => context
                          .read<CampaignListCubit>()
                          .setFilter(CampaignFilter.ended),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<CampaignListCubit>().refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: state.filtered.length,
                    itemBuilder: (context, index) {
                      final c = state.filtered[index];
                      final cubit = context.read<CampaignListCubit>();
                      return StaggeredReveal(
                        key: ValueKey('${state.filter.name}-${c.id}'),
                        index: index,
                        child: CampaignCard(
                          campaign: c,
                          ctrRatio: cubit.ctrFor(c),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.accent.withValues(alpha: 0.16),
      labelStyle: TextStyle(
        color: selected ? AppTheme.accent : AppTheme.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: selected ? AppTheme.accent : AppTheme.cardBorder,
      ),
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.danger, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
