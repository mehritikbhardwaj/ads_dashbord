import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/campaign.dart';
import '../../../widgets/dashboard_ui.dart';

class CampaignCard extends StatelessWidget {
  const CampaignCard({
    required this.campaign,
    required this.ctrRatio,
    super.key,
  });

  final Campaign campaign;
  final double ctrRatio;

  @override
  Widget build(BuildContext context) {
    final progress = campaign.budget > 0
        ? (campaign.spend / campaign.budget).clamp(0.0, 1.0)
        : 0.0;
    final pct = campaign.budgetUtilization?.round() ?? (progress * 100).round();

    return DashboardCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      onTap: () => context.push('/campaigns/detail/${campaign.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CampaignThumbnail(
            url: campaign.thumbnail,
            objective: campaign.objective,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          campaign.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _StatusBadge(status: campaign.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Chip(
                        icon: _objectiveIcon(campaign.objective),
                        label: campaign.objective,
                      ),
                      _Chip(
                        icon: _channelIcon(campaign.channel),
                        label: campaign.channel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Total spend',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${formatNumber(campaign.spend)} ${campaign.currency} '
                          '/ ${formatNumber(campaign.budget)} ${campaign.currency}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedProgressBar(value: progress),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _Metric(
                          icon: Icons.visibility_outlined,
                          label: 'Impressions',
                          value: formatCompact(campaign.impressions),
                        ),
                      ),
                      Expanded(
                        child: _Metric(
                          icon: Icons.ads_click_outlined,
                          label: 'Clicks',
                          value: formatCompact(campaign.clicks),
                        ),
                      ),
                      Expanded(
                        child: _Metric(
                          icon: Icons.trending_up,
                          label: 'CTR',
                          value: formatPercentRatio(ctrRatio),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _dateRange(campaign.startDate, campaign.endDate),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
            ),
          ),
        ],
      ),
    );
  }

  static String _dateRange(String start, String end) {
    if (start.isEmpty && end.isEmpty) return '—';
    if (start.isNotEmpty && end.isNotEmpty) return '$start  →  $end';
    return start.isNotEmpty ? start : end;
  }

  static IconData _objectiveIcon(String objective) {
    final o = objective.toLowerCase();
    if (o.contains('conversion')) return Icons.shopping_cart_outlined;
    if (o.contains('awareness')) return Icons.campaign_outlined;
    if (o.contains('engage')) return Icons.favorite_border;
    return Icons.flag_outlined;
  }

  static IconData _channelIcon(String channel) {
    final c = channel.toLowerCase();
    if (c.contains('search')) return Icons.search;
    if (c.contains('social')) return Icons.public;
    if (c.contains('display')) return Icons.image_outlined;
    return Icons.devices_other;
  }
}

class _CampaignThumbnail extends StatelessWidget {
  const _CampaignThumbnail({required this.url, required this.objective});

  final String? url;
  final String objective;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.12),
        border: const Border(bottom: BorderSide(color: AppTheme.cardBorder)),
      ),
      alignment: Alignment.center,
      child: DashboardIconBox(
        icon: CampaignCard._objectiveIcon(objective),
        size: 52,
        radius: 4,
      ),
    );
    if (url == null || url!.isEmpty) return fallback;
    return Image.network(
      url!,
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 120,
          color: Colors.white10,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
      color: AppTheme.accent.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.accent, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CampaignStatus status;

  @override
  Widget build(BuildContext context) {
    late Color dot;
    late String label;
    switch (status) {
      case CampaignStatus.active:
        dot = AppTheme.success;
        label = 'Active';
        break;
      case CampaignStatus.paused:
        dot = AppTheme.warning;
        label = 'Paused';
        break;
      case CampaignStatus.ended:
        dot = AppTheme.textSecondary;
        label = 'Ended';
        break;
      case CampaignStatus.unknown:
        dot = AppTheme.textSecondary;
        label = 'Unknown';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: dot.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dot,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.accent),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
