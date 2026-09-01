import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config.dart';
import '../../core/di.dart';
import '../../core/format.dart';
import '../../core/web_download.dart';
import '../../shared/widgets/admin_scaffold.dart';
import '../../shared/widgets/async_view.dart';
import '../../theme/app_theme.dart';
import 'data/reports_models.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late Future<List<ReportCardData>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = reportsRepository.get();
  }

  void _reload() => setState(_load);

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/reports',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: AsyncView<List<ReportCardData>>(
                future: _future,
                onRetry: _reload,
                minHeight: 400,
                builder: (context, data) {
                  return GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.2,
                    children: data.map((report) {
                      Color color, iconColor;
                      IconData icon;
                      String description = '';

                      switch (report.report) {
                        case 'payments':
                          color = const Color(0xFFECECFF);
                          iconColor = const Color(0xFF6B4EFF);
                          icon = Icons.description_outlined;
                          description = 'Overview of all payment\nactivities.';
                          break;
                        case 'wallet':
                          color = const Color(0xFFE4FBE9);
                          iconColor = const Color(0xFF22C55E);
                          icon = Icons.wallet_outlined;
                          description =
                              'Wallet funding, withdrawal\nand coin economy';
                          break;
                        case 'users':
                          color = const Color(0xFFFFF4E0);
                          iconColor = const Color(0xFFF59E0B);
                          icon = Icons.people_outline;
                          description =
                              'User growth, engagement\nand demographics.';
                          break;
                        case 'games':
                          color = const Color(0xFFFFE4E4);
                          iconColor = const Color(0xFFEF4444);
                          icon = Icons.gamepad_outlined;
                          description =
                              'Most played games, win\nrate and metrics.';
                          break;
                        case 'tournaments':
                          color = const Color(0xFFE0F2FE);
                          iconColor = const Color(0xFF3B82F6);
                          icon = Icons.emoji_events_outlined;
                          description =
                              'Tournament participation\nand price distribution.';
                          break;
                        case 'revenue':
                        default:
                          color = const Color(0xFFECECFF);
                          iconColor = const Color(0xFF6B4EFF);
                          icon = Icons.bar_chart_outlined;
                          description = 'Revenue, fees and financial\nsummary.';
                          break;
                      }

                      String metricValue;
                      switch (report.format) {
                        case 'kobo':
                          metricValue = Format.naira(report.value);
                          break;
                        case 'coins':
                        case 'count':
                          metricValue = Format.number(report.value);
                          break;
                        case 'text':
                        default:
                          metricValue = report.value.toString();
                          break;
                      }

                      return _ReportCard(
                        reportId: report.report,
                        color: color,
                        iconColor: iconColor,
                        icon: icon,
                        title: report.title,
                        description: description,
                        metricLabel: report.headline,
                        metricValue: metricValue,
                      );
                    }).toList(),
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

class _ReportCard extends StatefulWidget {
  final String reportId;
  final Color color;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String description;
  final String metricLabel;
  final String metricValue;

  const _ReportCard({
    required this.reportId,
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.description,
    required this.metricLabel,
    required this.metricValue,
  });

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _downloading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: widget.iconColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: widget.iconColor.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            widget.metricLabel,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: widget.iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.metricValue,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: widget.iconColor,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _downloading
                ? null
                : () async {
                    setState(() => _downloading = true);
                    try {
                      final bytes =
                          await reportsRepository.download(widget.reportId);
                      downloadBytes(bytes, '${widget.reportId}_report.pdf');
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to download report: $e')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _downloading = false);
                    }
                  },
            child: Row(
              children: [
                if (_downloading) ...[
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.iconColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  _downloading ? 'Downloading...' : 'View Report',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.iconColor,
                  ),
                ),
                if (!_downloading) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: widget.iconColor, size: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
