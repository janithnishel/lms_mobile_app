import 'package:flutter/material.dart';

class ReviewInfoBanner extends StatelessWidget {
  const ReviewInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD), // Light Blue
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBBDEFB)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.visibility,
              color: Color(0xFF1976D2),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Review Mode: Correct answers are highlighted in green. Your answers (if any) are highlighted in red if incorrect.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue[900],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}