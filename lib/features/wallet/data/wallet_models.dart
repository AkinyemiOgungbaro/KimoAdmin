import '../../../core/format.dart';
import '../../dashboard/data/dashboard_models.dart';

class WalletData {
  final WalletCashData cash;
  final WalletCoinsData coins;
  final WalletCharts charts;
  final WalletRecent recent;

  WalletData({
    required this.cash,
    required this.coins,
    required this.charts,
    required this.recent,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      cash: WalletCashData.fromJson(json['cash'] ?? {}),
      coins: WalletCoinsData.fromJson(json['coins'] ?? {}),
      charts: WalletCharts.fromJson(json['charts'] ?? {}),
      recent: WalletRecent.fromJson(json),
    );
  }
}

class WalletCashData {
  final DashboardTile totalCustomerFunds;
  final DashboardTile fundsAdded;
  final DashboardTile fundsSpent;
  final DashboardTile? reversals;
  final DashboardTile activeWallets;
  final DashboardTile? pendingDeposits;
  final DashboardTile? failedPayments;

  WalletCashData({
    required this.totalCustomerFunds,
    required this.fundsAdded,
    required this.fundsSpent,
    this.reversals,
    required this.activeWallets,
    this.pendingDeposits,
    this.failedPayments,
  });

  factory WalletCashData.fromJson(Map<String, dynamic> json) {
    return WalletCashData(
      totalCustomerFunds: DashboardTile.from(json['total_customer_funds_kobo'] ?? json['total_customer_funds']),
      fundsAdded: DashboardTile.from(json['funds_added_kobo'] ?? json['funds_added']),
      fundsSpent: DashboardTile.from(json['funds_spent_kobo'] ?? json['funds_spent']),
      reversals: (json['reversals_kobo'] ?? json['reversals']) != null ? DashboardTile.from(json['reversals_kobo'] ?? json['reversals']) : null,
      activeWallets: DashboardTile.from(json['wallets_holding_cash'] ?? json['active_wallets']),
      pendingDeposits: (json['pending_deposits_kobo'] ?? json['pending_deposits']) != null ? DashboardTile.from(json['pending_deposits_kobo'] ?? json['pending_deposits']) : null,
      failedPayments: json['failed_payments'] != null ? DashboardTile.from(json['failed_payments']) : null,
    );
  }
}

class WalletCoinsData {
  final DashboardTile inCirculation;
  final DashboardTile bonusInCirculation;
  final DashboardTile earned;
  final DashboardTile spent;
  final DashboardTile reversed;
  final DashboardTile expired;
  final DashboardTile? pendingRedemptions;
  final DashboardTile rewardsClaimed;

  WalletCoinsData({
    required this.inCirculation,
    required this.bonusInCirculation,
    required this.earned,
    required this.spent,
    required this.reversed,
    required this.expired,
    this.pendingRedemptions,
    required this.rewardsClaimed,
  });

  factory WalletCoinsData.fromJson(Map<String, dynamic> json) {
    return WalletCoinsData(
      inCirculation: DashboardTile.from(json['coins_in_circulation'] ?? json['in_circulation']),
      bonusInCirculation: DashboardTile.from(json['bonus_in_circulation']),
      earned: DashboardTile.from(json['coins_earned'] ?? json['earned']),
      spent: DashboardTile.from(json['coins_spent'] ?? json['spent']),
      reversed: DashboardTile.from(json['coin_reversals'] ?? json['reversed']),
      expired: DashboardTile.from(json['coins_expired'] ?? json['expired']),
      pendingRedemptions: json['pending_redemptions'] != null ? DashboardTile.from(json['pending_redemptions']) : null,
      rewardsClaimed: DashboardTile.from(json['rewards_claimed']),
    );
  }
}

class WalletCharts {
  final List<ChartPoint> cashBalanceTrend;
  final Map<String, int> bySource;
  final Map<String, int> bySink;
  final List<TopGame> topGames;

  WalletCharts({
    required this.cashBalanceTrend,
    required this.bySource,
    required this.bySink,
    required this.topGames,
  });

  factory WalletCharts.fromJson(Map<String, dynamic> json) {
    Map<String, int> parseChartArray(String key) {
      final list = json[key] as List?;
      if (list == null) return {};
      return Map.fromEntries(list.map((e) => MapEntry(e['label'] as String, (e['coins'] as num).toInt())));
    }

    return WalletCharts(
      cashBalanceTrend: (json['cash_balance_trend'] as List<dynamic>?)
              ?.map((e) => ChartPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bySource: parseChartArray('coins_by_source'),
      bySink: parseChartArray('coins_by_sink'),
      topGames: ((json['top_games_by_coins'] ?? json['top_games']) as List<dynamic>?)
              ?.map((e) => TopGame.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TopGame {
  final String game;
  final int coinsEarned;
  final int players;
  final int avgCoinsPerUser;

  TopGame({
    required this.game,
    required this.coinsEarned,
    required this.players,
    required this.avgCoinsPerUser,
  });

  factory TopGame.fromJson(Map<String, dynamic> json) {
    return TopGame(
      game: json['name'] ?? json['game'] as String? ?? 'Unknown',
      coinsEarned: json['coins'] ?? json['coins_earned'] as int? ?? 0,
      players: json['players'] as int? ?? 0,
      avgCoinsPerUser: json['average_per_player'] ?? json['avg_coins_per_user'] as int? ?? 0,
    );
  }
}

class WalletRecent {
  final List<Map<String, dynamic>> cashTransactions;
  final List<Map<String, dynamic>> coinTransactions;
  final List<Map<String, dynamic>> pendingRedemptions;

  WalletRecent({
    required this.cashTransactions,
    required this.coinTransactions,
    required this.pendingRedemptions,
  });

  factory WalletRecent.fromJson(Map<String, dynamic> json) {
    return WalletRecent(
      cashTransactions: (json['recent_cash'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      coinTransactions: (json['recent_coins'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      pendingRedemptions: (json['pending_redemptions'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}
