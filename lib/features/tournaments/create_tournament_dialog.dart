import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_exception.dart';
import '../../core/di.dart';
import '../../core/format.dart';
import '../../shared/widgets/form_fields.dart';
import '../../theme/app_theme.dart';
import 'data/tournament_models.dart';

/// Create/edit dialog for a tournament. Pass [existing] to edit; omit to create.
/// Returns `true` when a tournament was created or updated.
class TournamentFormDialog extends StatefulWidget {
  final TournamentItem? existing;
  const TournamentFormDialog({super.key, this.existing});

  @override
  State<TournamentFormDialog> createState() => _TournamentFormDialogState();
}

class _TournamentFormDialogState extends State<TournamentFormDialog> {
  final _name = TextEditingController();
  final _duration = TextEditingController();
  final _limit = TextEditingController();
  final _pool = TextEditingController();
  final _entryFee = TextEditingController();
  final _attempts = TextEditingController(text: '1');
  final _code = TextEditingController();

  DateTime? _startsAt;
  bool _busy = false;
  bool _generatingCode = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _name.text = e.name;
      _startsAt = DateTime.tryParse(e.startsAt ?? '')?.toLocal();
      _duration.text = e.durationMinutes.toString();
      _limit.text = e.participantLimit.toString();
      _pool.text = (e.prizePoolKobo / 100).toStringAsFixed(0);
      _entryFee.text = e.entryFeeCoins.toString();
      _attempts.text =
          e.attemptsPerGame == 0 ? '1' : e.attemptsPerGame.toString();
      _code.text = e.entryCode ?? '';
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _duration,
      _limit,
      _pool,
      _entryFee,
      _attempts,
      _code
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startsAt ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt ?? now),
    );
    if (time == null) return;
    setState(() {
      _startsAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _generateCode() async {
    setState(() => _generatingCode = true);
    try {
      final code = await tournamentsRepository.entryCode();
      if (code.isNotEmpty) setState(() => _code.text = code);
    } catch (_) {
      // Non-fatal: the admin can also type a code manually.
    } finally {
      if (mounted) setState(() => _generatingCode = false);
    }
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    final name = _name.text.trim();
    if (name.isEmpty) return _fail('Enter a tournament name');
    if (_startsAt == null) return _fail('Choose a start date & time');

    final duration = int.tryParse(_duration.text.trim());
    if (duration == null || duration <= 0)
      return _fail('Enter a valid duration (minutes)');

    final limitText = _limit.text.trim();
    final limit = limitText.isEmpty ? 0 : int.tryParse(limitText);
    if (limit == null || limit < 0)
      return _fail('Enter a valid participant limit');

    final poolNaira = num.tryParse(_pool.text.trim());
    if (poolNaira == null || poolNaira < 0)
      return _fail('Enter a valid prize pool');

    final entryFee = int.tryParse(_entryFee.text.trim());
    if (entryFee == null || entryFee < 0)
      return _fail('Enter a valid entry fee');

    final attempts = int.tryParse(_attempts.text.trim());
    if (attempts == null || attempts <= 0)
      return _fail('Enter valid attempts per game');

    final code = _code.text.trim();

    final form = TournamentForm(
      name: name,
      startsAt: _startsAt!.toUtc().toIso8601String(),
      durationMinutes: duration,
      entryFeeCoins: entryFee,
      prizePoolKobo: (poolNaira * 100).round(),
      attemptsPerGame: attempts,
      participantLimit: limit,
      entryCode: code,
    );

    setState(() => _busy = true);
    try {
      if (_isEdit) {
        await tournamentsRepository.update(widget.existing!.id, form.toJson());
      } else {
        await tournamentsRepository.create(form);
      }
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      _fail(e.message);
    } catch (_) {
      _fail('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _fail(String message) => setState(() => _error = message);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_isEdit ? 'Edit Tournament' : 'Create a New Tournament',
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        size: 20, color: AppColors.textSecondary),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _label('Tournament Title'),
              TextField(
                  controller: _name,
                  decoration: fieldDecoration(hint: 'e.g. Weekend Cup')),
              const SizedBox(height: 14),
              _label('Start Date & Time'),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(10),
                child: InputDecorator(
                  decoration: fieldDecoration().copyWith(
                    suffixIcon: const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.textMuted),
                  ),
                  child: Text(
                    _startsAt == null
                        ? 'Select date & time'
                        : Format.dateTime(_startsAt!.toIso8601String()),
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _startsAt == null
                            ? AppColors.textMuted
                            : AppColors.textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: _numberField('Duration (minutes)', _duration)),
                  const SizedBox(width: 12),
                  Expanded(child: _numberField('Participant Limit', _limit)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _numberField('Prize Pool (₦)', _pool)),
                  const SizedBox(width: 12),
                  Expanded(child: _numberField('Entry Fee (coins)', _entryFee)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _numberField('Attempts / game', _attempts)),
                  const SizedBox(width: 12),
                  Expanded(child: _codeField()),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                _errorBanner(_error!),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : Text(_isEdit ? 'Save changes' : 'Create tournament',
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      );

  Widget _numberField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: fieldDecoration(),
          style: GoogleFonts.inter(fontSize: 13),
        ),
      ],
    );
  }

  Widget _codeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Entry Code'),
        TextField(
          controller: _code,
          textCapitalization: TextCapitalization.characters,
          decoration: fieldDecoration(hint: 'ABC123').copyWith(
            suffixIcon: _generatingCode
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : TextButton(
                    onPressed: _generateCode,
                    child: Text('Generate',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.primary)),
                  ),
          ),
          style: GoogleFonts.inter(fontSize: 13),
        ),
      ],
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: AppColors.statusRedBg, borderRadius: BorderRadius.circular(8)),
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
