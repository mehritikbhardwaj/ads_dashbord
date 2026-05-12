import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/anomaly.dart';
import '../../../widgets/dashboard_ui.dart';
import '../bloc/anomaly_alerts_bloc.dart';

class AnomalyAlertsPage extends StatelessWidget {
  const AnomalyAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anomaly Alerts'),
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
      ),
      body: BlocBuilder<AnomalyAlertsBloc, AnomalyAlertsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              StaggeredReveal(
                index: 0,
                child: _MonitoringCard(
                  isPolling: state.isPolling,
                  lastChecked: state.lastChecked,
                ),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                DashboardCard(
                  accent: AppTheme.danger,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.error_outline,
                      color: AppTheme.danger,
                    ),
                    title: Text(state.errorMessage!),
                    trailing: TextButton(
                      onPressed: () => context.read<AnomalyAlertsBloc>().add(
                        const AnomalyAlertsPoll(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (state.isInitialLoading && state.anomalies.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.anomalies.isEmpty)
                const DashboardCard(
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Text('No anomalies detected in the latest window.'),
                  ),
                )
              else
                ...state.anomalies.indexed.map(
                  (entry) => StaggeredReveal(
                    key: ValueKey(entry.$2.id),
                    index: entry.$1 + 1,
                    child: _AnomalyCard(entry.$2),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MonitoringCard extends StatelessWidget {
  const _MonitoringCard({required this.isPolling, this.lastChecked});

  final bool isPolling;
  final DateTime? lastChecked;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            const DashboardIconBox(
              icon: Icons.monitor_heart_outlined,
              size: 48,
              radius: 4,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monitoring in real-time',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Polling Ads API every 30 seconds',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (lastChecked != null)
                    Text(
                      'Last check: ${formatRelative(lastChecked!)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: [
                _LiveDot(active: true, busy: isPolling),
                const SizedBox(height: 4),
                const Text(
                  'Live',
                  style: TextStyle(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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

class _LiveDot extends StatelessWidget {
  const _LiveDot({required this.active, required this.busy});

  final bool active;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SoftPulse(
      enabled: active,
      minScale: busy ? 0.78 : 0.88,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppTheme.success,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _AnomalyCard extends StatelessWidget {
  const _AnomalyCard(this.anomaly);

  final Anomaly anomaly;

  @override
  Widget build(BuildContext context) {
    final isSpike = anomaly.type == AnomalyType.spendSpike;
    final accent = isSpike ? AppTheme.danger : AppTheme.warning;
    final tag = isSpike ? 'Spend Spike' : 'CTR Drop';

    return DashboardCard(
      margin: const EdgeInsets.only(bottom: 12),
      accent: accent,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardIconBox(
                  icon: isSpike ? Icons.trending_up : Icons.trending_down,
                  color: accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        anomaly.campaignName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Campaign',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatRelative(anomaly.detectedAt),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(anomaly.message, style: const TextStyle(height: 1.35)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricBox(
                    label: 'Actual',
                    value: _fmtMetric(anomaly),
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricBox(
                    label: 'Expected',
                    value: _fmtExpected(anomaly),
                    icon: Icons.area_chart_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricBox(
                    label: 'Change',
                    value:
                        '${anomaly.deviationPercent > 0 ? '+' : ''}${anomaly.deviationPercent.toStringAsFixed(0)}%',
                    icon: Icons.show_chart,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtMetric(Anomaly a) {
    if (a.type == AnomalyType.spendSpike) {
      return '${formatNumber(a.actualValue)} SAR';
    }
    return formatPercentRatio(a.actualValue);
  }

  String _fmtExpected(Anomaly a) {
    if (a.type == AnomalyType.spendSpike) {
      return '${formatNumber(a.expectedValue)} SAR';
    }
    return formatPercentRatio(a.expectedValue);
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.accent),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
