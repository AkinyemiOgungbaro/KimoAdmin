/// Models for `GET /admin/rewards`.
///
/// Categories: `gadget` | `airtime_data` | `clothing` | `food`.
/// Types: `physical` | `airtime` | `data`. Status: `active` | `out_of_stock`.

class RewardItem {
  final String id;
  final String name;
  final String? imageUrl;
  final String type;
  final String category;
  final String? subcategory;
  final String? network;
  final num coinCost;
  final num cashCostKobo;
  final num priceKobo;
  final num discountPercent;
  final num stock;
  final num redeemed;
  final String status;
  final String? providerVariationId;

  const RewardItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.type,
    required this.category,
    this.subcategory,
    this.network,
    required this.coinCost,
    required this.cashCostKobo,
    required this.priceKobo,
    required this.discountPercent,
    required this.stock,
    required this.redeemed,
    required this.status,
    this.providerVariationId,
  });

  factory RewardItem.fromJson(Map<String, dynamic> j) => RewardItem(
        id: j['id']?.toString() ?? '',
        name: j['name'] as String? ?? '',
        imageUrl: j['image_url'] as String?,
        type: j['type'] as String? ?? 'physical',
        category: j['category'] as String? ?? '',
        subcategory: j['subcategory'] as String?,
        network: j['network'] as String?,
        coinCost: (j['coin_cost'] as num?) ?? 0,
        cashCostKobo: (j['cash_cost_kobo'] as num?) ?? 0,
        priceKobo: (j['price_kobo'] as num?) ?? 0,
        discountPercent: (j['discount_percent'] as num?) ?? 0,
        stock: (j['stock'] as num?) ?? 0,
        redeemed: (j['redeemed'] as num?) ?? 0,
        status: j['status'] as String? ?? 'active',
        providerVariationId: j['provider_variation_id']?.toString(),
      );

  bool get isActive => status == 'active';
}

class RewardsPageData {
  final List<RewardItem> items;
  final List<String> subcategories;
  final int total;
  final int page;
  final int limit;

  const RewardsPageData({
    required this.items,
    required this.subcategories,
    required this.total,
    required this.page,
    required this.limit,
  });

  int get pageCount => limit <= 0 ? 1 : ((total + limit - 1) ~/ limit).clamp(1, 1 << 30);

  factory RewardsPageData.fromJson(Map<String, dynamic> j) => RewardsPageData(
        items: ((j['items'] as List?) ?? const [])
            .map((e) => RewardItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        subcategories:
            ((j['subcategories'] as List?) ?? const []).map((e) => e.toString()).toList(),
        total: (j['total'] as num?)?.toInt() ?? 0,
        page: (j['page'] as num?)?.toInt() ?? 1,
        limit: (j['limit'] as num?)?.toInt() ?? 12,
      );
}

/// Multipart payload for creating/updating a reward. [imageBytes] is optional
/// on edit (omit to keep the existing image).
class RewardForm {
  final String name;
  final String description;
  final String type;
  final String category;
  final String? subcategory;
  final num priceKobo;
  final num coinCost;
  final num cashCostKobo;
  final num stock;
  final List<int>? imageBytes;
  final String? imageFilename;

  const RewardForm({
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    this.subcategory,
    required this.priceKobo,
    required this.coinCost,
    required this.cashCostKobo,
    required this.stock,
    this.imageBytes,
    this.imageFilename,
  });

  Map<String, dynamic> toFields() => {
        'name': name,
        if (description.isNotEmpty) 'description': description,
        'type': type,
        'category': category,
        if (subcategory != null && subcategory!.isNotEmpty) 'subcategory': subcategory,
        'price_kobo': priceKobo,
        'coin_cost': coinCost,
        'cash_cost_kobo': cashCostKobo,
        'stock': stock,
      };
}
