import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_exception.dart';
import '../../core/di.dart';
import '../../core/format.dart';
import '../../shared/widgets/admin_scaffold.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/paginator.dart';
import '../../theme/app_theme.dart';
import 'create_tournament_dialog.dart';
import 'data/tournament_models.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['Upcoming', 'Live', 'Completed', 'Canceled', 'Leaderboard'];

  late Future<TournamentsPageData> _listFuture;
  late Future<LeaderboardData> _leaderboardFuture;
  int _leaderboardPage = 1;
  static const _leaderboardLimit = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadList();
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadList() {
    _listFuture = tournamentsRepository.list();
  }

  void _loadLeaderboard() {
    _leaderboardFuture = tournamentsRepository.leaderboard(
        page: _leaderboardPage, limit: _leaderboardLimit);
  }

  void _reload() {
    setState(_loadList);
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _create() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const TournamentFormDialog(),
    );
    if (ok == true) {
      _toast('Tournament created');
      _reload();
    }
  }

  Future<void> _edit(TournamentItem t) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => TournamentFormDialog(existing: t),
    );
    if (ok == true) {
      _toast('Tournament updated');
      _reload();
    }
  }

  Future<void> _cancel(TournamentItem t) async {
    final confirm = await _confirmDialog(
      context,
      title: 'Cancel tournament?',
      message:
          '"${t.name}" will be moved to Canceled. Registered players will be refunded per '
          'the backend rules.',
      confirmLabel: 'Cancel tournament',
      destructive: true,
    );
    if (confirm != true) return;
    try {
      await tournamentsRepository.cancel(t.id);
      _toast('Tournament canceled');
      _reload();
    } on ApiException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast('Could not cancel tournament');
    }
  }

  Future<void> _restore(TournamentItem t) async {
    try {
      await tournamentsRepository.restore(t.id);
      _toast('Tournament restored');
      _reload();
    } on ApiException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast('Could not restore tournament');
    }
  }

  void _viewPlayers(TournamentItem t) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) =>
          _PlayersDialog(tournamentId: t.id, tournamentName: t.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/tournaments',
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tournaments',
                style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _create,
                  icon: const Icon(Icons.add_rounded,
                      size: 18, color: Colors.white),
                  label: Text('Create Tournament',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _statusTab({'upcoming'}, _upcomingCard),
                  _statusTab({'live'}, _liveCard),
                  _statusTab({'over'}, _completedCard),
                  _statusTab({'cancelled', 'canceled'}, _canceledCard),
                  _leaderboardTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status tabs ────────────────────────────────────────────────────────────
  Widget _statusTab(
      Set<String> statuses, Widget Function(TournamentItem) card) {
    return AsyncView<TournamentsPageData>(
      key: ValueKey(_listFuture),
      future: _listFuture,
      onRetry: _reload,
      builder: (context, data) {
        final items = data.items
            .where((t) => statuses.contains(t.status.toLowerCase()))
            .toList();
        if (items.isEmpty) return const _EmptyState();
        return ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          itemCount: items.length,
          itemBuilder: (_, i) => card(items[i]),
        );
      },
    );
  }

  Widget _upcomingCard(TournamentItem t) {
    return _TournamentCard(
      t: t,
      columns: [
        _col('Prize Pool', Format.naira(t.prizePoolKobo)),
        _col('Participants', _participants(t)),
        _col('Entry', '${Format.coins(t.entryFeeCoins)} coins'),
        _entryCodeCol(t),
      ],
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (v) => v == 'edit' ? _edit(t) : _cancel(t),
        itemBuilder: (_) => [
          _menuItem('edit', 'Edit', AppColors.textPrimary),
          _menuItem('cancel', 'Cancel tournament', AppColors.statusRed),
        ],
      ),
    );
  }

  Widget _liveCard(TournamentItem t) {
    return _TournamentCard(
      t: t,
      columns: [
        _col('Prize Pool', Format.naira(t.prizePoolKobo)),
        _col('Participating', _participants(t)),
        _col('Time Remaining', Format.remaining(t.secondsRemaining),
            labelColor: AppColors.statusGreen,
            valueColor: AppColors.textPrimary),
      ],
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (v) => v == 'players' ? _viewPlayers(t) : _cancel(t),
        itemBuilder: (_) => [
          _menuItem('players', 'View players', AppColors.textPrimary),
          _menuItem('cancel', 'Cancel tournament', AppColors.statusRed),
        ],
      ),
    );
  }

  Widget _completedCard(TournamentItem t) {
    return _TournamentCard(
      t: t,
      columns: [
        _col('Prize Pool', Format.naira(t.prizePoolKobo)),
        _col('Total Players', Format.number(t.participants)),
        _col('Completion Rate', Format.rate(t.completionRate)),
      ],
      trailing: ElevatedButton(
        onPressed: () => _viewPlayers(t),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: Text('View List',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
      ),
    );
  }

  Widget _canceledCard(TournamentItem t) {
    return _TournamentCard(
      t: t,
      columns: [
        _col('Prize Pool', Format.naira(t.prizePoolKobo)),
        _col('Total Players', Format.number(t.participants)),
        _col('Entry', '${Format.coins(t.entryFeeCoins)} coins'),
      ],
      trailing: OutlinedButton(
        onPressed: () => _restore(t),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text('Restore',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary)),
      ),
    );
  }

  // ── Leaderboard tab ──────────────────────────────────────────────────────
  Widget _leaderboardTab() {
    return AsyncView<LeaderboardData>(
      key: ValueKey(_leaderboardFuture),
      future: _leaderboardFuture,
      onRetry: () => setState(_loadLeaderboard),
      builder: (context, data) {
        if (data.items.isEmpty) {
          return const _EmptyState(message: 'No leaderboard scores yet.');
        }
        final pageCount = (data.total / data.limit).ceil();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.tournamentName != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: Text(data.tournamentName!,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),
            ],
            const _LeaderboardHeaderRow(),
            Expanded(
              child: ListView.separated(
                itemCount: data.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => _LeaderboardRow(entry: data.items[i]),
              ),
            ),
            if (pageCount > 1)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Paginator(
                    currentPage: _leaderboardPage,
                    pageCount: pageCount,
                    onSelect: (p) => setState(() {
                      _leaderboardPage = p;
                      _loadLeaderboard();
                    }),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── small helpers ──────────────────────────────────────────────────────────
  static String _participants(TournamentItem t) => t.participantLimit > 0
      ? '${Format.number(t.participants)}/${Format.number(t.participantLimit)}'
      : Format.number(t.participants);

  PopupMenuItem<String> _menuItem(String value, String label, Color color) =>
      PopupMenuItem(
        value: value,
        child:
            Text(label, style: GoogleFonts.inter(fontSize: 13, color: color)),
      );

  Widget _entryCodeCol(TournamentItem t) {
    final code = t.entryCode;
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Entry Code',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          if (code == null || code.isEmpty)
            Text('Nil',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary))
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(code,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    _toast('Entry code copied');
                  },
                  child: const Icon(Icons.copy_outlined,
                      size: 15, color: AppColors.textMuted),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Shared card ───────────────────────────────────────────────────────────────
class _TournamentCard extends StatelessWidget {
  final TournamentItem t;
  final List<Widget> columns;
  final Widget trailing;
  const _TournamentCard(
      {required this.t, required this.columns, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.name,
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('Starts : ${Format.dateTime(t.startsAt)}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          ...columns,
          trailing,
        ],
      ),
    );
  }
}

Widget _col(String label, String value,
    {Color? labelColor, Color? valueColor}) {
  return Expanded(
    flex: 2,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight:
                    labelColor != null ? FontWeight.w600 : FontWeight.w400,
                color: labelColor ?? AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary)),
      ],
    ),
  );
}

