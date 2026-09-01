import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/di.dart';
import '../../theme/app_theme.dart';

class AppSidebar extends StatelessWidget {
  final String currentRoute;
  const AppSidebar({super.key, required this.currentRoute});

  static const _navItems = [
    _NavItem('Dashboard', '/dashboard'),
    _NavItem('Users', '/users'),
    _NavItem('Games', '/games'),
    _NavItem('Tournaments', '/tournaments'),
    _NavItem('Rewards', '/rewards'),
    _NavItem('Wallet', '/wallet'),
    _NavItem('Payments', '/payments'),
    _NavItem('Content', '/content'),
    _NavItem('Notifications', '/notifications'),
    _NavItem('Reports', '/reports'),
    _NavItem('Settings', '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      color: AppColors.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            child: _KimoLogo(),
          ),
          // Nav items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _navItems.map((item) {
                final isActive = currentRoute == item.route ||
                    (currentRoute.startsWith(item.route) &&
                        item.route != '/dashboard');
                return _NavTile(item: item, isActive: isActive);
              }).toList(),
            ),
          ),
          const _SidebarFooter(),
        ],
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'You will need to sign in again to access the dashboard.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.statusRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await authController.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final admin = authController.admin;
        return Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 18),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  admin?.initials ?? 'A',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      admin?.name ?? 'Admin',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (admin?.email.isNotEmpty ?? false)
                      Text(
                        admin!.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: AppColors.sidebarText,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Sign out',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.logout_rounded,
                    size: 18, color: AppColors.sidebarText),
                onPressed: () => _confirmLogout(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KimoLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KIMO',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.logoBox,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'GAMES',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  const _NavTile({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(item.route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.sidebarActiveItem : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          item.label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color:
                isActive ? AppColors.sidebarActiveText : AppColors.sidebarText,
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String route;
  const _NavItem(this.label, this.route);
}
