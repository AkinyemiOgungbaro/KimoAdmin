import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_exception.dart';
import '../../core/di.dart';
import '../../core/format.dart';
import '../../shared/widgets/admin_scaffold.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/paginator.dart';
import '../../shared/widgets/status_badge.dart';
import '../../theme/app_theme.dart';
import 'add_reward_dialog.dart';
import 'data/reward_models.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // (label, category token). `null` category = all rewards.
  static const _tabs = <(String, String?)>[
    ('All Rewards', null),
    ('Gadgets', 'gadget'),
    ('Airtime & Data', 'airtime_data'),
    ('Food', 'food'),
    ('Clothing', 'clothing'),
  ];
  static const _limit = 12;

  int _tabIndex = 0;
  int _page = 1;
  int? _total;
  late Future<RewardsPageData> _future;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _load();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == _tabIndex) return;
    _tabIndex = _tabController.index;
    _page = 1;
    setState(_load);
  }

  String? get _category => _tabs[_tabIndex].$2;

  void _load() {
    _future =
        rewardsRepository.list(category: _category, page: _page, limit: _limit);
    _future.then(
      (d) {
        if (mounted) setState(() => _total = d.total);
      },
      onError: (_) {},
    );
  }

  void _reload() => setState(_load);

  void _goToPage(int p) => setState(() {
        _page = p;
        _load();
      });

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _add() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const RewardFormDialog(),
    );
    if (ok == true) {
      _toast('Reward created');
      _reload();
    }
  }

  Future<void> _edit(RewardItem r) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => RewardFormDialog(existing: r),
    );
    if (ok == true) {
      _toast('Reward updated');
      _reload();
    }
  }

  Future<void> _outOfStock(RewardItem r) async {
    try {
      await rewardsRepository.outOfStock(r.id);
      _toast('“${r.name}” marked out of stock');
      _reload();
    } on ApiException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast('Could not update reward');
    }
  }

  Future<void> _toggleActive(RewardItem r) async {
    final activate = !r.isActive;
    try {
      await rewardsRepository.setActive(r.id, activate);
      _toast(activate ? '“${r.name}” activated' : '“${r.name}” deactivated');
      _reload();
    } on ApiException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast('Could not update reward');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/rewards',
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Rewards',
                    style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(width: 12),
                if (_total != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${Format.number(_total)} items',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textSecondary)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                    tabs: _tabs.map((t) => Tab(text: t.$1)).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _add,
                  icon: const Icon(Icons.add_rounded,
                      size: 18, color: Colors.white),
                  label: Text('Add Reward',
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
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: _HeaderRow(),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: AsyncView<RewardsPageData>(
                        future: _future,
                        onRetry: _reload,
                        builder: (context, data) {
                          if (data.items.isEmpty) {
                            return Center(
                              child: Text('No rewards in this category yet.',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.textSecondary)),
                            );
                          }
                          return Column(
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  itemCount: data.items.length,
                                  separatorBuilder: (_, __) => const Divider(
                                      height: 1, indent: 20, endIndent: 20),
                                  itemBuilder: (_, i) => _RewardRow(
                                    reward: data.items[i],
                                    onEdit: () => _edit(data.items[i]),
                                    onOutOfStock: () =>
                                        _outOfStock(data.items[i]),
                                    onToggleActive: () =>
                                        _toggleActive(data.items[i]),
                                  ),
                                ),
                              ),
                              if (data.pageCount > 1)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Paginator(
                                      currentPage: _page,
                                      pageCount: data.pageCount,
                                      onSelect: _goToPage,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Table header ──────────────────────────────────────────────────────────────
class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    Widget h(String t, int flex) => Expanded(
          flex: flex,
          child: Text(t,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        );
    return Row(
      children: [
        h('Reward', 4),
        h('Coin Cost', 2),
        h('Cash Cost', 2),
        h('Price', 2),
        h('Discount', 2),
        h('Stock', 2),
        h('Redeemed', 2),
        h('Status', 2),
        h('', 1),
      ],
    );
  }
}

// ── Row ─────────────────────────────────────────────────────────────────────
class _RewardRow extends StatefulWidget {
  final RewardItem reward;
  final VoidCallback onEdit;
  final VoidCallback onOutOfStock;
  final VoidCallback onToggleActive;

  const _RewardRow({
    required this.reward,
    required this.onEdit,
    required this.onOutOfStock,
    required this.onToggleActive,
  });

  @override
  State<_RewardRow> createState() => _RewardRowState();
}

class _RewardRowState extends State<_RewardRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.reward;
    final subtitle = [
      if (r.subcategory != null && r.subcategory!.isNotEmpty) r.subcategory,
      if (r.network != null && r.network!.isNotEmpty) r.network,
    ].whereType<String>().join(' • ');

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        color: _hovering ? AppColors.pageBg : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  _Thumb(imageUrl: r.imageUrl),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary)),
                        if (subtitle.isNotEmpty)
                          Text(subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  fontSize: 11.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _cell(Format.number(r.coinCost)),
            _cell(Format.naira(r.cashCostKobo)),
            _cell(Format.naira(r.priceKobo)),
            _cell(r.discountPercent > 0 ? Format.rate(r.discountPercent) : '—'),
            _cell(Format.number(r.stock)),
            _cell(Format.number(r.redeemed)),
            Expanded(flex: 2, child: StatusBadge(status: r.status)),
            Expanded(
              flex: 1,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz,
                    color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onSelected: (v) {
                  if (v == 'edit') {
                    widget.onEdit();
                  } else if (v == 'out_of_stock') {
                    widget.onOutOfStock();
                  } else if (v == 'toggle') {
                    widget.onToggleActive();
                  }
                },
                itemBuilder: (_) => [
                  _item('edit', 'Edit', AppColors.textPrimary),
                  if (r.isActive)
                    _item('out_of_stock', 'Mark out of stock',
                        AppColors.textPrimary),
                  _item(
                    'toggle',
                    r.isActive ? 'Deactivate' : 'Activate',
                    r.isActive ? AppColors.statusRed : AppColors.statusGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String text) => Expanded(
        flex: 2,
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary)),
      );

  PopupMenuItem<String> _item(String value, String label, Color color) =>
      PopupMenuItem(
        value: value,
        child:
            Text(label, style: GoogleFonts.inter(fontSize: 13, color: color)),
      );
}

class _Thumb extends StatelessWidget {
  final String? imageUrl;
  const _Thumb({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? const Icon(Icons.card_giftcard_rounded,
              size: 18, color: AppColors.textMuted)
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.card_giftcard_rounded,
                  size: 18,
                  color: AppColors.textMuted),
            ),
    );
  }
}
