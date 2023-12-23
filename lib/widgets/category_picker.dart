import 'package:flutter/material.dart';

import '../data/model.dart';

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({required this.onSelection, super.key, this.selected});
  final void Function(LogCategory) onSelection;
  final LogCategory? selected;

  @override
  Widget build(BuildContext context) {
    const double heightButtons = 24;
    return Column(
      children: [
        Container(color: selected?.color ?? Colors.transparent, height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var category in LogCategory.orderedValues)
              Expanded(
                flex: category == selected ? 1 : 4,
                child: InkWell(
                  onTap: () {
                    onSelection(category);
                  },
                  child: Stack(children: [
                    Container(
                        color: selected?.color ?? Colors.transparent,
                        height: heightButtons),
                    Container(
                      decoration: BoxDecoration(
                        color: category.color,
                        borderRadius: selected == category
                            ? const BorderRadiusDirectional.all(
                                Radius.circular(10))
                            : const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                      ),
                      height: heightButtons,
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
