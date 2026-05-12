/// CTR as a ratio (0–1), computed client-side when possible.
double computeCtrRatio({required int impressions, required int clicks}) {
  if (impressions <= 0) return 0;
  return clicks / impressions;
}
