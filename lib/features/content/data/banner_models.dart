class BannerItem {
  final String id;
  final String name;
  final String placement;
  final String imageUrl;
  final String? targetUrl;
  final int width;
  final int height;
  final String format;
  final bool sizeMismatch;
  final String status;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int impressions;
  final int clicks;
  final num ctr;
  final DateTime createdAt;

  BannerItem({
    required this.id,
    required this.name,
    required this.placement,
    required this.imageUrl,
    this.targetUrl,
    required this.width,
    required this.height,
    required this.format,
    required this.sizeMismatch,
    required this.status,
    this.startsAt,
    this.endsAt,
    required this.impressions,
    required this.clicks,
    required this.ctr,
    required this.createdAt,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'],
      name: json['name'],
      placement: json['placement'],
      imageUrl: json['image_url'],
      targetUrl: json['target_url'],
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      format: json['format'] ?? '',
      sizeMismatch: json['size_mismatch'] == true,
      status: json['status'] ?? 'inactive',
      startsAt: json['starts_at'] != null ? DateTime.parse(json['starts_at']).toLocal() : null,
      endsAt: json['ends_at'] != null ? DateTime.parse(json['ends_at']).toLocal() : null,
      impressions: json['impressions'] ?? 0,
      clicks: json['clicks'] ?? 0,
      ctr: json['ctr'] ?? 0,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}

class BannersPageData {
  final List<BannerItem> items;
  final int total;
  final int page;
  final int limit;

  BannersPageData({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory BannersPageData.fromJson(Map<String, dynamic> json) {
    return BannersPageData(
      items: (json['items'] as List?)?.map((x) => BannerItem.fromJson(x)).toList() ?? [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
    );
  }
}

class PlacementItem {
  final String placement;
  final int width;
  final int height;
  final String label;

  PlacementItem({
    required this.placement,
    required this.width,
    required this.height,
    required this.label,
  });

  factory PlacementItem.fromJson(Map<String, dynamic> json) {
    return PlacementItem(
      placement: json['placement'],
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      label: json['label'] ?? '',
    );
  }
}

class PlacementsData {
  final List<PlacementItem> items;

  PlacementsData({required this.items});

  factory PlacementsData.fromJson(Map<String, dynamic> json) {
    return PlacementsData(
      items: (json['items'] as List?)?.map((x) => PlacementItem.fromJson(x)).toList() ?? [],
    );
  }
}
