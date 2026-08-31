import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_exception.dart';
import '../../core/di.dart';
import '../../shared/widgets/form_fields.dart';
import '../../theme/app_theme.dart';
import 'data/reward_models.dart';

/// Create/edit dialog for a reward. Pass [existing] to edit; omit to create.
/// Returns `true` when a reward was created or updated.
class RewardFormDialog extends StatefulWidget {
  final RewardItem? existing;
  const RewardFormDialog({super.key, this.existing});

  @override
  State<RewardFormDialog> createState() => _RewardFormDialogState();
}

class _RewardFormDialogState extends State<RewardFormDialog> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _subcategory = TextEditingController();
  final _coinCost = TextEditingController();
  final _cashCost = TextEditingController();
  final _discountPercent = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '0');

  static const _categories = <(String, String)>[
    ('gadget', 'Gadget'),
    ('airtime_data', 'Airtime & Data'),
    ('clothing', 'Clothing'),
    ('food', 'Food'),
  ];
  static const _types = <(String, String)>[
    ('physical', 'Physical'),
    ('airtime', 'Airtime'),
    ('data', 'Data'),
  ];

  static const _networks = <(String, String)>[
    ('mtn', 'MTN'),
    ('glo', 'Glo'),
    ('airtel', 'Airtel'),
    ('9mobile', '9mobile'),
  ];

  String _category = 'gadget';
  String _type = 'physical';
  String _network = 'mtn';
  
  List<DataPlan> _dataPlans = [];
  bool _fetchingPlans = false;
  String? _selectedVariation;

  PlatformFile? _picked;
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _name.text = e.name;
      _subcategory.text = e.subcategory ?? '';
      _coinCost.text = e.coinCost.toStringAsFixed(0);
      _cashCost.text = (e.cashCostKobo / 100).toStringAsFixed(0);
      _discountPercent.text = e.discountPercent.toStringAsFixed(0);
      _price.text = (e.priceKobo / 100).toStringAsFixed(0);
      _stock.text = e.stock.toStringAsFixed(0);
      if (_categories.any((c) => c.$1 == e.category)) _category = e.category;
      if (_types.any((t) => t.$1 == e.type)) _type = e.type;
      if (e.network != null) {
        final net = e.network!.toLowerCase();
        if (_networks.any((n) => n.$1 == net)) {
          _network = net;
        }
      }
      if (_type == 'data') {
        _selectedVariation = e.providerVariationId;
        _fetchDataPlans();
      }
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _description, _subcategory, _coinCost, _cashCost, _discountPercent, _price, _stock]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchDataPlans() async {
    if (_type != 'data') return;
    setState(() => _fetchingPlans = true);
    try {
      final plans = await rewardsRepository.getDataPlans(_network);
      if (mounted) {
        setState(() {
          _dataPlans = plans;
          if (plans.isNotEmpty && !plans.any((p) => p.variationCode == _selectedVariation)) {
            _selectedVariation = plans.first.variationCode;
          }
        });
      }
    } catch (e) {
      if (mounted) _fail('Failed to fetch data plans');
    } finally {
      if (mounted) setState(() => _fetchingPlans = false);
    }
  }

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (res != null && res.files.isNotEmpty) {
      setState(() => _picked = res.files.first);
    }
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    final isData = _type == 'data';
    final isDigital = _type == 'airtime' || isData;

    final name = _name.text.trim();
    if (!isData && name.isEmpty) return _fail('Enter a product name');

    final coin = num.tryParse(_coinCost.text.trim());
    if (coin == null || coin < 0) return _fail('Enter a valid coin cost');

    num? cash, discount;
    if (isDigital) {
      discount = num.tryParse(_discountPercent.text.trim());
      if (discount == null || discount < 0) return _fail('Enter a valid discount percent');
    } else {
      cash = num.tryParse(_cashCost.text.trim());
      if (cash == null || cash < 0) return _fail('Enter a valid cash cost');
    }

    num? price;
    if (!isData) {
      price = num.tryParse(_price.text.trim());
      if (price == null || price < 0) return _fail('Enter a valid price');
    }

    final stock = int.tryParse(_stock.text.trim());
    if (!isData && (stock == null || stock < 0)) return _fail('Enter a valid stock quantity');

    if (!_isEdit && _picked == null && !isDigital) return _fail('Add a product image');

    if (isData && _selectedVariation == null) return _fail('Select a data plan');

    final form = RewardForm(
      name: isData ? null : name,
      description: _description.text.trim(),
      type: _type,
      category: _category,
      subcategory: _subcategory.text.trim(),
      network: isDigital ? _network : null,
      variationCode: isData ? _selectedVariation : null,
      priceKobo: isData ? null : (price! * 100).round(),
      coinCost: coin,
      cashCostKobo: isDigital ? null : (cash! * 100).round(),
      discountPercent: isDigital ? discount : null,
      stock: isData ? 0 : stock,
      imageBytes: _picked?.bytes,
      imageFilename: _picked?.name,
    );

    setState(() => _busy = true);
    try {
      if (_isEdit) {
        await rewardsRepository.update(widget.existing!.id, form);
      } else {
        await rewardsRepository.create(form);
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
                  Text(_isEdit ? 'Edit Reward' : 'Add New Reward',
                      style: GoogleFonts.inter(
                          fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _dropdown('Category', _category, _categories, (v) => setState(() => _category = v))),
                  const SizedBox(width: 12),
                  Expanded(child: _dropdown('Type', _type, _types, (v) {
                    setState(() => _type = v);
                    if (v == 'data') _fetchDataPlans();
                  })),
                ],
              ),
              const SizedBox(height: 14),
              if (_type == 'data' || _type == 'airtime') ...[
                _dropdown('Network', _network, _networks, (v) {
                  setState(() => _network = v);
                  if (_type == 'data') _fetchDataPlans();
                }),
                const SizedBox(height: 14),
              ] else ...[
                _label('Subcategory (optional)'),
                TextField(
                  controller: _subcategory,
                  decoration: fieldDecoration(hint: 'e.g. Power banks'),
                ),
                const SizedBox(height: 14),
              ],
              
              if (_type == 'data') ...[
                _label('Data Plan'),
                if (_fetchingPlans)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_dataPlans.isEmpty)
                  Text('No plans available for $_network', style: GoogleFonts.inter(color: AppColors.statusRed))
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.pageBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedVariation,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                            items: _dataPlans.map((p) => DropdownMenuItem(
                              value: p.variationCode,
                              child: Text(p.name, style: GoogleFonts.inter(fontSize: 13), overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: (v) => setState(() => _selectedVariation = v),
                          ),
                        ),
                      ),
                      if (_selectedVariation != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Provider Cost: ₦${(_dataPlans.firstWhere((p) => p.variationCode == _selectedVariation).amountKobo / 100).toStringAsFixed(2)}',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                const SizedBox(height: 14),
              ] else ...[
                _label('Product Name'),
                TextField(controller: _name, decoration: fieldDecoration(hint: 'e.g. MTN 1GB Data')),
                const SizedBox(height: 14),
              ],

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _numberField('Coin Cost', _coinCost)),
                  const SizedBox(width: 12),
                  if (_type == 'airtime' || _type == 'data')
                    Expanded(child: _numberField('Discount (%)', _discountPercent))
                  else
                    Expanded(child: _numberField('Cash Cost (₦)', _cashCost)),
                ],
              ),
              const SizedBox(height: 14),
              
              if (_type != 'data') ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _numberField('Price (₦)', _price)),
                    const SizedBox(width: 12),
                    Expanded(child: _numberField('Stock', _stock)),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              
              _label('Product Image (Optional for data/airtime)'),
              _imagePicker(),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text(_isEdit ? 'Save changes' : 'Add reward',
                          style: GoogleFonts.inter(
                              fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
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
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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

  Widget _dropdown(
    String label,
    String value,
    List<(String, String)> options,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.pageBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
              items: options
                  .map((o) => DropdownMenuItem(
                        value: o.$1,
                        child: Text(o.$2, style: GoogleFonts.inter(fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagePicker() {
    final hasImage = _picked != null;
    final keepingExisting = _isEdit && !hasImage;
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(hasImage ? Icons.check_circle_rounded : Icons.upload_rounded,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                hasImage
                    ? _picked!.name
                    : keepingExisting
                        ? 'Replace image (keeping current)'
                        : 'Upload image',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.statusRedBg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.statusRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.statusRed)),
          ),
        ],
      ),
    );
  }
}
