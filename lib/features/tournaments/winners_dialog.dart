import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/di.dart';
import '../../core/format.dart';
import '../../shared/widgets/async_view.dart';
import '../../theme/app_theme.dart';
import 'data/prize_models.dart';
import 'data/tournament_models.dart';

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
  bool _toBeGivenOnly = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = tournamentsRepository.prizes(widget.tournament.id);

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
              const SizedBox(height: 16),
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

    final rows = _toBeGivenOnly
        ? data.items.where((p) => p.status == 'awaiting_fulfilment').toList()
        : data.items;

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
              ? _note('Every prize has been given.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => _WinnerRow(prize: rows[i]),
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

class _WinnerRow extends StatelessWidget {
  final TournamentPrize prize;
  const _WinnerRow({required this.prize});

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
