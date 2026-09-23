import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/di.dart';
import '../../shared/widgets/async_view.dart';
import '../../theme/app_theme.dart';
import '../games/data/game_models.dart';
import '../games/tournament_only.dart';
import 'data/tournament_models.dart';

const tournamentGames = {
  'trivia': 'Trivia',
  'picture_puzzle': 'Picture Puzzle',
  'xoxo': 'XOXO',
};

class TournamentContentDraft {
  final Set<String> games;
  final Set<String> categories;
  final Set<String> imageIds;
  bool timeBooster;

  TournamentContentDraft.from(TournamentItem? existing)
      : games = {...?existing?.games},
        categories = {...?existing?.triviaCategories},
        imageIds = {...?existing?.puzzleImageIds},
        timeBooster = existing?.timeBoosterEnabled ?? false {
    if (existing == null) games.addAll(tournamentGames.keys);
  }

  bool get hasTrivia => games.contains('trivia');
  bool get hasPuzzle => games.contains('picture_puzzle');

  String? get problem {
    if (games.isEmpty) return 'Choose at least one game';
    if (hasTrivia && categories.isEmpty) {
      return 'Choose at least one trivia category';
    }
    if (hasPuzzle && imageIds.isEmpty) {
      return 'Choose at least one puzzle picture';
    }
    return null;
  }

  List<String> get chosenCategories => hasTrivia ? categories.toList() : [];
  List<String> get chosenImageIds => hasPuzzle ? imageIds.toList() : [];
  bool get chosenTimeBooster => hasPuzzle && timeBooster;
}

class TournamentContentSection extends StatefulWidget {
  final TournamentContentDraft draft;
  final VoidCallback onChanged;

  const TournamentContentSection(
      {super.key, required this.draft, required this.onChanged});

  @override
  State<TournamentContentSection> createState() =>
      _TournamentContentSectionState();
}

class _TournamentContentSectionState extends State<TournamentContentSection> {
  late Future<List<TriviaCategory>> _categories;
  late Future<List<PuzzleImage>> _images;

  TournamentContentDraft get _draft => widget.draft;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadImages();
  }

  void _loadCategories() {
    _categories = gamesRepository
        .detail('trivia')
        .then((d) => d.library?.categories ?? const []);
  }

  void _loadImages() {
    _images = gamesRepository.detail('picture_puzzle').then((d) =>
        (d.library?.images ?? const []).where((i) => i.isActive).toList());
  }

  void _toggle(Set<String> set, String value, bool on) {
    on ? set.add(value) : set.remove(value);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Games'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in tournamentGames.entries)
              FilterChip(
                label: Text(entry.value),
                selected: _draft.games.contains(entry.key),
                onSelected: (on) => _toggle(_draft.games, entry.key, on),
              ),
          ],
        ),
        if (_draft.hasTrivia) ...[
          const SizedBox(height: 14),
          _label('Trivia Categories'),
          AsyncView<List<TriviaCategory>>(
            future: _categories,
            minHeight: 60,
            onRetry: () => setState(_loadCategories),
            builder: (context, categories) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in categories)
                  FilterChip(
                    avatar: c.tournamentOnly
                        ? const Icon(Icons.emoji_events,
                            size: 16, color: AppColors.primary)
                        : null,
                    label: Text('${c.category} (${c.questions})'),
                    selected: _draft.categories.contains(c.category),
                    onSelected: (on) =>
                        _toggle(_draft.categories, c.category, on),
                  ),
              ],
            ),
          ),
        ],
        if (_draft.hasPuzzle) ...[
          const SizedBox(height: 14),
          _label('Puzzle Pictures (${_draft.imageIds.length} chosen)'),
          AsyncView<List<PuzzleImage>>(
            future: _images,
            minHeight: 60,
            onRetry: () => setState(_loadImages),
            builder: (context, images) => ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final image in images)
                      _PictureChoice(
                        image: image,
                        selected: _draft.imageIds.contains(image.id),
                        onTap: () => _toggle(_draft.imageIds, image.id,
                            !_draft.imageIds.contains(image.id)),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: _draft.timeBooster,
                  onChanged: (on) {
                    _draft.timeBooster = on;
                    widget.onChanged();
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ),
              Text('Allow the time booster in the picture puzzle',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      );
}

class _PictureChoice extends StatelessWidget {
  final PuzzleImage image;
  final bool selected;
  final VoidCallback onTap;

  const _PictureChoice(
      {required this.image, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: image.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.divider,
                width: selected ? 3 : 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(image.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textMuted)),
                if (image.tournamentOnly)
                  const Positioned(
                      left: 4, bottom: 4, child: TournamentOnlyBadge()),
                if (selected)
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(Icons.check_circle,
                        size: 20, color: AppColors.primary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
