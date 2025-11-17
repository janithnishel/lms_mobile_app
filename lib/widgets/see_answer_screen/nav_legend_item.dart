import 'package:flutter/material.dart';

class NavLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const NavLegendItem({
    Key? key,
    required this.color,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: color == Colors.blue 
                  ? Colors.blue 
                  : Colors.grey[400]!,
              width: color == Colors.blue ? 2 : 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}