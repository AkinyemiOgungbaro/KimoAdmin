import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/di.dart';
import '../../core/format.dart';
import '../../core/range.dart';
import '../../shared/widgets/admin_scaffold.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/range_dropdown.dart';
import '../../shared/widgets/status_badge.dart';
import '../../theme/app_theme.dart';
import 'data/game_models.dart';

class GamesListPage extends StatefulWidget {
  const GamesListPage({super.key});

  @override
  State<GamesListPage> createState() => _GamesListPageState();
}

class _GamesListPageState extends State<GamesListPage> {
  RangePeriod _period = RangePeriod.month;
  late Future<List<GameSummary>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = gamesRepository.list(range: _period.token);
  }

  void _reload() => setState(_load);

  void _onPeriod(RangePeriod p) {
    if (p == _period) return;
    setState(() {
      _period = p;
      _load();
    });
  }

  static const _gameIcons = {
    'picture_puzzle': 'assets/images/picture_puzzle_3d.png',
    'xoxo': 'assets/images/xo_3d.png',
    'trivia': 'assets/images/trivia_3d.png',
  };

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/games',
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Games',
                    style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const Spacer(),
                RangeDropdown(value: _period, onChanged: _onPeriod),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: AsyncView<List<GameSummary>>(
                future: _future,
                onRetry: _reload,
                minHeight: 300,
                builder: (context, games) => _table(games),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _table(List<GameSummary> games) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _col('Game', flex: 4),
                _col('Rounds Played', flex: 3),
                _col('Avg. Session', flex: 3),
                _col('Avg. Coins', flex: 3),
                _col('Completion', flex: 3),
                _col('Status', flex: 2),
              ],
            ),
          ),
          const Divider(height: 1),
          if (games.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text('No games available',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textMuted)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: games.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 24, endIndent: 24),
              itemBuilder: (ctx, i) {
                final game = games[i];
                return _GameRow(
                  game: game,
                  icon: _gameIcons[game.key] ?? '🎮',
                  onTap: () => context.go('/games/${game.key}'),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _col(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
    );
  }
}

class _GameRow extends StatefulWidget {
  final GameSummary game;
  final String icon;
  final VoidCallback onTap;
  const _GameRow({required this.game, required this.icon, required this.onTap});

  @override
  State<_GameRow> createState() => _GameRowState();
}

class _GameRowState extends State<_GameRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          color: _hovering ? AppColors.pageBg : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: widget.icon.startsWith('assets/')
                            ? Image.asset(widget.icon, width: 24, height: 24)
                            : Text(widget.icon,
                                style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(g.name,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),
              _cell(Format.number(g.roundsPlayed), flex: 3),
              _cell(Format.durationFromSeconds(g.avgSessionSeconds), flex: 3),
              _cell(Format.number(g.avgCoinsEarned), flex: 3),
              _cell(Format.rate(g.completionRate, decimals: 1), flex: 3),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge(
                      status: g.maintenance ? 'maintenance' : g.status),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style:
              GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
    );
  }
}
