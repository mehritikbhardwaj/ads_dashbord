import 'package:equatable/equatable.dart';

class DailyMetric extends Equatable {
  const DailyMetric({
    required this.date,
    required this.impressions,
    required this.clicks,
    required this.ctr,
  });

  final String date;
  final int impressions;
  final int clicks;
  final double ctr;

  factory DailyMetric.fromJson(Map<String, dynamic> json) {
    return DailyMetric(
      date: json['date'] as String,
      impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
      ctr: (json['ctr'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toForecastHistoryJson() => {
        'date': date,
        'ctr': ctr,
      };

  @override
  List<Object?> get props => [date];
}
