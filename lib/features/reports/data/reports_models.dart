class ReportCardData {
  final String report;
  final String title;
  final String headline;
  final dynamic value;
  final String format;

  ReportCardData({
    required this.report,
    required this.title,
    required this.headline,
    required this.value,
    required this.format,
  });

  factory ReportCardData.fromJson(Map<String, dynamic> json) {
    return ReportCardData(
      report: json['report'] as String? ?? '',
      title: json['title'] as String? ?? '',
      headline: json['label'] as String? ?? json['headline'] as String? ?? '',
      value: json['value'] ?? 0,
      format: _inferFormat(json['format'] as String?, json['report'] as String?),
    );
  }

  static String _inferFormat(String? providedFormat, String? report) {
    if (providedFormat != null && providedFormat.isNotEmpty && providedFormat != 'text') {
      return providedFormat;
    }
    switch (report) {
      case 'payments':
      case 'revenue':
        return 'kobo';
      case 'wallet':
        return 'coins';
      case 'users':
      case 'tournaments':
        return 'count';
      default:
        return 'text';
    }
  }
}
