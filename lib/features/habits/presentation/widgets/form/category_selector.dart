import 'package:flutter/material.dart';
import 'package:lyfer/core/shared/models/category_model.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategoryId;
  final Function(String) onCategorySelected;
  final Function(Color?) onColorSelected;

  const CategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currentCategory = appCategories.firstWhere(
      (category) => category.id == selectedCategoryId,
      orElse: () => appCategories.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 96, // Fixed height for the scrolling area
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: appCategories.map((category) {
                final isSelected = category.id == selectedCategoryId;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      onCategorySelected(category.id);
                      // Update color to match the category default if desired
                      if (isSelected == false) {
                        onColorSelected(category.defaultColor);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      width: 80, // Fixed width for consistent size
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category.defaultColor.withOpacity(0.2)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? category.defaultColor
                              : Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category.icon,
                            size: 32,
                            color: isSelected
                                ? category.defaultColor
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? category.defaultColor
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
