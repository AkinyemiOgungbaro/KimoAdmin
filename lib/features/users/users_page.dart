import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/di.dart';
import '../../core/format.dart';
import '../../core/web_download.dart';
import '../../shared/widgets/admin_scaffold.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/paginator.dart';
import '../../shared/widgets/status_badge.dart';
import '../../theme/app_theme.dart';
import 'add_user_dialog.dart';
import 'data/user_models.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _searchCtrl = TextEditingController();
  static const _limit = 10;

  String _search = '';
  int _page = 1;
  Timer? _debounce;
  bool _exporting = false;
  int? _totalUsers;

  late Future<UsersPageData> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _load() {
    _future = usersRepository.list(search: _search, page: _page, limit: _limit);
    _future.then((d) {
      if (mounted) setState(() => _totalUsers = d.totalUsers);
    }).catchError((_) {});
  }

  void _reload() => setState(_load);

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() {
        _search = value.trim();
        _page = 1;
        _load();
      });
    });
  }

  void _goToPage(int page) {
    setState(() {
      _page = page;
      _load();
    });
  }

  Future<void> _addUser() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const AddUserDialog(),
    );
    if (created == true) {
      _toast('User created');
      setState(() {
        _page = 1;
        _load();
      });
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _exporting = true);
    try {
      final csv = await usersRepository.exportCsv();
      downloadText(csv, 'kimo-users.csv');
      _toast('Export started');
    } catch (e) {
      _toast('Export failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _setStatus(UserListItem user, String status) async {
    try {
      await usersRepository.setStatus(user.id, status);
      _toast('${user.displayName} is now ${status == 'active' ? 'active' : 'unverified'}');
      _reload();
    } catch (e) {
      _toast('Could not update status: $e', error: true);
    }
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
      currentRoute: '/users',
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Users',
                    style: GoogleFonts.inter(
                        fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const Spacer(),
                if (_totalUsers != null)
                  Text('${Format.number(_totalUsers)} total users',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search by name, username or email',
                        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                        suffixIcon: _search.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _onSearchChanged('');
                                },
                              ),
                      ),
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _exporting ? null : _exportCsv,
                  icon: _exporting
                      ? const SizedBox(
                          width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Export CSV'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.divider),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addUser,
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: Text('Add User',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AsyncView<UsersPageData>(
                future: _future,
                onRetry: _reload,
                minHeight: 300,
                builder: (context, data) => _table(data),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _table(UsersPageData data) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      _col('User', flex: 3),
                      _col('Email', flex: 3),
                      _col('Phone', flex: 2),
                      _col('Coins', flex: 2),
                      _col('Cash', flex: 2),
                      _col('Games', flex: 1),
                      _col('Status', flex: 2),
                      _col('', flex: 1),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: data.items.isEmpty
                      ? Center(
                          child: Text('No users found',
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
                        )
                      : ListView.separated(
                          itemCount: data.items.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, indent: 20, endIndent: 20),
                          itemBuilder: (ctx, i) => _UserRow(
                            user: data.items[i],
                            onView: () => _showUser(data.items[i]),
                            onSetStatus: (status) => _setStatus(data.items[i], status),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Page ${data.page} of ${data.pageCount}',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
            const Spacer(),
            Paginator(
              currentPage: data.page,
              pageCount: data.pageCount,
              onSelect: _goToPage,
            ),
          ],
        ),
      ],
    );
  }

  void _showUser(UserListItem u) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(u.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kv('Username', '@${u.username}'),
            _kv('Email', u.email),
            _kv('Phone', u.phoneNumber ?? '—'),
            _kv('Coins', Format.number(u.coins)),
            _kv('Cash', Format.naira(u.cashKobo)),
            _kv('Games played', Format.number(u.gamesPlayed)),
            _kv('Status', u.status),
            _kv('Joined', Format.dateShort(u.createdAt)),
            _kv('Last login', Format.dateTime(u.lastLoginAt)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(k,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            ),
            Expanded(
              child: Text(v,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ),
          ],
        ),
      );

  Widget _col(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    );
  }
}

class _UserRow extends StatefulWidget {
  final UserListItem user;
  final VoidCallback onView;
  final ValueChanged<String> onSetStatus;
  const _UserRow({required this.user, required this.onView, required this.onSetStatus});

  @override
  State<_UserRow> createState() => _UserRowState();
}

class _UserRowState extends State<_UserRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final isActive = u.status.toLowerCase() == 'active';
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        color: _hovering ? AppColors.pageBg : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF00BCD4),
                    backgroundImage:
                        (u.avatarUrl != null && u.avatarUrl!.isNotEmpty) ? NetworkImage(u.avatarUrl!) : null,
                    child: (u.avatarUrl == null || u.avatarUrl!.isEmpty)
                        ? Text(
                            u.displayName.isNotEmpty ? u.displayName[0].toUpperCase() : '?',
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        Text('@${u.username}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex: 3, child: _cell(u.email)),
            Expanded(flex: 2, child: _cell(u.phoneNumber ?? '—')),
            Expanded(flex: 2, child: _cell(Format.number(u.coins))),
            Expanded(flex: 2, child: _cell(Format.naira(u.cashKobo))),
            Expanded(flex: 1, child: _cell(Format.number(u.gamesPlayed))),
            Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: StatusBadge(status: u.status))),
            Expanded(
              flex: 1,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      widget.onView();
                      break;
                    case 'activate':
                      widget.onSetStatus('active');
                      break;
                    case 'unverify':
                      widget.onSetStatus('unverified');
                      break;
                  }
                },
                itemBuilder: (_) => [
                  _menuItem('view', 'View details'),
                  if (isActive)
                    _menuItem('unverify', 'Set unverified')
                  else
                    _menuItem('activate', 'Mark active'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String text) {
    return Text(text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary));
  }

  PopupMenuItem<String> _menuItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Text(label,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary)),
    );
  }
}
