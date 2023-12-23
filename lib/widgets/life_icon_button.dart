
import 'package:flutter/material.dart';

class LifeIconButton extends StatelessWidget {
  const LifeIconButton({
    super.key,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    required this.color,
    required this.iconData,
  });
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final Color color;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.white10),
        padding: const EdgeInsets.all(10),
        child: Icon(iconData, color: color),
      ),
    );
  }
}
