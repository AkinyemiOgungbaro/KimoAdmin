/// Models for the Games endpoints.
///
/// Game keys: `picture_puzzle`, `trivia`, `xoxo`.

class GameSummary {
  final String key;
  final String name;
  final num maxCoins;
  final bool maintenance;
  final bool randomiseImages;
  final String difficulty;
  final String status;
  final num roundsPlayed;
  final num avgSessionSeconds;
  final num avgCoinsEarned;
  final num completionRate;
  final num coinsWon;

  const GameSummary({
    required this.key,
    required this.name,
    required this.maxCoins,
    required this.maintenance,
    required this.randomiseImages,
    required this.difficulty,
    required this.status,
    required this.roundsPlayed,
    required this.avgSessionSeconds,
    required this.avgCoinsEarned,
    required this.completionRate,
    required this.coinsWon,
  });

  factory GameSummary.fromJson(Map<String, dynamic> j) => GameSummary(
        key: j['key'] as String? ?? '',
        name: j['name'] as String? ?? '',
        maxCoins: (j['max_coins'] as num?) ?? 0,
        maintenance: j['maintenance'] as bool? ?? false,
        randomiseImages: j['randomise_images'] as bool? ?? false,
        difficulty: j['difficulty'] as String? ?? 'medium',
        status: j['status'] as String? ?? 'active',
        roundsPlayed: (j['rounds_played'] as num?) ?? 0,
        avgSessionSeconds: (j['avg_session_seconds'] as num?) ?? 0,
        avgCoinsEarned: (j['avg_coins_earned'] as num?) ?? 0,
        completionRate: (j['completion_rate'] as num?) ?? 0,
        coinsWon: (j['coins_won'] as num?) ?? 0,
      );

  GameSummary copyWith({
    String? key,
    String? name,
    num? maxCoins,
    bool? maintenance,
    bool? randomiseImages,
    String? difficulty,
    String? status,
    num? roundsPlayed,
    num? avgSessionSeconds,
    num? avgCoinsEarned,
    num? completionRate,
    num? coinsWon,
  }) {
    return GameSummary(
      key: key ?? this.key,
      name: name ?? this.name,
      maxCoins: maxCoins ?? this.maxCoins,
      maintenance: maintenance ?? this.maintenance,
      randomiseImages: randomiseImages ?? this.randomiseImages,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      roundsPlayed: roundsPlayed ?? this.roundsPlayed,
      avgSessionSeconds: avgSessionSeconds ?? this.avgSessionSeconds,
      avgCoinsEarned: avgCoinsEarned ?? this.avgCoinsEarned,
      completionRate: completionRate ?? this.completionRate,
      coinsWon: coinsWon ?? this.coinsWon,
    );
  }

  bool get isPuzzle => key == 'picture_puzzle';
  bool get isTrivia => key == 'trivia';
  bool get isXoxo => key == 'xoxo';
}

class PuzzleImage {
  final String id;
  final String name;
  final String imageUrl;
  final bool isActive;
  final String? lastUsedAt;
  final String? createdAt;

  const PuzzleImage({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isActive,
    this.lastUsedAt,
    this.createdAt,
  });

  factory PuzzleImage.fromJson(Map<String, dynamic> j) => PuzzleImage(
        id: j['id']?.toString() ?? '',
        name: j['name'] as String? ?? '',
        imageUrl: j['image_url'] as String? ?? '',
        isActive: j['is_active'] as bool? ?? true,
        lastUsedAt: j['last_used_at'] as String?,
        createdAt: j['created_at'] as String?,
      );
}

class PuzzleLibrary {
  final int total;
  final List<PuzzleImage> images;
  const PuzzleLibrary({required this.total, required this.images});

  factory PuzzleLibrary.fromJson(Map<String, dynamic> j) => PuzzleLibrary(
        total: (j['total'] as num?)?.toInt() ?? 0,
        images: ((j['images'] as List?) ?? const [])
            .map((e) => PuzzleImage.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}

class GameDetail {
  final GameSummary summary;
  final String range;
  final PuzzleLibrary? library;

  const GameDetail({required this.summary, required this.range, this.library});

  factory GameDetail.fromJson(Map<String, dynamic> j) => GameDetail(
        summary: GameSummary.fromJson(j),
        range: j['range'] as String? ?? '',
        library: j['library'] is Map
            ? PuzzleLibrary.fromJson((j['library'] as Map).cast<String, dynamic>())
            : null,
      );
}

/// Settings patch for `PATCH /admin/games/{key}` (all optional).
class GameSettingsPatch {
  final String? difficulty;
  final num? maxCoins;
  final bool? maintenance;
  final bool? randomiseImages;

  const GameSettingsPatch({this.difficulty, this.maxCoins, this.maintenance, this.randomiseImages});

  Map<String, dynamic> toJson() => {
        if (difficulty != null) 'difficulty': difficulty,
        if (maxCoins != null) 'max_coins': maxCoins,
        if (maintenance != null) 'maintenance': maintenance,
        if (randomiseImages != null) 'randomise_images': randomiseImages,
      };
}

class TriviaQuestion {
  final String id;
  final String category;
  final String difficulty;
  final String prompt;
  final List<String> options;
  final int answerIndex;
  final bool isActive;
  final String? createdAt;

  const TriviaQuestion({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.prompt,
    required this.options,
    required this.answerIndex,
    required this.isActive,
    this.createdAt,
  });

  factory TriviaQuestion.fromJson(Map<String, dynamic> j) => TriviaQuestion(
        id: j['id']?.toString() ?? '',
        category: j['category'] as String? ?? '',
        difficulty: j['difficulty'] as String? ?? '',
        prompt: j['prompt'] as String? ?? '',
        options: ((j['options'] as List?) ?? const []).map((e) => e.toString()).toList(),
        answerIndex: (j['answer_index'] as num?)?.toInt() ?? -1,
        isActive: j['is_active'] as bool? ?? true,
        createdAt: j['created_at'] as String?,
      );
}

class TriviaPageData {
  final List<TriviaQuestion> items;
  final int total;
  final int page;
  final int limit;

  const TriviaPageData({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  int get pageCount => limit <= 0 ? 1 : ((total + limit - 1) ~/ limit).clamp(1, 1 << 30);

  factory TriviaPageData.fromJson(Map<String, dynamic> j) => TriviaPageData(
        items: ((j['items'] as List?) ?? const [])
            .map((e) => TriviaQuestion.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        total: (j['total'] as num?)?.toInt() ?? 0,
        page: (j['page'] as num?)?.toInt() ?? 1,
        limit: (j['limit'] as num?)?.toInt() ?? 20,
      );
}

/// Result of `POST /admin/games/trivia/questions` (CSV import).
class TriviaImportResult {
  final String category;
  final int added;
  final int duplicates;
  final List<String> rejected;

  const TriviaImportResult({
    required this.category,
    required this.added,
    required this.duplicates,
    required this.rejected,
  });

  factory TriviaImportResult.fromJson(Map<String, dynamic> j) => TriviaImportResult(
        category: j['category'] as String? ?? '',
        added: (j['added'] as num?)?.toInt() ?? 0,
        duplicates: (j['duplicates'] as num?)?.toInt() ?? 0,
        rejected: ((j['rejected'] as List?) ?? const []).map((e) => e.toString()).toList(),
      );
}
