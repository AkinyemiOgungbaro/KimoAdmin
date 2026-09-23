import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/format.dart';
import '../../shared/widgets/form_fields.dart';
import '../../theme/app_theme.dart';
import 'data/tournament_models.dart';

const _prizeTypes = {'cash': 'Cash', 'airtime': 'Airtime', 'item': 'Item'};

class PrizeBandDraft {
  String type;
  final TextEditingController toRank;
  final TextEditingController amount;
  final TextEditingController itemName;

  PrizeBandDraft(int toRank)
      : type = 'cash',
        toRank = TextEditingController(text: '$toRank'),
        amount = TextEditingController(),
        itemName = TextEditingController();

  PrizeBandDraft.from(PrizeBand band)
      : type = band.type,
        toRank = TextEditingController(text: '${band.toRank}'),
        amount = TextEditingController(
            text: band.type == 'item'
                ? ''
                : (band.amountKobo / 100).toStringAsFixed(0)),
        itemName = TextEditingController(text: band.itemName ?? '');

  void dispose() {
    toRank.dispose();
    amount.dispose();
    itemName.dispose();
  }
}

int _fromRank(List<PrizeBandDraft> bands, int index) {
  var from = 1;
  for (var i = 0; i < index; i++) {
    from = (int.tryParse(bands[i].toRank.text.trim()) ?? from) + 1;
  }
  return from;
}

/// The bands as the API takes them, or the reason they cannot be sent.
({List<PrizeBand> bands, String? error}) buildPrizeBands(
    List<PrizeBandDraft> drafts) {
  final bands = <PrizeBand>[];

  for (var i = 0; i < drafts.length; i++) {
    final draft = drafts[i];
    final from = _fromRank(drafts, i);
    final to = int.tryParse(draft.toRank.text.trim());

    if (to == null || to < from) {
      return (
        bands: bands,
        error: 'Prize ${i + 1}: end on rank $from or later'
      );
    }

    if (draft.type == 'item') {
      final name = draft.itemName.text.trim();
      if (name.length < 2) {
        return (bands: bands, error: 'Prize ${i + 1}: name the item');
      }
      bands.add(
          PrizeBand(fromRank: from, toRank: to, type: 'item', itemName: name));
      continue;
    }

    final naira = num.tryParse(draft.amount.text.trim());
    if (naira == null || naira <= 0) {
      return (bands: bands, error: 'Prize ${i + 1}: enter an amount');
    }
    bands.add(PrizeBand(
        fromRank: from,
        toRank: to,
        type: draft.type,
        amountKobo: (naira * 100).round()));
  }

  return (bands: bands, error: null);
}

class PrizeBandsEditor extends StatelessWidget {
  final List<PrizeBandDraft> bands;
  final VoidCallback onChanged;

  const PrizeBandsEditor(
      {super.key, required this.bands, required this.onChanged});

  void _add() {
    bands.add(PrizeBandDraft(_fromRank(bands, bands.length)));
    onChanged();
  }

  void _remove(int index) {
    bands.removeAt(index).dispose();
    onChanged();
  }

  String _summary() {
    final built = buildPrizeBands(bands).bands;
    var winners = 0;
    num cash = 0;
    num airtime = 0;
    var items = 0;

    for (final band in built) {
      winners += band.winners;
      if (band.type == 'cash') cash += band.amountKobo * band.winners;
      if (band.type == 'airtime') airtime += band.amountKobo * band.winners;
      if (band.type == 'item') items += band.winners;
    }

    return [
      '$winners ${winners == 1 ? 'winner' : 'winners'}',
      if (cash > 0) '${Format.naira(cash)} cash',
      if (airtime > 0) '${Format.naira(airtime)} airtime',
      if (items > 0) '$items ${items == 1 ? 'item' : 'items'}',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Prizes',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const Spacer(),
            if (bands.isNotEmpty)
              Text(_summary(),
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < bands.length; i++) _row(i),
        TextButton.icon(
          onPressed: _add,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text('Add prize',
              style:
                  GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ],
    );
  }

  Widget _row(int index) {
    final band = bands[index];
    final from = _fromRank(bands, index);

    return Padding(
      key: ObjectKey(band),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text('Rank $from to',
                style: GoogleFonts.inter(
                    fontSize: 12.5, color: AppColors.textSecondary)),
          ),
          SizedBox(
            width: 64,
            child: TextField(
              controller: band.toRank,
              keyboardType: TextInputType.number,
              decoration: fieldDecoration(),
              style: GoogleFonts.inter(fontSize: 13),
              onChanged: (_) => onChanged(),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: DropdownButtonFormField<String>(
              initialValue: band.type,
              isDense: true,
              decoration: fieldDecoration(),
              style:
                  GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
              items: [
                for (final entry in _prizeTypes.entries)
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
              ],
              onChanged: (value) {
                band.type = value ?? band.type;
                onChanged();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: ValueKey(band.type == 'item'),
              controller: band.type == 'item' ? band.itemName : band.amount,
              keyboardType: band.type == 'item'
                  ? TextInputType.text
                  : TextInputType.number,
              decoration: fieldDecoration(
                  hint: band.type == 'item'
                      ? 'e.g. Wireless earbuds'
                      : 'Amount (₦) each'),
              style: GoogleFonts.inter(fontSize: 13),
              onChanged: (_) => onChanged(),
            ),
          ),
          IconButton(
            onPressed: () => _remove(index),
            tooltip: 'Remove',
            icon: const Icon(Icons.close_rounded,
                size: 18, color: AppColors.textSecondary),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
