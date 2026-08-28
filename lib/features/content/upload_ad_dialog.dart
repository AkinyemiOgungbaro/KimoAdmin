import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/di.dart';
import '../../shared/widgets/form_fields.dart';
import '../../theme/app_theme.dart';
import 'data/banner_models.dart';
import 'package:intl/intl.dart';

class UploadAdDialog extends StatefulWidget {
  final BannerItem? existing;
  final List<PlacementItem> placements;

  const UploadAdDialog({
    super.key,
    this.existing,
    required this.placements,
  });

  @override
  State<UploadAdDialog> createState() => _UploadAdDialogState();
}

class _UploadAdDialogState extends State<UploadAdDialog> {
  final _form = GlobalKey<FormState>();
  bool _saving = false;

  late String _name = widget.existing?.name ?? '';
  late final List<String> _selectedPlacements = widget.existing?.placement.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? [];
  late String _targetUrl = widget.existing?.targetUrl ?? '';
  
  PlatformFile? _pickedImage;
  String? _startsAt;
  String? _endsAt;

  @override
  void initState() {
    super.initState();
    if (widget.existing?.startsAt != null) {
      _startsAt = widget.existing!.startsAt!.toUtc().toIso8601String();
    }
    if (widget.existing?.endsAt != null) {
      _endsAt = widget.existing!.endsAt!.toUtc().toIso8601String();
    }
  }

  Future<void> _pickImage() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (picked == null || picked.files.isEmpty) return;
    setState(() => _pickedImage = picked.files.first);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (widget.existing == null && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick an image')));
      return;
    }
    _form.currentState!.save();
    setState(() => _saving = true);
    try {
      MultipartFile? file;
      if (_pickedImage != null) {
        file = MultipartFile.fromBytes(_pickedImage!.bytes!, filename: _pickedImage!.name);
      }
      final placementsStr = _selectedPlacements.join(',');
      
      if (widget.existing != null) {
        await bannersRepository.updateBanner(
          id: widget.existing!.id,
          name: _name,
          placements: placementsStr,
          targetUrl: _targetUrl,
          startsAt: _startsAt,
          endsAt: _endsAt,
          file: file,
        );
      } else {
        await bannersRepository.addBanner(
          name: _name,
          placements: placementsStr,
          targetUrl: _targetUrl,
          startsAt: _startsAt,
          endsAt: _endsAt,
          file: file!,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart 
        ? (widget.existing?.startsAt ?? DateTime.now())
        : (widget.existing?.endsAt ?? DateTime.now().add(const Duration(days: 7)));
    
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (d == null) return;
    
    if (mounted) {
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (t == null) return;
      final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      setState(() {
        if (isStart) {
          _startsAt = dt.toUtc().toIso8601String();
        } else {
          _endsAt = dt.toUtc().toIso8601String();
        }
      });
    }
  }

  String? _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.existing != null ? 'Edit Ad' : 'Upload New Ad';
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: _name,
                onSaved: (v) => _name = v ?? '',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                decoration: fieldDecoration(hint: 'Name'),
              ),
              const SizedBox(height: 16),
              FormField<List<String>>(
                initialValue: _selectedPlacements,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                builder: (state) {
                  return InputDecorator(
                    decoration: fieldDecoration(hint: 'Placements').copyWith(errorText: state.errorText),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.placements.map((p) {
                        final isSelected = _selectedPlacements.contains(p.placement);
                        return FilterChip(
                          label: Text('${p.placement} ${p.label.isNotEmpty ? '(${p.label})' : ''}'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedPlacements.add(p.placement);
                              } else {
                                _selectedPlacements.remove(p.placement);
                              }
                              state.didChange(_selectedPlacements);
                            });
                          },
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _targetUrl,
                onSaved: (v) => _targetUrl = v ?? '',
                decoration: fieldDecoration(hint: 'Target URL'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Starts At', border: OutlineInputBorder()),
                        child: Text(_formatDate(_startsAt) ?? 'Select date'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Ends At', border: OutlineInputBorder()),
                        child: Text(_formatDate(_endsAt) ?? 'Select date'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_pickedImage != null)
                    Expanded(child: Text('Selected: ${_pickedImage!.name}', maxLines: 1, overflow: TextOverflow.ellipsis))
                  else if (widget.existing != null)
                    Expanded(child: Image.network(widget.existing!.imageUrl, height: 60, fit: BoxFit.contain, alignment: Alignment.centerLeft))
                  else
                    const Expanded(child: Text('No image selected')),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Pick Image'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Ad', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
