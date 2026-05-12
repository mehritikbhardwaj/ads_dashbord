import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/summary_models.dart';
import '../../../widgets/dashboard_ui.dart';
import '../bloc/spend_summary_cubit.dart';

class SpendSummaryPage extends StatelessWidget {
  const SpendSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spend Summary'),
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
      ),
      body: BlocBuilder<SpendSummaryCubit, SpendSummaryState>(
        builder: (context, state) {
          if (state.isLoading && state.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null && state.summary == null) {
            return _Error(
              message: state.errorMessage!,
              onRetry: () => context.read<SpendSummaryCubit>().load(),
            );
          }
          final s = state.summary!;
          return RefreshIndicator(
            onRefresh: () => context.read<SpendSummaryCubit>().load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                StaggeredReveal(
                  index: 0,
                  child: _TotalSpendCard(total: s.totalSpend),
                ),
                const SizedBox(height: 16),
                StaggeredReveal(
                  index: 1,
                  child: _DateRangeRow(
                    days: state.days,
                    onSelect: (d) =>
                        context.read<SpendSummaryCubit>().selectRange(d),
                  ),
                ),
                const SizedBox(height: 16),
                StaggeredReveal(
                  index: 2,
                  child: _ChannelCard(channels: s.byChannel),
                ),
                const SizedBox(height: 16),
                StaggeredReveal(
                  index: 3,
                  child: _TopCtrCard(top: s.topCampaigns),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TotalSpendCard extends StatelessWidget {
  const _TotalSpendCard({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      accent: AppTheme.success,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            const DashboardIconBox(
              icon: Icons.show_chart,
              color: AppTheme.success,
              size: 52,
              radius: 4,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Spend',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  AnimatedMetricText(
                    value: total,
                    formatter: (value) => '${formatNumber(value)} SAR',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangeRow extends StatelessWidget {
  const _DateRangeRow({required this.days, required this.onSelect});

  final int days;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, int value) {
      final selected = days == value;
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.accent.withValues(alpha: 0.14)
                : AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.accent : AppTheme.cardBorder,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelect(value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? AppTheme.accent : AppTheme.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return DashboardCard(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                DashboardIconBox(
                  icon: Icons.date_range_rounded,
                  color: AppTheme.accent,
                  size: 40,
                  radius: 10,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pick a window to compare spend trends',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  chip('Last 7 Days', 7),
                  chip('Last 14 Days', 14),
                  chip('Last 30 Days', 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({required this.channels});

  final List<ChannelSpend> channels;

  @override
  Widget build(BuildContext context) {
    final total = channels.fold<double>(0, (a, c) => a + c.spend);
    final colors = [
      AppTheme.accent,
      const Color(0xFF3949AB),
      const Color(0xFF8E24AA),
    ];
    if (channels.isEmpty) {
      return const DashboardCard(
        child: Padding(
          padding: EdgeInsets.zero,
          child: Text('No channel data'),
        ),
      );
    }
    return DashboardCard(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spend by channel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: 140,
                  width: 140,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 44,
                      sections: [
                        for (var i = 0; i < channels.length; i++)
                          PieChartSectionData(
                            color: colors[i % colors.length],
                            value: channels[i].spend,
                            title:
                                '${((channels[i].spend / total) * 100).round()}%',
                            radius: 28,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 400),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      for (var i = 0; i < channels.length; i++) ...[
                        if (i > 0) const Divider(height: 16),
                        _LegendRow(
                          color: colors[i % colors.length],
                          label: channels[i].channel,
                          pct: total > 0
                              ? (channels[i].spend / total) * 100
                              : 0,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.pct,
  });

  final Color color;
  final String label;
  final double pct;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          '${pct.round()}%',
          style: const TextStyle(
            color: AppTheme.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TopCtrCard extends StatelessWidget {
  const _TopCtrCard({required this.top});

  final List<TopCampaignCtr> top;

  @override
  Widget build(BuildContext context) {
    final list = top.take(3).toList();
    return DashboardCard(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 3 Campaigns by CTR',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < list.length; i++) ...[
              if (i > 0) const Divider(height: 20),
              _RankRow(rank: i + 1, item: list[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.rank, required this.item});

  final int rank;
  final TopCampaignCtr item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.accent),
          ),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: AppTheme.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            rank == 1
                ? Icons.campaign_outlined
                : rank == 2
                ? Icons.card_giftcard_outlined
                : Icons.shopping_cart_outlined,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Row(
          children: [
            Text(
              formatPercentRatio(item.ctr),
              style: const TextStyle(
                color: AppTheme.success,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.north_east, size: 16, color: AppTheme.success),
          ],
        ),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});

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
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
