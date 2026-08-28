import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/di.dart';
import '../../shared/widgets/admin_scaffold.dart';
import '../../shared/widgets/async_view.dart';
import '../../theme/app_theme.dart';
import 'data/banner_models.dart';
import 'upload_ad_dialog.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['Active Ads', 'Scheduled', 'Expired', 'All Ads'];

  late Future<BannersPageData> _listFuture;
  late Future<PlacementsData> _placementsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadList();
    _placementsFuture = bannersRepository.placements();
  }

  void _loadList() {
    _listFuture = bannersRepository.list();
  }

  void _reload() {
    setState(_loadList);
  }

  Future<void> _uploadAd({BannerItem? existing}) async {
    final placementsData = await _placementsFuture;
    if (!mounted) return;
    final res = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => UploadAdDialog(
        existing: existing,
        placements: placementsData.items,
      ),
    );
    if (res == true) {
      _reload();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/content',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advert/Banner Management',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    indicatorColor: const Color(0xFF6B4EFF),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  ),
                ),
                InkWell(
                  onTap: () => _uploadAd(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4EFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Upload New Ad',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 32),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _statusTab('active'),
                  _statusTab('scheduled'),
                  _statusTab('expired'),
                  _statusTab('all'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTab(String filter) {
    return AsyncView<BannersPageData>(
      future: _listFuture,
      onRetry: _reload,
      builder: (context, data) {
        final now = DateTime.now().toUtc();
        final items = data.items.where((b) {
          if (filter == 'all') return true;
          
          if (filter == 'expired') {
            return b.endsAt != null && b.endsAt!.isBefore(now);
          }
          if (filter == 'scheduled') {
            return b.startsAt != null && b.startsAt!.isAfter(now);
          }
          if (filter == 'active') {
            final started = b.startsAt == null || b.startsAt!.isBefore(now);
            final ended = b.endsAt != null && b.endsAt!.isBefore(now);
            return b.status == 'active' && started && !ended;
          }
          return true;
        }).toList();

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F5FF),
          ),
          child: Column(
            children: [
              _buildTableHeader(),
              const Divider(height: 1, color: Color(0xFFEBEBFF)),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEBEBFF)),
                  itemBuilder: (context, index) {
                    final b = items[index];
                    return InkWell(
                      onTap: () => _uploadAd(existing: b),
                      child: _buildTableRow(
                        b.imageUrl,
                        b.name,
                        b.placement,
                        '${b.width} x ${b.height}',
                        b.format.toUpperCase(),
                        b.status,
                        b.impressions.toString(),
                        b.clicks.toString(),
                        '${b.ctr}%',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: _th('Banner')),
          Expanded(flex: 3, child: _th('Placement')),
          Expanded(flex: 2, child: _th('Size')),
          Expanded(flex: 2, child: _th('Type')),
          Expanded(flex: 2, child: _th('Status')),
          Expanded(flex: 2, child: _th('Impressions')),
          Expanded(flex: 2, child: _th('Clicks')),
          Expanded(flex: 2, child: _th('CTR')),
          Expanded(flex: 2, child: _th('Actions')),
        ],
      ),
    );
  }

  Widget _th(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTableRow(String imageUrl, String name, String placement, String size, String type, String status, String impressions, String clicks, String ctr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E2E2),
                image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(placement, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(size, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Text(type, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusGreenBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.statusGreen, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(impressions, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Text(clicks, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Text(ctr, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _actionIcon(Icons.edit_outlined),
                const SizedBox(width: 8),
                _actionIcon(Icons.remove_red_eye_outlined),
                const SizedBox(width: 8),
                _actionIcon(Icons.more_vert),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBFF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16, color: const Color(0xFF6B4EFF)),
    );
  }
}
