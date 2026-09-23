import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/form_fields.dart';
import '../../theme/app_theme.dart';

const _networks = {
  'mtn': 'MTN',
  'airtel': 'Airtel',
  'glo': 'Glo',
  '9mobile': '9mobile',
};

/// Asks the admin to confirm how a prize was given. Returns null when cancelled.
Future<({String? network, String note})?> showFulfilPrizeDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool askNetwork = false,
}) {
  return showDialog(
    context: context,
    builder: (_) => _FulfilPrizeDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      askNetwork: askNetwork,
    ),
  );
}

class _FulfilPrizeDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool askNetwork;

  const _FulfilPrizeDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.askNetwork,
  });

  @override
  State<_FulfilPrizeDialog> createState() => _FulfilPrizeDialogState();
}

class _FulfilPrizeDialogState extends State<_FulfilPrizeDialog> {
  final _note = TextEditingController();
  String? _network;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _ready => !widget.askNetwork || _network != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.title,
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary)),
            if (widget.askNetwork) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _network,
                decoration: fieldDecoration(hint: 'Network'),
                items: [
                  for (final entry in _networks.entries)
                    DropdownMenuItem(
                        value: entry.key, child: Text(entry.value)),
                ],
                onChanged: (value) => setState(() => _network = value),
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _note,
              maxLength: 300,
              decoration: fieldDecoration(hint: 'Note (optional)'),
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _ready
              ? () => Navigator.pop(
                  context, (network: _network, note: _note.text.trim()))
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
