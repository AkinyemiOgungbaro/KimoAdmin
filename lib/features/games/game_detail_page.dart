import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_exception.dart';
import '../../core/di.dart';
import '../../core/format.dart';
import '../../core/range.dart';
import '../../shared/widgets/admin_scaffold.dart';
import '../../shared/widgets/form_fields.dart';
import '../../shared/widgets/range_dropdown.dart';
import '../../shared/widgets/paginator.dart';
import '../../shared/widgets/stat_card.dart';
import '../../theme/app_theme.dart';
import 'data/game_models.dart';

class GameDetailPage extends StatefulWidget {
  final String gameKey; // picture_puzzle | trivia | xoxo

  const GameDetailPage({super.key, required this.gameKey});

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  RangePeriod _period = RangePeriod.month;

  bool _loading = true;
  Object? _error;
  GameSummary? _summary;
  PuzzleLibrary? _library;

  // Editable settings mirror (kept in sync with PATCH responses).
  bool _maintenance = false;
  bool _randomise = false;
  num _maxCoins = 0;
  String _difficulty = 'medium';
  bool _saving = false;

  static const _icons = {
    'picture_puzzle': 'assets/images/picture_puzzle_3d.png',
    'xoxo': 'assets/images/xo_3d.png',
    'trivia': 'assets/images/trivia_3d.png',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await gamesRepository.detail(widget.gameKey, range: _period.token);
      if (!mounted) return;
      setState(() {
        _summary = d.summary;
        _library = d.library;
        _maintenance = d.summary.maintenance;
        _randomise = d.summary.randomiseImages;
        _maxCoins = d.summary.maxCoins;
        _difficulty = d.summary.difficulty;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _onPeriod(RangePeriod p) {
    if (p == _period) return;
    setState(() => _period = p);
    _load();
  }

  Future<void> _patch(GameSettingsPatch patch, {VoidCallback? onFail}) async {
    setState(() => _saving = true);
    try {
      final s = await gamesRepository.updateSettings(widget.gameKey, patch);
      if (!mounted) return;
      setState(() {
        if (_summary != null) {
          _summary = _summary!.copyWith(
            maintenance: s.maintenance,
            randomiseImages: s.randomiseImages,
            maxCoins: s.maxCoins,
            difficulty: s.difficulty,
            status: s.status,
          );
        } else {
          _summary = s;
        }
        _maintenance = s.maintenance;
        _randomise = s.randomiseImages;
        _maxCoins = s.maxCoins;
        _difficulty = s.difficulty;
      });
    } catch (e) {
      onFail?.call();
      _toast(e is ApiException ? e.message : 'Could not save settings', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toggleMaintenance(bool v) {
    final prev = _maintenance;
    setState(() => _maintenance = v);
    _patch(GameSettingsPatch(maintenance: v), onFail: () => setState(() => _maintenance = prev));
  }

  void _toggleRandomise(bool v) {
    final prev = _randomise;
    setState(() => _randomise = v);
    _patch(GameSettingsPatch(randomiseImages: v), onFail: () => setState(() => _randomise = prev));
  }

  void _setDifficulty(String value) {
    if (value == _difficulty) return;
    final prev = _difficulty;
    setState(() => _difficulty = value);
    _patch(GameSettingsPatch(difficulty: value), onFail: () => setState(() => _difficulty = prev));
  }

  Future<void> _editMaxCoins() async {
    final result = await promptForText(
      context,
      title: 'Set max coins',
      label: 'Coins awarded per round',
      initial: _maxCoins.toString(),
      number: true,
    );
    if (result == null) return;
    final parsed = num.tryParse(result.trim());
    if (parsed == null || parsed < 0) {
      _toast('Enter a valid number', error: true);
      return;
    }
    _patch(GameSettingsPatch(maxCoins: parsed));
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.statusRed : null,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/games',
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: _loading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
            : _error != null
                ? _errorView()
                : _content(),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.statusRed, size: 32),
          const SizedBox(height: 10),
          Text(_error is ApiException ? (_error as ApiException).message : 'Could not load game',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    final s = _summary!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top bar: back + breadcrumb + maintenance + range
        Row(
          children: [
            IconButton(
              onPressed: () => context.go('/games'),
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              tooltip: 'Back to games',
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 4),
            Text('Games',
                style: GoogleFonts.inter(
                    fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Spacer(),
            if (_saving)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SizedBox(
                    width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            Text('Maintenance',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            Switch(
              value: _maintenance,
              onChanged: _saving ? null : _toggleMaintenance,
              activeThumbColor: AppColors.statusRed,
              activeTrackColor: AppColors.statusRedBg,
            ),
            const SizedBox(width: 16),
            RangeDropdown(value: _period, onChanged: _onPeriod),
          ],
        ),
        const SizedBox(height: 20),

        // Title + set-amount
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: _icons.containsKey(widget.gameKey)
                      ? Image.asset(_icons[widget.gameKey]!, width: 26, height: 26)
                      : const Text('🎮', style: TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 12),
            Text(s.name,
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(width: 24),
            Text('Max coins',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(Format.number(_maxCoins),
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(width: 6),
            TextButton(
              onPressed: _saving ? null : _editMaxCoins,
              child: Text('Edit',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _statCards(s),
        const SizedBox(height: 20),

        Expanded(child: _gameContent(s)),
      ],
    );
  }

  Widget _statCards(GameSummary s) {
    final cards = <Widget>[
      ColoredStatCard(
        label: 'Rounds Played',
        value: Format.number(s.roundsPlayed),
        borderColor: AppColors.statGreen,
        valueColor: AppColors.statGreen,
      ),
      ColoredStatCard(
        label: 'Total Coins Won',
        value: Format.compact(s.coinsWon),
        borderColor: AppColors.statBlue,
        valueColor: AppColors.statBlue,
      ),
      ColoredStatCard(
        label: 'Completion Rate',
        value: Format.rate(s.completionRate, decimals: 1),
        borderColor: AppColors.statYellow,
        valueColor: AppColors.statYellow,
      ),
      ColoredStatCard(
        label: 'Avg. Coins Earned',
        value: Format.number(s.avgCoinsEarned),
        borderColor: AppColors.statRed,
        valueColor: AppColors.statRed,
      ),
      ColoredStatCard(
        label: 'Avg. Session',
        value: Format.durationFromSeconds(s.avgSessionSeconds),
        borderColor: AppColors.statPurple,
        valueColor: AppColors.statPurple,
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }

  Widget _gameContent(GameSummary s) {
    if (s.isPuzzle) {
      return _PuzzleImagesPanel(
        initial: _library?.images ?? const [],
        initialTotal: _library?.total ?? 0,
        randomise: _randomise,
        saving: _saving,
        onRandomiseChanged: _toggleRandomise,
      );
    }
    if (s.isTrivia) return const _TriviaPanel();
    if (s.isXoxo) {
      return _XoxoPanel(difficulty: _difficulty, saving: _saving, onChanged: _setDifficulty);
    }
    return const SizedBox();
  }
}

// ── Puzzle: upload panel + real thumbnail grid with delete ──────────────────
class _PuzzleImagesPanel extends StatefulWidget {
  final List<PuzzleImage> initial;
  final int initialTotal;
  final bool randomise;
  final bool saving;
  final ValueChanged<bool> onRandomiseChanged;

  const _PuzzleImagesPanel({
    required this.initial,
    required this.initialTotal,
    required this.randomise,
    required this.saving,
    required this.onRandomiseChanged,
  });

  @override
  State<_PuzzleImagesPanel> createState() => _PuzzleImagesPanelState();
}

class _PuzzleImagesPanelState extends State<_PuzzleImagesPanel> {
  late List<PuzzleImage> _images = List.of(widget.initial);
  late int _total = widget.initialTotal;
  bool _uploading = false;

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.statusRed : null,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _upload() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      _toast('Could not read that file', error: true);
      return;
    }
    final suggested = file.name.contains('.')
        ? file.name.substring(0, file.name.lastIndexOf('.'))
        : file.name;
    if (!mounted) return;
    final name = await promptForText(context,
        title: 'Name this image', label: 'Image name', initial: suggested);
    if (name == null || name.trim().isEmpty) return;

    setState(() => _uploading = true);
    try {
      final img = await gamesRepository.uploadPuzzleImage(
          name: name.trim(), bytes: bytes, filename: file.name);
      setState(() {
        _images = [img, ..._images];
        _total += 1;
      });
      _toast('Image uploaded');
    } catch (e) {
      _toast(e is ApiException ? e.message : 'Upload failed', error: true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _delete(PuzzleImage img) async {
    final ok = await showConfirmDialog(context,
        title: 'Delete image',
        message: 'Remove "${img.name}" from the puzzle library?',
        confirmLabel: 'Delete',
        destructive: true);
    if (ok != true) return;
    try {
      await gamesRepository.deletePuzzleImage(img.id);
      setState(() {
        _images = _images.where((e) => e.id != img.id).toList();
        _total = (_total - 1).clamp(0, 1 << 30);
      });
      _toast('Image deleted');
    } catch (e) {
      _toast(e is ApiException ? e.message : 'Delete failed', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload panel
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: _uploading ? null : _upload,
                  borderRadius: BorderRadius.circular(12),
                  child: DottedBorder(
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 44, color: AppColors.primary),
                          const SizedBox(height: 12),
                          Text('Click to choose an image',
                              style: GoogleFonts.inter(
                                  fontSize: 14, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('PNG or JPG',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _uploading ? null : _upload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: _uploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text('Upload image',
                            style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Image library
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: widget.randomise,
                        onChanged: widget.saving ? null : widget.onRandomiseChanged,
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                    Text('Randomise images',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                    const Spacer(),
                    Text('${Format.number(_total)} images',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _images.isEmpty
                      ? Center(
                          child: Text('No images yet — upload one to get started',
                              style:
                                  GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          itemCount: _images.length,
                          itemBuilder: (ctx, i) => _PuzzleTile(
                            image: _images[i],
                            onDelete: () => _delete(_images[i]),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PuzzleTile extends StatelessWidget {
  final PuzzleImage image;
  final VoidCallback onDelete;
  const _PuzzleTile({required this.image, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            image.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.pageBg,
              child: const Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: AppColors.pageBg,
                child: const Center(
                    child: SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
              );
            },
          ),
          // Delete control — white circular button, dark icon (visible; the old
          // code used color.withOpacity(2) which clamped to the tile colour).
          Positioned(
            top: 6,
            right: 6,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 1,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.delete_outline, size: 16, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          if (!image.isActive)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Inactive',
                    style: GoogleFonts.inter(fontSize: 9, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Trivia: CSV import + category-filtered question list with delete ────────
class _TriviaPanel extends StatefulWidget {
  const _TriviaPanel();

  @override
  State<_TriviaPanel> createState() => _TriviaPanelState();
}

class _TriviaPanelState extends State<_TriviaPanel> {
  static const _limit = 12;
  static const _triviaCategories = [
    'Bible Quiz',
    'Business',
    'Football',
    'General Knowledge',
    'History',
    'Mathematics',
    'Music',
    'Nigerian Affairs',
    'Science',
  ];
  
  final _importCategory = TextEditingController(text: _triviaCategories.first);
  final _filterCategory = TextEditingController(text: _triviaCategories.first);

  String _filter = _triviaCategories.first;
  int _page = 1;
  PlatformFile? _pickedFile;
  bool _importing = false;
  late Future<TriviaPageData> _future;

  InputDecorationTheme _dropdownTheme() => InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: AppColors.pageBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _importCategory.dispose();
    _filterCategory.dispose();
    super.dispose();
  }

  void _load() {
    _future = gamesRepository.listTrivia(category: _filter, page: _page, limit: _limit);
  }

  void _reload() => setState(_load);

  void _applyFilter() {
    setState(() {
      _filter = _filterCategory.text.trim();
      _page = 1;
      _load();
    });
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.statusRed : null,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _pick() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    setState(() => _pickedFile = picked.files.first);
  }

  Future<void> _import() async {
    final category = _importCategory.text.trim();
    if (category.isEmpty) {
      _toast('Enter a category', error: true);
      return;
    }
    final file = _pickedFile;
    if (file == null || file.bytes == null) {
      _toast('Choose a CSV file', error: true);
      return;
    }
    setState(() => _importing = true);
    try {
      final result = await gamesRepository.importTrivia(
          category: category, bytes: file.bytes!, filename: file.name);
      _toast('Added ${result.added} • ${result.duplicates} duplicates'
          '${result.rejected.isNotEmpty ? ' • ${result.rejected.length} rejected' : ''}');
      setState(() {
        _pickedFile = null;
        _page = 1;
        _load();
      });
    } catch (e) {
      _toast(e is ApiException ? e.message : 'Import failed', error: true);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _delete(TriviaQuestion q) async {
    final ok = await showConfirmDialog(context,
        title: 'Delete question',
        message: q.prompt,
        confirmLabel: 'Delete',
        destructive: true);
    if (ok != true) return;
    try {
      await gamesRepository.deleteTrivia(q.id);
      _toast('Question deleted');
      _reload();
    } catch (e) {
      _toast(e is ApiException ? e.message : 'Delete failed', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: _importCard()),
        const SizedBox(width: 16),
        Expanded(flex: 6, child: _listCard()),
      ],
    );
  }

  Widget _importCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Import questions',
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Upload a CSV of questions for a category.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          InkWell(
            onTap: _importing ? null : _pick,
            borderRadius: BorderRadius.circular(12),
            child: DottedBorder(
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_pickedFile == null ? Icons.upload_file_outlined : Icons.description_outlined,
                        size: 40, color: AppColors.primary),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _pickedFile?.name ?? 'Click to choose a CSV file',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Category',
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          DropdownMenu<String>(
            controller: _importCategory,
            initialSelection: _importCategory.text,
            expandedInsets: EdgeInsets.zero,
            dropdownMenuEntries: _triviaCategories.map((c) => DropdownMenuEntry(value: c, label: c)).toList(),
            textStyle: GoogleFonts.inter(fontSize: 13),
            inputDecorationTheme: _dropdownTheme(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _importing ? null : _import,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: _importing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text('Import CSV',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: DropdownMenu<String>(
                    controller: _filterCategory,
                    initialSelection: _filterCategory.text,
                    expandedInsets: EdgeInsets.zero,
                    leadingIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                    dropdownMenuEntries: _triviaCategories.map((c) => DropdownMenuEntry(value: c, label: c)).toList(),
                    textStyle: GoogleFonts.inter(fontSize: 13),
                    inputDecorationTheme: _dropdownTheme(),
                    onSelected: (v) {
                      if (v != null) {
                        _filterCategory.text = v;
                        _applyFilter();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: _applyFilter, child: const Text('Apply')),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<TriviaPageData>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 3));
                }
                if (snap.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          snap.error is ApiException
                              ? (snap.error as ApiException).message
                              : 'Could not load questions',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(onPressed: _reload, child: const Text('Retry')),
                      ],
                    ),
                  );
                }
                final data = snap.data;
                if (data == null || data.items.isEmpty) {
                  return Center(
                    child: Text('No questions found',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: data.items.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (ctx, i) => _QuestionTile(
                          q: data.items[i],
                          onDelete: () => _delete(data.items[i]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Paginator(
                      currentPage: data.page,
                      pageCount: data.pageCount,
                      onSelect: (p) => setState(() {
                        _page = p;
                        _load();
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final TriviaQuestion q;
  final VoidCallback onDelete;
  const _QuestionTile({required this.q, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (q.category.isNotEmpty) _chip(q.category, AppColors.primaryLight, AppColors.primary),
                  if (q.difficulty.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _chip(q.difficulty, AppColors.pageBg, AppColors.textSecondary),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(q.prompt,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              ...List.generate(q.options.length, (i) {
                final correct = i == q.answerIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Icon(
                        correct ? Icons.check_circle : Icons.circle_outlined,
                        size: 14,
                        color: correct ? AppColors.statusGreen : AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(q.options[i],
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: correct ? AppColors.textPrimary : AppColors.textSecondary,
                                fontWeight: correct ? FontWeight.w600 : FontWeight.w400)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textSecondary),
          tooltip: 'Delete',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ── XOXO: difficulty selector ───────────────────────────────────────────────
class _XoxoPanel extends StatelessWidget {
  final String difficulty;
  final bool saving;
  final ValueChanged<String> onChanged;

  const _XoxoPanel({required this.difficulty, required this.saving, required this.onChanged});

  static const _options = [
    ('simple', 'Simple'),
    ('medium', 'Medium'),
    ('hard', 'Hard'),
    ('very_hard', 'Very Hard'),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose difficulty',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Sets the AI strength for new XOXO matches.',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _options.map((o) {
                final selected = o.$1 == difficulty;
                return InkWell(
                  onTap: saving ? null : () => onChanged(o.$1),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryLight : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.divider,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          size: 18,
                          color: selected ? AppColors.primary : AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Text(o.$2,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: selected ? AppColors.primary : AppColors.textPrimary)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ──────────────────────────────────────────────────────────

/// Simple text-input dialog. Returns the entered text, or null if cancelled.
Future<String?> promptForText(
  BuildContext context, {
  required String title,
  required String label,
  String initial = '',
  bool number = false,
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: fieldDecoration(hint: label),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, controller.text),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

/// Confirmation dialog. Returns true when the user confirms.
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
      content: Text(message, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
              backgroundColor: destructive ? AppColors.statusRed : AppColors.primary),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

/// Dashed-border wrapper for upload drop zones.
class DottedBorder extends StatelessWidget {
  final Widget child;
  const DottedBorder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    const radius = Radius.circular(12);

    final path = Path()..addRRect(RRect.fromLTRBR(0, 0, size.width, size.height, radius));
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
            metric.extractPath(distance, next < metric.length ? next : metric.length), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
