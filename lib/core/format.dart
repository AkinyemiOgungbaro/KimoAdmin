import 'package:intl/intl.dart';

/// Centralised formatting helpers.
///
/// The backend sends money in **kobo** (integer minor units, ÷100 → ₦) and
/// dates as ISO-8601 UTC strings.
class Format {
  Format._();

  static final NumberFormat _int = NumberFormat.decimalPattern();
  static final NumberFormat _compact = NumberFormat.compact();
  static final NumberFormat _money = NumberFormat('#,##0.##');

  /// Kobo → "₦1,234.5"
  static String naira(num? kobo) {
    if (kobo == null) return '₦0';
    return '₦${_money.format(kobo / 100.0)}';
  }

  /// Kobo → compact "₦1.2M"
  static String nairaCompact(num? kobo) {
    if (kobo == null) return '₦0';
    return '₦${_compact.format(kobo / 100.0)}';
  }

  /// Thousands-separated integer, e.g. 28756 → "28,756".
  static String number(num? n) => n == null ? '0' : _int.format(n);

  /// Compact integer, e.g. 1200000 → "1.2M".
  static String compact(num? n) => n == null ? '0' : _compact.format(n);

  /// Coins are whole numbers; show compact for large values.
  static String coins(num? n) => n == null ? '0' : _compact.format(n);

  /// Accepts a rate as either a fraction (0..1) or a percentage (0..100) and
  /// renders it as a percentage string.
  static String rate(num? value, {int decimals = 0}) {
    if (value == null) return '—';
    final pct = value <= 1 ? value * 100 : value;
    return '${pct.toStringAsFixed(decimals)}%';
  }

  static DateTime? _parse(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso)?.toLocal();
  }

  /// ISO → "Mar 5, 2026".
  static String dateShort(String? iso) {
    final d = _parse(iso);
    return d == null ? '—' : DateFormat('MMM d, yyyy').format(d);
  }

  /// ISO → "Mar 5, 2026 • 2:30 PM".
  static String dateTime(String? iso) {
    final d = _parse(iso);
    return d == null ? '—' : DateFormat('MMM d, yyyy • h:mm a').format(d);
  }

  /// ISO → "2 mins ago".
  static String relativeTime(String? iso) {
    final d = _parse(iso);
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.isNegative) return 'just now';
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    return DateFormat('MMM d').format(d);
  }

  /// Seconds → "4m 12s" / "45s".
  static String durationFromSeconds(num? seconds) {
    if (seconds == null) return '—';
    final s = seconds.round();
    final m = s ~/ 60;
    final rem = s % 60;
    return m == 0 ? '${rem}s' : '${m}m ${rem}s';
  }

  /// Countdown seconds → "2d 3h" / "3h 12m" / "5m".
  static String remaining(num? seconds) {
    if (seconds == null || seconds <= 0) return '—';
    final s = seconds.round();
    final d = s ~/ 86400;
    final h = (s % 86400) ~/ 3600;
    final m = (s % 3600) ~/ 60;
    if (d > 0) return '${d}d ${h}h';
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