// ── Leaderboard rows ───────────────────────────────────────────────────────────
class _LeaderboardHeaderRow extends StatelessWidget {
  const _LeaderboardHeaderRow();

  @override
  Widget build(BuildContext context) {
    Widget h(String t, int flex) => Expanded(
          flex: flex,
          child: Text(t,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
        );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          h('#', 1),
          h('Player', 5),
          h('Points', 2),
          h('Games', 2),
          h('Last Scored', 3)
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  const _LeaderboardRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('${entry.rank}',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.username,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                if (entry.email != null && entry.email!.isNotEmpty)
                  Text(entry.email!,
                      style: GoogleFonts.inter(
                          fontSize: 11.5, color: AppColors.textMuted)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(Format.number(entry.points),
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textPrimary)),
          ),
          Expanded(
            flex: 2,
            child: Text(Format.number(entry.gamesScored),
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textPrimary)),
          ),
          Expanded(
            flex: 3,
            child: Text(
                entry.lastScoredAt == null
                    ? '—'
                    : Format.relativeTime(entry.lastScoredAt),
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

// ── Players dialog ────────────────────────────────────────────────────────────
class _PlayersDialog extends StatefulWidget {
  final String tournamentId;
  final String tournamentName;
  const _PlayersDialog(
      {required this.tournamentId, required this.tournamentName});

  @override
  State<_PlayersDialog> createState() => _PlayersDialogState();
}

class _PlayersDialogState extends State<_PlayersDialog> {
  late Future<List<TournamentPlayer>> _future;

  @override
  void initState() {
    super.initState();
    _future = tournamentsRepository.players(widget.tournamentId);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Players',
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        Text(widget.tournamentName,
                            style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        size: 20, color: AppColors.textSecondary),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: AsyncView<List<TournamentPlayer>>(
                  future: _future,
                  onRetry: () => setState(() {
                    _future =
                        tournamentsRepository.players(widget.tournamentId);
                  }),
                  builder: (context, players) {
                    if (players.isEmpty) {
                      return const _EmptyState(
                          message: 'No players registered yet.');
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: players.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) => _PlayerRow(player: players[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final TournamentPlayer player;
  const _PlayerRow({required this.player});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.username,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                if (player.email != null && player.email!.isNotEmpty)
                  Text(player.email!,
                      style: GoogleFonts.inter(
                          fontSize: 11.5, color: AppColors.textMuted)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('${Format.number(player.points)} pts',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textPrimary)),
          ),
          Expanded(
            flex: 2,
            child: Text('${Format.number(player.gamesScored)} games',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: player.entryFeePaid
                      ? AppColors.statusGreenBg
                      : AppColors.statusOrangeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(player.entryFeePaid ? 'Paid' : 'Unpaid',
                    style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: player.entryFeePaid
                            ? AppColors.statusGreen
                            : AppColors.statusOrange)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Misc ─────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({this.message = 'No tournaments here yet.'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message,
          style:
              GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary)),
    );
  }
}

Future<bool?> _confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title,
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
      content:
          Text(message, style: GoogleFonts.inter(fontSize: 13.5, height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Never mind',
              style: GoogleFonts.inter(color: AppColors.textSecondary)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor:
                destructive ? AppColors.statusRed : AppColors.primary,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
