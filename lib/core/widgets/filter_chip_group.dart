import 'package:flutter/material.dart';
import '../constants/motion.dart';

class FilterChipGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selectedOption;
  final Function(String?) onSelected;
  final bool showAllOption;

  const FilterChipGroup({
    super.key,
    required this.label,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allOptions = showAllOption ? ['All', ...options] : options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allOptions.map((option) {
            final isSelected = selectedOption == option ||
                (selectedOption == null && option == 'All');

            return AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppMotion.easing,
              child: FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onSelected(option == 'All' ? null : option);
                  }
                },
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primaryContainer,
                checkmarkColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.2),
                  width: isSelected ? 1.5 : 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
