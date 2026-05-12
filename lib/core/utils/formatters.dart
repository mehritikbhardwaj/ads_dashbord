import 'package:intl/intl.dart';

final _compact = NumberFormat.compact();
final _money = NumberFormat('#,##0');
final _day = DateFormat('dd MMM yyyy');

String formatCompact(num value) => _compact.format(value);

String formatNumber(num value) => _money.format(value);

String formatPercentRatio(double ratio) =>
    '${(ratio * 100).toStringAsFixed(2)}%';

String formatDay(DateTime d) => _day.format(d);

String formatRelative(DateTime utcTime) {
  final now = DateTime.now().toUtc();
  final diff = now.difference(utcTime);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
