import 'package:flutter/material.dart';

import '../data/model.dart';

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({required this.onSelection, this.selected, super.key});
  final void Function(LogCategory) onSelection;
  final LogCategory? selected;

  @override
  Widget build(BuildContext context) {
    const double heightButtons = 24;
    const double radius = 8;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: selected?.color ?? Colors.transparent,
          height: radius,
        ),
        Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: selected?.color ?? Colors.transparent,
              height: radius,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var category in LogCategory.orderedValues)
                  Expanded(
                    flex: category == selected ? 1 : 1,
                    child: InkWell(
                      onTap: () {
                        onSelection(category);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(radius),
                        ),
                        height: heightButtons,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
