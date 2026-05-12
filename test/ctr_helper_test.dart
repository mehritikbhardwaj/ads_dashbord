import 'package:ads_dashboard/core/utils/ctr_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('computeCtrRatio uses clicks over impressions', () {
    expect(computeCtrRatio(impressions: 1000, clicks: 25), 0.025);
    expect(computeCtrRatio(impressions: 0, clicks: 10), 0);
  });
}
