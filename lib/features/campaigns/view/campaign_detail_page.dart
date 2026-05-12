import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/forecast_models.dart';
import '../../../widgets/dashboard_ui.dart';
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

Color _statusColor(CampaignStatus status) {
  switch (status) {
    case CampaignStatus.active:
      return AppTheme.success;
    case CampaignStatus.paused:
      return AppTheme.warning;
    case CampaignStatus.ended:
      return AppTheme.textSecondary;
    case CampaignStatus.unknown:
      return AppTheme.textSecondary;
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
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _phaseChild(context, state),
          );
        },
      ),
    );
  }

  Widget _phaseChild(BuildContext context, CampaignDetailState state) {
    switch (state.phase) {
      case DetailPhase.loading:
        return const Center(
          key: ValueKey('loading'),
          child: CircularProgressIndicator(),
        );
      case DetailPhase.failure:
        return _MessageCard(
          key: const ValueKey('failure'),
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
        return const _MessageCard(
          key: ValueKey('empty'),
          icon: Icons.inbox_outlined,
          iconColor: AppTheme.textSecondary,
          title: 'No data available',
          subtitle:
              'There is no historical CTR to display for this campaign.',
        );
      case DetailPhase.success:
        final c = state.campaign!;
        return _DetailBody(
          key: ValueKey('success-${c.id}'),
          state: state,
          campaign: c,
        );
    }
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.state,
    required this.campaign,
    super.key,
  });

  final CampaignDetailState state;
  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        StaggeredReveal(
          index: 0,
          child: Text(
            campaign.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        StaggeredReveal(
          index: 1,
          child: Row(
            children: [
              _Pill(
                color: _statusColor(campaign.status),
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
        ),
        const SizedBox(height: 16),
        StaggeredReveal(
          index: 2,
          child: _KpiRow(campaign: campaign, ctr: state.headlineCtr),
        ),
        const SizedBox(height: 16),
        StaggeredReveal(index: 3, child: _CtrChartCard(state: state)),
        const SizedBox(height: 16),
        if (state.recommendation != null)
          StaggeredReveal(
            index: 4,
            child: _RecommendationCard(rec: state.recommendation!),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.color, required this.label, this.filled = false});

  final Color color;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
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
              SoftPulse(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
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
    final tiles = [
      _KpiTile(
        icon: Icons.visibility_outlined,
        label: 'Impressions',
        value: campaign.impressions.toDouble(),
        formatter: (v) => formatCompact(v),
      ),
      _KpiTile(
        icon: Icons.ads_click_outlined,
        label: 'Clicks',
        value: campaign.clicks.toDouble(),
        formatter: (v) => formatCompact(v),
      ),
      _KpiTile(
        icon: Icons.trending_up,
        label: 'CTR',
        value: ctr,
        formatter: (v) => formatPercentRatio(v),
        trailing: const Icon(Icons.info_outline, size: 14),
      ),
      _KpiTile(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Spend',
        value: campaign.spend,
        formatter: (v) => formatNumber(v),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          final width = (constraints.maxWidth - 8) / 2;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tile in tiles) SizedBox(width: width, child: tile),
            ],
          );
        }
        return Row(children: [for (final tile in tiles) Expanded(child: tile)]);
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.formatter,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final double value;
  final String Function(double) formatter;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        height: 70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppTheme.accent),
            const SizedBox(height: 8),
            AnimatedMetricText(
              value: value,
              formatter: formatter,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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

class _CtrChartCard extends StatefulWidget {
  const _CtrChartCard({required this.state});

  final CampaignDetailState state;

  @override
  State<_CtrChartCard> createState() => _CtrChartCardState();
}

class _CtrChartCardState extends State<_CtrChartCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hist = widget.state.history;
    final fore = widget.state.forecast;
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
    var minY = (allY.reduce((a, b) => a < b ? a : b) * 0.85).clamp(
      0.0,
      double.infinity,
    );
    if ((maxY - minY) < 0.5) {
      maxY = minY + 2;
    }

    final dividerX = (hist.length - 0.5).toDouble();
    final totalLen = histSpots.length + (foreSpots.length - 1);

    return DashboardCard(
      child: Padding(
        padding: EdgeInsets.zero,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
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
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final progress = Curves.easeOutCubic.transform(
                    _controller.value,
                  );
                  final cutoff = totalLen * progress;

                  List<FlSpot> trim(List<FlSpot> source) {
                    if (source.isEmpty) return source;
                    final out = <FlSpot>[];
                    final firstX = source.first.x;
                    for (final s in source) {
                      if (s.x <= firstX + cutoff) {
                        out.add(s);
                      } else {
                        break;
                      }
                    }
                    if (out.isEmpty) out.add(source.first);
                    return out;
                  }

                  return LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: foreSpots.last.x,
                      minY: minY,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: (maxY - minY) / 4,
                        getDrawingHorizontalLine: (value) =>
                            FlLine(color: Colors.white12, strokeWidth: 1),
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
                            interval: (foreSpots.last.x / 4).clamp(
                              1,
                              double.infinity,
                            ),
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
                          spots: trim(lowerSpots),
                          isCurved: true,
                          color: AppTheme.accent.withValues(alpha: 0.08),
                          barWidth: 1,
                          dotData: const FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: trim(upperSpots),
                          isCurved: true,
                          color: AppTheme.accent.withValues(alpha: 0.08),
                          barWidth: 1,
                          dotData: const FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: trim(histSpots),
                          isCurved: true,
                          color: AppTheme.accent,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: trim(foreSpots),
                          isCurved: true,
                          color: AppTheme.accent,
                          barWidth: 3,
                          dashArray: const [6, 4],
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                    duration: Duration.zero,
                  );
                },
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
    return DashboardCard(
      accent: AppTheme.success,
      backgroundColor: AppTheme.success.withValues(alpha: 0.08),
      child: Padding(
        padding: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final detailsButton = OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.success,
                side: const BorderSide(color: AppTheme.success),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Details'),
            );
            final iconBox = SoftPulse(
              minScale: 0.96,
              child: DashboardIconBox(
                icon: up ? Icons.trending_up : Icons.trending_down,
                color: AppTheme.success,
                size: 48,
                radius: 4,
              ),
            );
            final copy = Column(
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
            );

            if (constraints.maxWidth < 420) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      iconBox,
                      const SizedBox(width: 12),
                      Expanded(child: copy),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerRight, child: detailsButton),
                ],
              );
            }

            return Row(
              children: [
                iconBox,
                const SizedBox(width: 12),
                Expanded(child: copy),
                const SizedBox(width: 12),
                detailsButton,
              ],
            );
          },
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
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DashboardCard(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: EdgeInsets.zero,
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
              if (action != null) ...[const SizedBox(height: 12), action!],
            ],
          ),
        ),
      ),
    );
  }
}
