class NotificationItem {
  final String id;
  final String severity;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> context;
  final bool read;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.severity,
    required this.type,
    required this.title,
    required this.body,
    required this.context,
    required this.read,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      severity: json['severity'],
      type: json['type'],
      title: json['title'],
      body: json['body'],
      context: json['context'] as Map<String, dynamic>? ?? {},
      read: json['read'] == true,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}

class NotificationCounts {
  final int all;
  final int critical;
  final int actionRequired;
  final int warning;
  final int system;

  NotificationCounts({
    required this.all,
    required this.critical,
    required this.actionRequired,
    required this.warning,
    required this.system,
  });

  factory NotificationCounts.fromJson(Map<String, dynamic> json) {
    return NotificationCounts(
      all: json['all'] ?? 0,
      critical: json['critical'] ?? 0,
      actionRequired: json['action_required'] ?? 0,
      warning: json['warning'] ?? 0,
      system: json['system'] ?? 0,
    );
  }
}

class NotificationsPageData {
  final List<NotificationItem> items;
  final NotificationCounts counts;
  final int unread;
  final int total;
  final int page;
  final int limit;

  NotificationsPageData({
    required this.items,
    required this.counts,
    required this.unread,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory NotificationsPageData.fromJson(Map<String, dynamic> json) {
    return NotificationsPageData(
      items: (json['items'] as List).map((x) => NotificationItem.fromJson(x)).toList(),
      counts: NotificationCounts.fromJson(json['counts']),
      unread: json['unread'] ?? 0,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
    );
  }
}
