import 'tournament_models.dart';

class TournamentPrize {
  final int rank;
  final String prizeType;
  final num amount;
  final String? itemName;
  final String status;
  final String? winnerUserId;
  final String? winnerName;
  final String? winnerUsername;
  final String? winnerEmail;
  final String? winnerPhone;
  final num? finalPoints;
  final List<String> flags;
  final String? claimCode;
  final String? fulfilmentMethod;
  final String? fulfilledAt;
  final String? fulfilmentNote;
  final String? fulfilledByName;

  const TournamentPrize({
    required this.rank,
    required this.prizeType,
    required this.amount,
    this.itemName,
    required this.status,
    this.winnerUserId,
    this.winnerName,
    this.winnerUsername,
    this.winnerEmail,
    this.winnerPhone,
    this.finalPoints,
    this.flags = const [],
    this.claimCode,
    this.fulfilmentMethod,
    this.fulfilledAt,
    this.fulfilmentNote,
    this.fulfilledByName,
  });

  bool get awarded => winnerUserId != null;
  bool get toBeGiven => status == 'awaiting_fulfilment' || status == 'sending';

  factory TournamentPrize.fromJson(Map<String, dynamic> j) => TournamentPrize(
        rank: (j['rank'] as num?)?.toInt() ?? 0,
        prizeType: j['prize_type'] as String? ?? 'cash',
        amount: (j['amount'] as num?) ?? 0,
        itemName: j['item_name'] as String?,
        status: j['status'] as String? ?? '',
        winnerUserId: j['winner_user_id'] as String?,
        winnerName: j['winner_name'] as String?,
        winnerUsername: j['winner_username'] as String?,
        winnerEmail: j['winner_email'] as String?,
        winnerPhone: j['winner_phone'] as String?,
        finalPoints: j['final_points'] as num?,
        flags: ((j['flags'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        claimCode: j['claim_code'] as String?,
        fulfilmentMethod: j['fulfilment_method'] as String?,
        fulfilledAt: j['fulfilled_at'] as String?,
        fulfilmentNote: j['fulfilment_note'] as String?,
        fulfilledByName: j['fulfilled_by_name'] as String?,
      );
}

class TournamentPrizes {
  final String? distributedAt;
  final List<PrizeBand> bands;
  final List<TournamentPrize> items;
  final int unpaid;
  final int unawarded;

  const TournamentPrizes({
    this.distributedAt,
    required this.bands,
    required this.items,
    required this.unpaid,
    required this.unawarded,
  });

  factory TournamentPrizes.fromJson(Map<String, dynamic> j) => TournamentPrizes(
        distributedAt:
            (j['tournament'] as Map?)?['prizes_distributed_at'] as String?,
        bands: ((j['bands'] as List?) ?? const [])
            .map((e) => PrizeBand.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        items: ((j['items'] as List?) ?? const [])
            .map((e) =>
                TournamentPrize.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        unpaid: (j['unpaid'] as num?)?.toInt() ?? 0,
        unawarded: (j['unawarded'] as num?)?.toInt() ?? 0,
      );
}
