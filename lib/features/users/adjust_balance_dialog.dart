import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/di.dart';
import '../../shared/widgets/form_fields.dart';
import '../../theme/app_theme.dart';
import 'data/user_models.dart';

class AdjustBalanceDialog extends StatefulWidget {
  final UserListItem user;

  const AdjustBalanceDialog({super.key, required this.user});

  static Future<bool?> show(BuildContext context, UserListItem user) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AdjustBalanceDialog(user: user),
    );
  }

  @override
  State<AdjustBalanceDialog> createState() => _AdjustBalanceDialogState();
}

class _AdjustBalanceDialogState extends State<AdjustBalanceDialog> {
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  String _type = 'cash'; // cash or coin
  String _action = 'add'; // add or subtract
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid positive amount');
      return;
    }

    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'Enter a reason');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final value = _action == 'add' ? amount : -amount;

      await apiClient
          .post('/admin/wallet/adjust', data: {
        'user_id': widget.user.id,
        'currency': _type,
        'amount': _type == 'cash'
            ? (value * 100).toInt()
            : value.toInt(), // assuming naira for cash input
        'reason': reason,
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DialogHeader(
                title: 'Adjust Balance',
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              Text('Adjusting balance for ${widget.user.displayName}',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _RadioOption(
                      title: 'Cash (₦)',
                      selected: _type == 'cash',
                      onTap: () => setState(() => _type = 'cash'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RadioOption(
                      title: 'Coins',
                      selected: _type == 'coin',
                      onTap: () => setState(() => _type = 'coin'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _RadioOption(
                      title: 'Add',
                      selected: _action == 'add',
                      onTap: () => setState(() => _action = 'add'),
                      activeColor: AppColors.statusGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RadioOption(
                      title: 'Subtract',
                      selected: _action == 'subtract',
                      onTap: () => setState(() => _action = 'subtract'),
                      activeColor: AppColors.statusRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _label('Amount'),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: fieldDecoration().copyWith(
                  hintText: _type == 'cash' ? '0.00' : '0',
                ),
              ),
              const SizedBox(height: 16),
              _label('Reason'),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonCtrl,
                decoration: fieldDecoration().copyWith(
                  hintText: 'e.g. Refund for failed game',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                _ErrorBanner(_error!),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white))
                        : const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }
}

class _RadioOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;

  const _RadioOption({
    required this.title,
    required this.selected,
    required this.onTap,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(color: selected ? activeColor : AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? activeColor : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  const _DialogHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const Spacer(),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded,
              size: 20, color: AppColors.textSecondary),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.statusRedBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: AppColors.statusRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: GoogleFonts.inter(
                    fontSize: 12.5, color: AppColors.statusRed)),
          ),
        ],
      ),
    );
  }
}
