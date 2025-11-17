import 'package:flutter/material.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        // Divide space in the main Row
        children: [
          // 👤 Avatar
          const CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 30,
            child: Text(
              'J',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Text Content (Welcome Message)
          // Uses Expanded instead of Flexible. (removed width 150)
          Expanded(
            child: Column(
              children: [
                // To prevent overflow of 'Welcome back, Janith!' Text in the Row
                // Wrapped Text with Expanded.
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      // Because this was added, Text can give space to Tag
                      child: Text(
                        'Welcome back, Janith!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),

                        maxLines: 2, // 💡 තනි පේළියට සීමා කරයි
                        // overflow: TextOverflow.ellipsis, // 💡 තිත් තුනක් පෙන්වයි
                      ),
                    ),
                    // No problem because Emoji has fixed space.
                    Text('👋', style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 4),
                // Also put MaxLines limit for description
                Text(
                  'Ready to continue your ICT A-Level journey?',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 2,
                  // overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8), // 💡 Text සහ Tag අතර පොඩි ඉඩක් දුන්නා
          // 🟢 STUDENT Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize
                  .min, // 💡 Tag එකේ width එක content එකට සීමා කරයි.
              children: [
                Icon(Icons.backpack, size: 14, color: Colors.green[700]),
                const SizedBox(width: 4),
                Text(
                  'STUDENT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
