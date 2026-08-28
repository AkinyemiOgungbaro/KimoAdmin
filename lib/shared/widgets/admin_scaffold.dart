import 'package:flutter/material.dart';
import 'sidebar.dart';

/// The main shell widget: sidebar (fixed) + scrollable content area
class AdminScaffold extends StatelessWidget {
  final String currentRoute;
  final Widget child;

  const AdminScaffold({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(currentRoute: currentRoute),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
