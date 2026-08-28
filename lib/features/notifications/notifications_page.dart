import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/di.dart';
import '../../shared/widgets/admin_scaffold.dart';
import '../../shared/widgets/async_view.dart';
import '../../theme/app_theme.dart';
import 'data/notification_models.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  late Future<NotificationsPageData> _allFuture;
  late Future<NotificationsPageData> _criticalFuture;
  late Future<NotificationsPageData> _actionRequiredFuture;
  late Future<NotificationsPageData> _warningFuture;
  late Future<NotificationsPageData> _systemFuture;

  NotificationCounts? _counts;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAll();
  }

  void _loadAll() {
    _allFuture = notificationsRepository.list().then((data) {
      if (mounted) setState(() => _counts = data.counts);
      return data;
    });
    _criticalFuture = notificationsRepository.list(severity: 'critical');
    _actionRequiredFuture = notificationsRepository.list(severity: 'action_required');
    _warningFuture = notificationsRepository.list(severity: 'warning');
    _systemFuture = notificationsRepository.list(severity: 'system');
  }

  Future<void> _markAllAsRead() async {
    try {
      await notificationsRepository.markAllAsRead();
      if (mounted) {
        setState(_loadAll);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All notifications marked as read')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not mark as read')));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/notifications',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    indicatorColor: const Color(0xFF6B4EFF),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    tabs: [
                      Tab(text: 'All (${_counts?.all ?? 0})'),
                      Tab(text: 'Critical (${_counts?.critical ?? 0})'),
                      Tab(text: 'Action Required (${_counts?.actionRequired ?? 0})'),
                      Tab(text: 'Warnings (${_counts?.warning ?? 0})'),
                      Tab(text: 'System (${_counts?.system ?? 0})'),
                    ],
                  ),
                ),
                  InkWell(
                    onTap: _markAllAsRead,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Mark All as Read',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1),
              const SizedBox(height: 24),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _tabView(_allFuture),
                    _tabView(_criticalFuture),
                    _tabView(_actionRequiredFuture),
                    _tabView(_warningFuture),
                    _tabView(_systemFuture),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tabView(Future<NotificationsPageData> future) {
    return AsyncView<NotificationsPageData>(
      future: future,
      onRetry: () => setState(_loadAll),
      builder: (context, data) {
        if (data.items.isEmpty) {
          return Center(
            child: Text(
              'No notifications',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: data.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = data.items[index];
            return _notificationItem(
              item.title,
              item.body,
              item.severity,
              DateFormat('MMM d, y h:mm a').format(item.createdAt),
              read: item.read,
            );
          },
        );
      },
    );
  }

  Widget _notificationItem(String title, String subtitle, String type, String time, {bool read = false}) {
    Color typeColor;
    Color typeBg;
    if (type == 'critical') {
      typeColor = const Color(0xFFDC2626);
      typeBg = const Color(0xFFFECACA);
    } else if (type == 'action_required' || type == 'warning') {
      typeColor = const Color(0xFFD97706);
      typeBg = const Color(0xFFFDE68A);
    } else {
      typeColor = const Color(0xFF16A34A);
      typeBg = const Color(0xFFBBF7D0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: read ? Colors.white70 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: typeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              type,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: typeColor,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
