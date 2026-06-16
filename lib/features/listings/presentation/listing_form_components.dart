import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';

const listingUnits = <String>['kg', 'piece', 'bunch', 'bag', 'box', 'jar'];

class ListingSectionTitle extends StatelessWidget {
  const ListingSectionTitle(this.title, {this.description, super.key});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class SellingUnitField extends StatelessWidget {
  const SellingUnitField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = listingUnits.contains(value)
        ? listingUnits
        : <String>[value, ...listingUnits];
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: l10n.sellingUnitLabel,
        prefixIcon: const Icon(Icons.scale_outlined),
      ),
      items: options
          .map(
            (unit) => DropdownMenuItem(
              value: unit,
              child: Text(_unitLabel(l10n, unit)),
            ),
          )
          .toList(),
      onChanged: (unit) {
        if (unit != null) {
          onChanged(unit);
        }
      },
    );
  }

  static String _unitLabel(AppLocalizations l10n, String unit) {
    return switch (unit) {
      'kg' => l10n.kilogramUnit,
      'piece' => l10n.pieceUnit,
      'bunch' => l10n.bunchUnit,
      'bag' => l10n.bagUnit,
      'box' => l10n.boxUnit,
      'jar' => l10n.jarUnit,
      _ => unit,
    };
  }
}

class PricePerUnitField extends StatelessWidget {
  const PricePerUnitField({
    required this.controller,
    required this.unit,
    required this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String unit;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      decoration: InputDecoration(
        labelText: l10n.customerPriceLabel,
        helperText: l10n.pricePerUnitHelp(unit),
        prefixText: '€  ',
        suffixText: l10n.perUnitLabel(unit),
        prefixIcon: const Icon(Icons.euro_rounded),
      ),
    );
  }
}

class HarvestDateField extends StatelessWidget {
  const HarvestDateField({
    required this.value,
    required this.onChanged,
    this.label = 'Produced date (optional)',
    super.key,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: value == null
            ? ''
            : MaterialLocalizations.of(context).formatMediumDate(value!),
      ),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 2),
          lastDate: DateTime(now.year + 2),
          helpText: label,
        );
        if (picked != null) onChanged(picked);
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: l10n.selectDateHint,
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        suffixIcon: value == null
            ? null
            : IconButton(
                tooltip: l10n.clearDateTooltip,
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}

class FarmLocationCard extends StatelessWidget {
  const FarmLocationCard({
    required this.city,
    required this.country,
    super.key,
  });

  final String city;
  final String country;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final place = [city, country].where((value) => value.isNotEmpty).join(', ');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Farm pickup location',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(place.isEmpty ? 'Location from your farm profile' : place),
                const SizedBox(height: 3),
                Text(
                  'Set automatically from your farm GPS location',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: theme.colorScheme.primary),
        ],
      ),
    );
  }
}
