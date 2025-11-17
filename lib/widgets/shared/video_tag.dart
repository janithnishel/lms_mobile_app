// lib/widgets/shared/video_tag.dart

import 'package:flutter/material.dart';

class VideoTag extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon; // IconData property added now

  const VideoTag({
    Key? key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.icon, // Added to constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row( // 💡 Icon එක සහ Text එක දෙකම එකට දාන්න Row එකක් භාවිතා කළා
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) // Displays only if an Icon is provided
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Icon(
                icon,
                size: 14, // Icon එකේ size එක ටිකක් කුඩා කළා
                color: textColor,
              ),
            ),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}