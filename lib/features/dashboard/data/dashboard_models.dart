/// Models for `GET /admin/dashboard?range=…`.

class DashboardTile {
  final num value;
  final double? changePercent;
  const DashboardTile(this.value, [this.changePercent]);

  /// Tiles are sometimes a plain number and sometimes `{value, change_percent}`.
  factory DashboardTile.from(dynamic v) {
    if (v is Map) {
      return DashboardTile(
        (v['value'] as num?) ?? 0,
        (v['change_percent'] as num?)?.toDouble(),
      );
    }
    return DashboardTile((v as num?) ?? 0);
  }
}

class ChartPoint {
  final String day;
  final double value;
  const ChartPoint(this.day, this.value);

  factory ChartPoint.fromJson(Map<String, dynamic> j) => ChartPoint(
        j['day']?.toString() ?? '',
        (j['value'] as num?)?.toDouble() ?? 0,
      );
}

class ActivityEntry {
  final String username;
  final String reason;
  final num amount;
  final String currency;
  final String? createdAt;

  const ActivityEntry({
    required this.username,
    required this.reason,
    required this.amount,
    required this.currency,
    this.createdAt,
  });

  factory ActivityEntry.fromJson(Map<String, dynamic> j) => ActivityEntry(
        username: j['username'] as String? ?? '—',
        reason: j['reason'] as String? ?? '',
        amount: (j['amount'] as num?) ?? 0,
        currency: j['currency'] as String? ?? '',
        createdAt: j['created_at'] as String?,
      );
}

class TopPlayer {
  final String username;
  final num rounds;
  final num coins;
  const TopPlayer(
      {required this.username, required this.rounds, required this.coins});

  factory TopPlayer.fromJson(Map<String, dynamic> j) => TopPlayer(
        username: j['username'] as String? ?? '—',
        rounds: (j['rounds'] as num?) ?? 0,
        coins: (j['coins'] as num?) ?? 0,
      );
}

class UpcomingTournament {
  final String id;
  final String name;
  final String status;
  final String? startsAt;
  final num entryFeeCoins;
  final num prizePoolKobo;
  final num entrants;

  const UpcomingTournament({
    required this.id,
    required this.name,
    required this.status,
    this.startsAt,
    required this.entryFeeCoins,
    required this.prizePoolKobo,
    required this.entrants,
  });

  factory UpcomingTournament.fromJson(Map<String, dynamic> j) =>
      UpcomingTournament(
        id: j['id']?.toString() ?? '',
        name: j['name'] as String? ?? '—',
        status: j['status'] as String? ?? 'upcoming',
        startsAt: j['starts_at'] as String?,
        entryFeeCoins: (j['entry_fee_coins'] as num?) ?? 0,
        prizePoolKobo: (j['prize_pool_kobo'] as num?) ?? 0,
        entrants: (j['entrants'] as num?) ?? 0,
      );
}

class DashboardData {
  final String range;
  final DashboardTile totalUsers;
  final DashboardTile newSignups;
  final DashboardTile activePlayers;
  final DashboardTile roundsPlayed;
  final DashboardTile coinsAwarded;
  final DashboardTile coinsRedeemed;
  final DashboardTile revenueKobo;
  final DashboardTile adViews;
  final DashboardTile tournamentEntries;
  final DashboardTile homeScreenInstalls;
  final DashboardTile homeScreenInstallsTotal;

  final num coinsEarnedAllTime;
  final num coinsRedeemedAllTime;
  final num coinsInCirculation;

  final List<ChartPoint> dailyActivePlayers;
  final List<ChartPoint> roundsPlayedSeries;
  final List<ActivityEntry> recentActivity;
  final List<TopPlayer> topPlayers;
  final List<UpcomingTournament> upcomingTournaments;

  const DashboardData({
    required this.range,
    required this.totalUsers,
    required this.newSignups,
    required this.activePlayers,
    required this.roundsPlayed,
    required this.coinsAwarded,
    required this.coinsRedeemed,
    required this.revenueKobo,
    required this.adViews,
    required this.tournamentEntries,
    required this.homeScreenInstalls,
    required this.homeScreenInstallsTotal,
    required this.coinsEarnedAllTime,
    required this.coinsRedeemedAllTime,
    required this.coinsInCirculation,
    required this.dailyActivePlayers,
    required this.roundsPlayedSeries,
    required this.recentActivity,
    required this.topPlayers,
    required this.upcomingTournaments,
  });

  factory DashboardData.fromJson(Map<String, dynamic> j) {
    final tiles = (j['tiles'] as Map?)?.cast<String, dynamic>() ?? const {};
    final coins = (j['coins'] as Map?)?.cast<String, dynamic>() ?? const {};
    final charts = (j['charts'] as Map?)?.cast<String, dynamic>() ?? const {};

    List<ChartPoint> points(String key) => ((charts[key] as List?) ?? const [])
        .map((e) => ChartPoint.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) =>
        ((j[key] as List?) ?? const [])
            .map((e) => f((e as Map).cast<String, dynamic>()))
            .toList();

    return DashboardData(
      range: j['range'] as String? ?? '',
      totalUsers: DashboardTile.from(tiles['total_users']),
      newSignups: DashboardTile.from(tiles['new_signups']),
      activePlayers: DashboardTile.from(tiles['active_players']),
      roundsPlayed: DashboardTile.from(tiles['rounds_played']),
      coinsAwarded: DashboardTile.from(tiles['coins_awarded']),
      coinsRedeemed: DashboardTile.from(tiles['coins_redeemed']),
      revenueKobo: DashboardTile.from(tiles['revenue_kobo']),
      adViews: DashboardTile.from(tiles['ad_views']),
      tournamentEntries: DashboardTile.from(tiles['tournament_entries']),
      homeScreenInstalls: DashboardTile.from(tiles['home_screen_installs']),
      homeScreenInstallsTotal:
          DashboardTile.from(tiles['home_screen_installs_total']),
      coinsEarnedAllTime: (coins['earned_all_time'] as num?) ?? 0,
      coinsRedeemedAllTime: (coins['redeemed_all_time'] as num?) ?? 0,
      coinsInCirculation: (coins['in_circulation'] as num?) ?? 0,
      dailyActivePlayers: points('daily_active_players'),
      roundsPlayedSeries: points('rounds_played'),
      recentActivity: list('recent_activity', ActivityEntry.fromJson),
      topPlayers: list('top_players_this_week', TopPlayer.fromJson),
      upcomingTournaments:
          list('upcoming_tournaments', UpcomingTournament.fromJson),
    );
  }
}
