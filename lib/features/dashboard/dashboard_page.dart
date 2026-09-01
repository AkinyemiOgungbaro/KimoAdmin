import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/di.dart';
import '../../core/format.dart';
import '../../core/range.dart';
import '../../shared/widgets/admin_scaffold.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/stat_card.dart';
import '../../theme/app_theme.dart';
import '../../charts/line_chart_widget.dart';
import '../../charts/bar_chart_widget.dart';
import '../../charts/donut_chart_widget.dart';
import 'data/dashboard_models.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  RangePeriod _period = RangePeriod.today;
  late Future<DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = dashboardRepository.get(_period.token);
  }

  void _reload() => setState(_load);

  void _onPeriod(RangePeriod p) {
    if (p == _period) return;
    setState(() {
      _period = p;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Dashboard',
                    style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const Spacer(),
                _PeriodDropdown(value: _period, onChanged: _onPeriod),
              ],
            ),
            const SizedBox(height: 24),
            AsyncView<DashboardData>(
              future: _future,
              onRetry: _reload,
              minHeight: 400,
              builder: (context, data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kpiGrid(data),
                  const SizedBox(height: 20),
                  _chartsRow(data),
                  const SizedBox(height: 20),
                  _bottomRow(data),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiGrid(DashboardData d) {
    final signupChange = d.newSignups.changePercent;
    final cards = <Widget>[
      StatCard(label: 'Total Users', value: Format.number(d.totalUsers.value)),
      StatCard(
          label: 'Active Players', value: Format.number(d.activePlayers.value)),
      StatCard(
        label: 'New Signups',
        value: Format.number(d.newSignups.value),
        change: signupChange == null
            ? null
            : '${signupChange.abs().toStringAsFixed(1)}%',
        positive: (signupChange ?? 0) >= 0,
      ),
      StatCard(
          label: 'Rounds Played', value: Format.number(d.roundsPlayed.value)),
      StatCard(
          label: 'Coins Awarded', value: Format.compact(d.coinsAwarded.value)),
      StatCard(label: 'Revenue', value: Format.naira(d.revenueKobo.value)),
      StatCard(label: 'Ad Views', value: Format.number(d.adViews.value)),
      StatCard(
          label: 'Coins Redeemed',
          value: Format.compact(d.coinsRedeemed.value)),
      StatCard(
          label: 'Tournament Entries',
          value: Format.number(d.tournamentEntries.value)),
      StatCard(
          label: 'Home Screen Installs',
          value: Format.number(d.homeScreenInstalls.value)),
    ];

    return LayoutBuilder(builder: (ctx, constraints) {
      final cols = constraints.maxWidth > 900 ? 5 : 3;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.1,
        ),
        itemCount: cards.length,
        itemBuilder: (ctx, i) => cards[i],
      );
    });
  }

  Widget _chartsRow(DashboardData d) {
    return SizedBox(
      height: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: _ChartCard(
              title: 'Daily Active Players',
              child: DauLineChart(
                data: d.dailyActivePlayers.map((p) => p.value).toList(),
                labels: d.dailyActivePlayers.map((p) => p.day).toList(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: _ChartCard(
              title: 'Rounds Played',
              child: GamesBarChart(
                data: d.roundsPlayedSeries.map((p) => p.value).toList(),
                labels: d.roundsPlayedSeries.map((p) => p.day).toList(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: _ChartCard(
              title: 'Coins Earned vs Redeemed',
              child: CoinsDonutChart(
                earned: d.coinsEarnedAllTime.toDouble(),
                redeemed: d.coinsRedeemedAllTime.toDouble(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomRow(DashboardData d) {
    return SizedBox(
      height: 360,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: _LiveFeedCard(activities: d.recentActivity)),
          const SizedBox(width: 12),
          Expanded(flex: 4, child: _TopPlayersCard(players: d.topPlayers)),
          const SizedBox(width: 12),
          Expanded(
              flex: 3,
              child:
                  _UpcomingTournamentsCard(tournaments: d.upcomingTournaments)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
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
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final String title;
  final Widget child;
  const _CardShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
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
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
    );
  }
}

class _LiveFeedCard extends StatelessWidget {
  final List<ActivityEntry> activities;
  const _LiveFeedCard({required this.activities});

  String _prettyReason(String reason) {
    if (reason.isEmpty) return 'Activity';
    return reason
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  String _amountLabel(ActivityEntry a) {
    final c = a.currency.toLowerCase();
    if (c == 'coins' || c == 'coin') {
      return a.amount > 0
          ? '+${Format.compact(a.amount)}'
          : Format.compact(a.amount);
    }
    if (c == 'ngn' || c == 'naira' || c == 'kobo')
      return Format.naira(a.amount);
    return '${a.amount > 0 ? '+' : ''}${Format.compact(a.amount)} ${a.currency}'
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: 'Live Activity Feed',
      child: activities.isEmpty
          ? const _EmptyHint('No recent activity')
          : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final a = activities[i];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.username,
                              style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          Text(_prettyReason(a.reason),
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_amountLabel(a),
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.statusGreen)),
                        Text(Format.relativeTime(a.createdAt),
                            style: GoogleFonts.inter(
                                fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _TopPlayersCard extends StatelessWidget {
  final List<TopPlayer> players;
  const _TopPlayersCard({required this.players});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: 'Top Players (This Week)',
      child: players.isEmpty
          ? const _EmptyHint('No players yet')
          : Column(
              children: [
                Row(
                  children: [
                    _h('#', flex: 1),
                    _h('Player', flex: 4),
                    _h('Rounds', flex: 3),
                    _h('Coins', flex: 3),
                  ],
                ),
                const Divider(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: players.length,
                    itemBuilder: (context, i) {
                      final p = players[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            _c('${i + 1}', flex: 1),
                            _c(p.username, flex: 4, weight: FontWeight.w600),
                            _c(Format.number(p.rounds), flex: 3),
                            _c(Format.compact(p.coins), flex: 3),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _h(String t, {required int flex}) => Expanded(
        flex: flex,
        child: Text(t,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
      );

  Widget _c(String t,
          {required int flex, FontWeight weight = FontWeight.w400}) =>
      Expanded(
        flex: flex,
        child: Text(t,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: weight,
                color: AppColors.textPrimary)),
      );
}

class _UpcomingTournamentsCard extends StatelessWidget {
  final List<UpcomingTournament> tournaments;
  const _UpcomingTournamentsCard({required this.tournaments});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: 'Upcoming Tournaments',
      child: tournaments.isEmpty
          ? const _EmptyHint('No upcoming tournaments')
          : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: tournaments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, i) {
                final t = tournaments[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                            child: Text('🏆', style: TextStyle(fontSize: 18))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            Text(Format.dateShort(t.startsAt),
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(Format.nairaCompact(t.prizePoolKobo),
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          Text('${Format.number(t.entrants)} entrants',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  final RangePeriod value;
  final ValueChanged<RangePeriod> onChanged;

  const _PeriodDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RangePeriod>(
          value: value,
          items: kRangePeriods
              .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.label, style: GoogleFonts.inter(fontSize: 13))))
              .toList(),
          onChanged: (p) => p == null ? null : onChanged(p),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
