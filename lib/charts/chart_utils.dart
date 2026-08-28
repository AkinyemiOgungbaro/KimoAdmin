import 'dart:math' as math;

/// Rounds [maxValue] up to a "nice" axis maximum (1/2/2.5/5/10 × 10ⁿ).
double niceMaxY(List<double> data) {
  final maxV = data.isEmpty ? 0.0 : data.reduce(math.max);
  if (maxV <= 0) return 10;
  final magnitude = math.pow(10, (math.log(maxV) / math.ln10).floor()).toDouble();
  final norm = maxV / magnitude;
  final double niceNorm;
  if (norm <= 1) {
    niceNorm = 1;
  } else if (norm <= 2) {
    niceNorm = 2;
  } else if (norm <= 2.5) {
    niceNorm = 2.5;
  } else if (norm <= 5) {
    niceNorm = 5;
  } else {
    niceNorm = 10;
  }
  return niceNorm * magnitude;
}

/// How many x-axis labels to skip so a long series stays readable
/// (aims for ≈6 visible labels).
int labelStep(int count) {
  if (count <= 6) return 1;
  return (count / 6).ceil();
}

/// Shortens a `day` label. ISO dates (`2026-08-20`) collapse to the day number.
String shortDayLabel(String raw) {
  if (raw.contains('-')) {
    final parts = raw.split('-');
    return parts.last;
  }
  if (raw.length > 4) return raw.substring(0, 3);
  return raw;
}
