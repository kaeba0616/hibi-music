/// 필터 칩 바 위젯

import 'package:flutter/material.dart';

class FilterChipBar<T> extends StatelessWidget {
  final List<FilterChipItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T?> onSelected;

  const FilterChipBar({
    super.key,
    required this.items,
    this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: const Text('전체'),
            selected: selectedValue == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(item.label),
                  selected: selectedValue == item.value,
                  onSelected: (_) => onSelected(item.value),
                ),
              )),
        ],
      ),
    );
  }
}

class FilterChipItem<T> {
  final T value;
  final String label;

  const FilterChipItem({
    required this.value,
    required this.label,
  });
}
