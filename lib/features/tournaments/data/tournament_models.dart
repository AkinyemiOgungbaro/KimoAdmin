/// Models for the Tournaments endpoints.
///
/// Status values observed: `upcoming`, `live`, `over`, `cancelled`.

class TournamentItem {
  final String id;
  final String name;
  final String status;
  final String? startsAt;
  final String? endsAt;
  final num durationMinutes;
  final String? registrationOpensAt;
  final num entryFeeCoins;
  final num prizePoolKobo;
  final num attemptsPerGame;
  final num participants;
  final num participantLimit;
  final String? entryCode;
  final String? bannerUrl;
  final num completionRate;
  final num secondsRemaining;

  const TournamentItem({
    required this.id,
    required this.name,
    required this.status,
    this.startsAt,
    this.endsAt,
    required this.durationMinutes,
    this.registrationOpensAt,
    required this.entryFeeCoins,
    required this.prizePoolKobo,
    required this.attemptsPerGame,
    required this.participants,
    required this.participantLimit,
    this.entryCode,
    this.bannerUrl,
    required this.completionRate,
    required this.secondsRemaining,
  });

  factory TournamentItem.fromJson(Map<String, dynamic> j) => TournamentItem(
        id: j['id']?.toString() ?? '',
        name: j['name'] as String? ?? '',
        status: j['status'] as String? ?? 'upcoming',
        startsAt: j['starts_at'] as String?,
        endsAt: j['ends_at'] as String?,
        durationMinutes: (j['duration_minutes'] as num?) ?? 0,
        registrationOpensAt: j['registration_opens_at'] as String?,
        entryFeeCoins: (j['entry_fee_coins'] as num?) ?? 0,
        prizePoolKobo: (j['prize_pool_kobo'] as num?) ?? 0,
        attemptsPerGame: (j['attempts_per_game'] as num?) ?? 0,
        participants: (j['participants'] as num?) ?? 0,
        participantLimit: (j['participant_limit'] as num?) ?? 0,
        entryCode: j['entry_code'] as String?,
        bannerUrl: j['banner_url'] as String?,
        completionRate: (j['completion_rate'] as num?) ?? 0,
        secondsRemaining: (j['seconds_remaining'] as num?) ?? 0,
      );
}

class TournamentsPageData {
  final List<TournamentItem> items;
  final int total;
  final int page;
  final int limit;

  const TournamentsPageData({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory TournamentsPageData.fromJson(Map<String, dynamic> j) =>
      TournamentsPageData(
        items: ((j['items'] as List?) ?? const [])
            .map((e) =>
                TournamentItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        total: (j['total'] as num?)?.toInt() ?? 0,
        page: (j['page'] as num?)?.toInt() ?? 1,
        limit: (j['limit'] as num?)?.toInt() ?? 20,
      );
}

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final String? email;
  final num points;
  final num gamesScored;
  final String? lastScoredAt;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.email,
    required this.points,
    required this.gamesScored,
    this.lastScoredAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) => LeaderboardEntry(
        rank: (j['rank'] as num?)?.toInt() ?? 0,
        userId: j['user_id']?.toString() ?? '',
        username: j['username'] as String? ?? '—',
        email: j['email'] as String?,
        points: (j['points'] as num?) ?? 0,
        gamesScored: (j['games_scored'] as num?) ?? 0,
        lastScoredAt: j['last_scored_at'] as String?,
      );
}

class LeaderboardData {
  final String? tournamentId;
  final String? tournamentName;
  final String? tournamentStatus;
  final List<LeaderboardEntry> items;
  final int total;
  final int page;
  final int limit;

  const LeaderboardData({
    this.tournamentId,
    this.tournamentName,
    this.tournamentStatus,
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> j) {
    final t = (j['tournament'] as Map?)?.cast<String, dynamic>();
    return LeaderboardData(
      tournamentId: t?['id']?.toString(),
      tournamentName: t?['name'] as String?,
      tournamentStatus: t?['status'] as String?,
      items: ((j['items'] as List?) ?? const [])
          .map((e) =>
              LeaderboardEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      total: (j['total'] as num?)?.toInt() ?? 0,
      page: (j['page'] as num?)?.toInt() ?? 1,
      limit: (j['limit'] as num?)?.toInt() ?? 20,
    );
  }
}

class TournamentPlayer {
  final String username;
  final String? email;
  final String? registeredAt;
  final bool entryFeePaid;
  final num points;
  final num gamesScored;

  const TournamentPlayer({
    required this.username,
    this.email,
    this.registeredAt,
    required this.entryFeePaid,
    required this.points,
    required this.gamesScored,
  });

  factory TournamentPlayer.fromJson(Map<String, dynamic> j) {
    final fee = j['entry_fee_paid'];
    final bool paid = fee is num ? fee > 0 : (fee == true);
    return TournamentPlayer(
      username: j['username'] as String? ?? '—',
      email: j['email'] as String?,
      registeredAt: j['registered_at'] as String?,
      entryFeePaid: paid,
      points: (j['points'] as num?) ?? 0,
      gamesScored: (j['games_scored'] as num?) ?? 0,
    );
  }
}

/// Payload for `POST /admin/tournaments` and (subset of) `PATCH`.
class TournamentForm {
  final String name;
  final String startsAt; // ISO-8601
  final num durationMinutes;
  final num entryFeeCoins;
  final num prizePoolKobo;
  final num attemptsPerGame;
  final num participantLimit;
  final String? entryCode;

  const TournamentForm({
    required this.name,
    required this.startsAt,
    required this.durationMinutes,
    required this.entryFeeCoins,
    required this.prizePoolKobo,
    required this.attemptsPerGame,
    required this.participantLimit,
    this.entryCode,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'starts_at': startsAt,
        'duration_minutes': durationMinutes,
        'entry_fee_coins': entryFeeCoins,
        'prize_pool_kobo': prizePoolKobo,
        'attempts_per_game': attemptsPerGame,
        'participant_limit': participantLimit,
        if (entryCode != null && entryCode!.isNotEmpty) 'entry_code': entryCode,
      };
}
