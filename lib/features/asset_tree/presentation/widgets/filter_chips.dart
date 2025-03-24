import 'package:flutter/material.dart';

class FilterChips extends StatelessWidget {
  final ValueChanged<bool> onEnergyFilterChanged;
  final ValueChanged<bool> onCriticalFilterChanged;
  final bool hasEnergyFilter;
  final bool hasCriticalFilter;

  const FilterChips({
    super.key,
    required this.onEnergyFilterChanged,
    required this.onCriticalFilterChanged,
    required this.hasEnergyFilter,
    required this.hasCriticalFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilterChip(
          label: const Text('Energy'),
          selected: hasEnergyFilter,
          onSelected: onEnergyFilterChanged,
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('Critical'),
          selected: hasCriticalFilter,
          onSelected: onCriticalFilterChanged,
        ),
      ],
    );
  }
}
