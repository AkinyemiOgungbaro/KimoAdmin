import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_exception.dart';
import '../../core/di.dart';
import '../../core/format.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/form_fields.dart';
import '../../theme/app_theme.dart';
import 'data/prize_models.dart';
import 'data/tournament_models.dart';
import 'fulfil_prize_dialog.dart';

String prizeLabel(String type, num amount, String? itemName) {
  switch (type) {
    case 'item':
      return itemName ?? 'Item';
    case 'airtime':
      return '${Format.naira(amount)} airtime';
    case 'coins':
      return '${Format.coins(amount)} coins';
    default:
      return '${Format.naira(amount)} cash';
  }
}

class WinnersDialog extends StatefulWidget {
  final TournamentItem tournament;
  const WinnersDialog({super.key, required this.tournament});

  @override
  State<WinnersDialog> createState() => _WinnersDialogState();
}

class _WinnersDialogState extends State<WinnersDialog> {
  late Future<TournamentPrizes> _future;
  final _search = TextEditingController();
  bool _toBeGivenOnly = false;
  int? _working;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() => _future = tournamentsRepository.prizes(widget.tournament.id);

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.statusRed : null,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _fulfil(TournamentPrize prize, String method) async {
    final winner = prize.winnerUsername ?? 'the winner';
    final what = prizeLabel(prize.prizeType, prize.amount, prize.itemName);
    final checkCode = prize.claimCode == null
        ? ''
        : ' Check their claim code ${prize.claimCode} first.';

    ({String? network, String note})? answer = (network: null, note: '');
    if (prize.status != 'sending') {
      answer = await showFulfilPrizeDialog(
        context,
        title: switch (method) {
          'wallet_credit' => 'Credit wallet',
          'airtime' => 'Send airtime',
          _ => 'Mark as given',
        },
        message: switch (method) {
          'wallet_credit' => "Credit $what to $winner's wallet?",
          'airtime' => 'Send $what to $winner on ${prize.winnerPhone ?? '-'}?',
          'item_handed_over' =>
            'Confirm $what was handed to $winner.$checkCode',
          _ => 'Confirm $what was paid to $winner at the event.$checkCode',
        },
        confirmLabel: switch (method) {
          'wallet_credit' => 'Credit wallet',
          'airtime' => 'Send airtime',
          _ => 'Mark given',
        },
        askNetwork: method == 'airtime',
      );
    }
    if (answer == null) return;

    setState(() => _working = prize.rank);
    try {
      final status = await tournamentsRepository.fulfilPrize(
        widget.tournament.id,
        prize.rank,
        method: method,
        network: answer.network,
        note: answer.note,
      );
      _toast(status == 'sending'
          ? 'The airtime is still processing. Check again in a minute'
          : 'Prize marked as given');
    } on ApiException catch (e) {
      _toast(e.message, error: true);
    } catch (_) {
      _toast('Failed', error: true);
    } finally {
      if (mounted) {
        setState(() {
          _working = null;
          _load();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 600),
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
                        Text('Winners',
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        Text(widget.tournament.name,
                            style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  FilterChip(
                    label: const Text('To be given'),
                    selected: _toBeGivenOnly,
                    onSelected: (on) => setState(() => _toBeGivenOnly = on),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        size: 20, color: AppColors.textSecondary),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration:
                    fieldDecoration(hint: 'Search by claim code or username')
                        .copyWith(
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: AppColors.textMuted),
                ),
                style: GoogleFonts.inter(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: AsyncView<TournamentPrizes>(
                  future: _future,
                  onRetry: () => setState(_load),
                  builder: (context, data) => _body(data),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(TournamentPrizes data) {
    if (data.items.isEmpty) {
      return _note('This tournament has no prizes.');
    }
    if (data.distributedAt == null) {
      return _note('Winners are decided about a minute after the tournament '
          'ends. Check back shortly.');
    }

    final query = _search.text.trim().toLowerCase();
    final rows = data.items
        .where((p) => !_toBeGivenOnly || p.toBeGiven)
        .where((p) =>
            query.isEmpty ||
            (p.claimCode ?? '').toLowerCase().contains(query) ||
            (p.winnerUsername ?? '').toLowerCase().contains(query))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
            '${data.unpaid} to be given'
            '${data.unawarded > 0 ? ' · ${data.unawarded} not awarded, too few players qualified' : ''}',
            style: GoogleFonts.inter(
                fontSize: 12.5, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Flexible(
          child: rows.isEmpty
              ? _note(query.isEmpty
                  ? 'Every prize has been given.'
                  : 'No winner matches that search.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => _WinnerRow(
                    prize: rows[i],
                    busy: _working == rows[i].rank,
                    onFulfil: (method) => _fulfil(rows[i], method),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _note(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary)),
        ),
      );
}

const _methodLabels = {
  'cash_at_event': 'cash at event',
  'wallet_credit': 'wallet credit',
  'airtime': 'airtime',
  'item_handed_over': 'handed over',
};

class _WinnerRow extends StatelessWidget {
  final TournamentPrize prize;
  final bool busy;
  final ValueChanged<String> onFulfil;
  const _WinnerRow(
      {required this.prize, required this.busy, required this.onFulfil});

  List<({String method, String label})> get _actions {
    if (!prize.toBeGiven) return const [];
    switch (prize.prizeType) {
      case 'cash':
        return const [
          (method: 'cash_at_event', label: 'Mark given'),
          (method: 'wallet_credit', label: 'Credit wallet'),
        ];
      case 'airtime':
        return [
          (
            method: 'airtime',
            label: prize.status == 'sending' ? 'Check airtime' : 'Send airtime'
          ),
        ];
      case 'item':
        return const [(method: 'item_handed_over', label: 'Mark given')];
      default:
        return const [];
    }
  }

  static String _flag(String flag) {
    final words = flag.replaceAll('_', ' ');
    return words.isEmpty ? words : words[0].toUpperCase() + words.substring(1);
  }

  ({String label, Color color, Color background}) get _status {
    if (!prize.awarded) {
      return (
        label: 'Not awarded',
        color: AppColors.statusGrey,
        background: AppColors.statusGreyBg
      );
    }
    if (prize.status == 'awaiting_fulfilment') {
      return (
        label: 'To be given',
        color: AppColors.statusOrange,
        background: AppColors.statusOrangeBg
      );
    }
    if (prize.status == 'sending') {
      return (
        label: 'Sending',
        color: AppColors.statusBlue,
        background: AppColors.statusBlueBg
      );
    }
    return (
      label: 'Given',
      color: AppColors.statusGreen,
      background: AppColors.statusGreenBg
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final contact = [prize.winnerPhone, prize.winnerEmail]
        .whereType<String>()
        .where((v) => v.isNotEmpty)
        .join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Text('#${prize.rank}',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    prize.awarded
                        ? '${prize.winnerUsername ?? '-'}'
                            '${prize.winnerName != null ? ' (${prize.winnerName})' : ''}'
                        : 'No qualified player',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                if (contact.isNotEmpty)
                  Text(contact,
                      style: GoogleFonts.inter(
                          fontSize: 11.5, color: AppColors.textMuted)),
                if (prize.claimCode != null)
                  Text('Claim code ${prize.claimCode}',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                if (prize.fulfilmentMethod != null && !prize.toBeGiven)
                  Text(
                      'Given as ${_methodLabels[prize.fulfilmentMethod] ?? prize.fulfilmentMethod}'
                      '${prize.fulfilledByName != null ? ' by ${prize.fulfilledByName}' : ''}'
                      '${prize.fulfilledAt != null ? ', ${Format.dateTime(prize.fulfilledAt)}' : ''}',
                      style: GoogleFonts.inter(
                          fontSize: 11.5, color: AppColors.textSecondary)),
                if (prize.fulfilmentNote != null)
                  Text(prize.fulfilmentNote!,
                      style: GoogleFonts.inter(
                          fontSize: 11.5, color: AppColors.textSecondary)),
                for (final flag in prize.flags)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flag_rounded,
                            size: 14, color: AppColors.statusRed),
                        const SizedBox(width: 4),
                        Text(_flag(flag),
                            style: GoogleFonts.inter(
                                fontSize: 11.5, color: AppColors.statusRed)),
                      ],
                    ),
                  ),
                if (_actions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Wrap(
                            spacing: 8,
                            children: [
                              for (final action in _actions)
                                OutlinedButton(
                                  onPressed: () => onFulfil(action.method),
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    side: BorderSide(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.4)),
                                  ),
                                  child: Text(action.label,
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.primary)),
                                ),
                            ],
                          ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
                prizeLabel(prize.prizeType, prize.amount, prize.itemName),
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textPrimary)),
          ),
          Expanded(
            flex: 2,
            child: Text(
                prize.finalPoints == null
                    ? ''
                    : '${Format.number(prize.finalPoints)} pts',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: status.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status.label,
                style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: status.color)),
          ),
        ],
      ),
    );
  }
}
