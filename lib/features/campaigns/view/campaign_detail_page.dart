import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/forecast_models.dart';
import '../bloc/campaign_detail_cubit.dart';

String _statusLabel(CampaignStatus status) {
  switch (status) {
    case CampaignStatus.active:
      return 'Active';
    case CampaignStatus.paused:
      return 'Paused';
    case CampaignStatus.ended:
      return 'Ended';
    case CampaignStatus.unknown:
      return 'Unknown';
  }
}

class CampaignDetailPage extends StatelessWidget {
  const CampaignDetailPage({required this.campaignId, super.key});

  final String campaignId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Campaign'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<CampaignDetailCubit, CampaignDetailState>(
        builder: (context, state) {
          switch (state.phase) {
            case DetailPhase.loading:
              return const Center(child: CircularProgressIndicator());
            case DetailPhase.failure:
              return _MessageCard(
                icon: Icons.error_outline,
                iconColor: AppTheme.danger,
                title: 'Failed to load data',
                subtitle: state.errorMessage ?? 'Something went wrong',
                action: TextButton(
                  onPressed: () =>
                      context.read<CampaignDetailCubit>().load(campaignId),
                  child: const Text('Retry'),
                ),
              );
            case DetailPhase.empty:
              return _MessageCard(
                icon: Icons.inbox_outlined,
                iconColor: AppTheme.textSecondary,
                title: 'No data available',
                subtitle:
                    'There is no historical CTR to display for this campaign.',
              );
            case DetailPhase.success:
              final c = state.campaign!;
              return _DetailBody(state: state, campaign: c);
          }
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.state, required this.campaign});

  final CampaignDetailState state;
  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          campaign.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _Pill(
              color: AppTheme.success,
              label: _statusLabel(campaign.status),
            ),
            const SizedBox(width: 8),
            _Pill(
              color: AppTheme.accent,
              label: campaign.objective,
              filled: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _KpiRow(campaign: campaign, ctr: state.headlineCtr),
        const SizedBox(height: 16),
        _CtrChartCard(state: state),
        const SizedBox(height: 16),
        if (state.recommendation != null)
          _RecommendationCard(rec: state.recommendation!),
        const SizedBox(height: 24),
        const Text(
          'UI states (demo)',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _DemoStatesPreview(),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.color,
    required this.label,
    this.filled = false,
  });

  final Color color;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!filled) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.campaign, required this.ctr});

  final Campaign campaign;
  final double ctr;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiTile(
            icon: Icons.visibility_outlined,
            label: 'Impressions',
            value: formatCompact(campaign.impressions),
          ),
        ),
        Expanded(
          child: _KpiTile(
            icon: Icons.ads_click_outlined,
            label: 'Clicks',
            value: formatCompact(campaign.clicks),
          ),
        ),
        Expanded(
          child: _KpiTile(
            icon: Icons.trending_up,
            label: 'CTR',
            value: formatPercentRatio(ctr),
            trailing: const Icon(Icons.info_outline, size: 14),
          ),
        ),
        Expanded(
          child: _KpiTile(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Spend',
            value: formatNumber(campaign.spend),
          ),
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppTheme.accent),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                ?trailing,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CtrChartCard extends StatelessWidget {
  const _CtrChartCard({required this.state});

  final CampaignDetailState state;

  @override
  Widget build(BuildContext context) {
    final hist = state.history;
    final fore = state.forecast;
    if (hist.isEmpty) {
      return const SizedBox.shrink();
    }

    final histSpots = <FlSpot>[];
    for (var i = 0; i < hist.length; i++) {
      histSpots.add(FlSpot(i.toDouble(), hist[i].ctr * 100));
    }

    final last = hist.last;
    final foreSpots = <FlSpot>[
      FlSpot((hist.length - 1).toDouble(), last.ctr * 100),
    ];
    final upperSpots = <FlSpot>[
      FlSpot((hist.length - 1).toDouble(), last.ctr * 100),
    ];
    final lowerSpots = <FlSpot>[
      FlSpot((hist.length - 1).toDouble(), last.ctr * 100),
    ];

    for (var j = 0; j < fore.length; j++) {
      final x = (hist.length - 1 + j + 1).toDouble();
      final f = fore[j];
      foreSpots.add(FlSpot(x, f.predictedCtr * 100));
      upperSpots.add(FlSpot(x, f.upperBound * 100));
      lowerSpots.add(FlSpot(x, f.lowerBound * 100));
    }

    final allY = [
      ...histSpots.map((e) => e.y),
      ...foreSpots.map((e) => e.y),
      ...upperSpots.map((e) => e.y),
      ...lowerSpots.map((e) => e.y),
    ];
    var maxY = allY.reduce((a, b) => a > b ? a : b) * 1.15;
    var minY = (allY.reduce((a, b) => a < b ? a : b) * 0.85).clamp(0.0, double.infinity);
    if ((maxY - minY) < 0.5) {
      maxY = minY + 2;
    }

    final dividerX = (hist.length - 0.5).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'CTR Performance & Forecast',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.info_outline, size: 20),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text('30 Days', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _LegendDot(color: AppTheme.accent, label: 'Historical CTR'),
                const SizedBox(width: 16),
                _LegendDot(
                  color: AppTheme.accent,
                  label: 'Forecast CTR',
                  dashed: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: foreSpots.last.x,
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white12,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (foreSpots.last.x / 4).clamp(1, double.infinity),
                        getTitlesWidget: (value, meta) {
                          final idx = value.round();
                          if (idx >= 0 && idx < hist.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                hist[idx].date.substring(5),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  extraLinesData: ExtraLinesData(
                    verticalLines: [
                      VerticalLine(
                        x: dividerX,
                        color: Colors.white24,
                        dashArray: [4, 4],
                      ),
                    ],
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: lowerSpots,
                      isCurved: true,
                      color: AppTheme.accent.withValues(alpha: 0.08),
                      barWidth: 1,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: upperSpots,
                      isCurved: true,
                      color: AppTheme.accent.withValues(alpha: 0.08),
                      barWidth: 1,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: histSpots,
                      isCurved: true,
                      color: AppTheme.accent,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: foreSpots,
                      isCurved: true,
                      color: AppTheme.accent,
                      barWidth: 3,
                      dashArray: const [6, 4],
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 3,
          decoration: BoxDecoration(
            color: dashed ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(2),
            border: dashed ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.rec});

  final ForecastRecommendation rec;

  @override
  Widget build(BuildContext context) {
    final up = rec.changePercent >= 0;
    return Card(
      color: AppTheme.success.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppTheme.success.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                up ? Icons.trending_up : Icons.trending_down,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Budget Recommendation',
                    style: TextStyle(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rec.message,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (rec.suggestedDailyBudget != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Suggested daily budget: ${formatNumber(rec.suggestedDailyBudget!)} SAR',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.success,
                side: const BorderSide(color: AppTheme.success),
              ),
              child: const Text('Details'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 40),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              if (action != null) ...[
                const SizedBox(height: 12),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoStatesPreview extends StatelessWidget {
  const _DemoStatesPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 160,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const _MessageCard(
          icon: Icons.inbox_outlined,
          iconColor: AppTheme.textSecondary,
          title: 'No data available',
          subtitle: 'There is no data to display for this period.',
        ),
        const SizedBox(height: 8),
        _MessageCard(
          icon: Icons.warning_amber_rounded,
          iconColor: AppTheme.danger,
          title: 'Failed to load data',
          subtitle: 'Something went wrong',
          action: TextButton(
            onPressed: () {},
            child: Text(
              'Retry',
              style: TextStyle(color: AppTheme.accent),
            ),
          ),
        ),
      ],
    );
  }
}
