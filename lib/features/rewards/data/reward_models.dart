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

  int get pageCount =>
      limit <= 0 ? 1 : ((total + limit - 1) ~/ limit).clamp(1, 1 << 30);

  factory RewardsPageData.fromJson(Map<String, dynamic> j) => RewardsPageData(
        items: ((j['items'] as List?) ?? const [])
            .map((e) => RewardItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        subcategories: ((j['subcategories'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        total: (j['total'] as num?)?.toInt() ?? 0,
        page: (j['page'] as num?)?.toInt() ?? 1,
        limit: (j['limit'] as num?)?.toInt() ?? 12,
      );
}

/// Multipart payload for creating/updating a reward. [imageBytes] is optional
/// on edit (omit to keep the existing image).
class RewardForm {
  final String? name;
  final String? description;
  final String type;
  final String category;
  final String? subcategory;
  final String? network;
  final String? variationCode;
  final num? priceKobo;
  final num coinCost;
  final num? cashCostKobo;
  final num? discountPercent;
  final num? stock;
  final List<int>? imageBytes;
  final String? imageFilename;

  const RewardForm({
    this.name,
    this.description,
    required this.type,
    required this.category,
    this.subcategory,
    this.network,
    this.variationCode,
    this.priceKobo,
    required this.coinCost,
    this.cashCostKobo,
    this.discountPercent,
    this.stock,
    this.imageBytes,
    this.imageFilename,
  });

  Map<String, dynamic> toFields() {
    final map = <String, dynamic>{
      'type': type,
      'category': category,
      'coin_cost': coinCost,
    };
    if (name != null) map['name'] = name;
    if (description != null && description!.isNotEmpty)
      map['description'] = description;
    if (subcategory != null && subcategory!.isNotEmpty)
      map['subcategory'] = subcategory;
    if (network != null && network!.isNotEmpty) map['network'] = network;
    if (variationCode != null && variationCode!.isNotEmpty)
      map['variation_code'] = variationCode;
    if (priceKobo != null) map['price_kobo'] = priceKobo;
    if (cashCostKobo != null) map['cash_cost_kobo'] = cashCostKobo;
    if (discountPercent != null) map['discount_percent'] = discountPercent;
    if (stock != null) map['stock'] = stock;
    return map;
  }
}

class DataPlan {
  final String variationCode;
  final String name;
  final int amountKobo;

  const DataPlan({
    required this.variationCode,
    required this.name,
    required this.amountKobo,
  });

  factory DataPlan.fromJson(Map<String, dynamic> json) {
    return DataPlan(
      variationCode: json['variation_code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      amountKobo: (json['amount_kobo'] as num?)?.toInt() ?? 0,
    );
  }
}
