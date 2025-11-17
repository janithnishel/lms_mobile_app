// import 'package:flutter/material.dart';

// class StatsCard extends StatelessWidget {
//   final IconData icon;
//   final Color iconColor;
//   final String title;
//   final String value;

//   const StatsCard({
//     Key? key,
//     required this.icon,
//     required this.iconColor,
//     required this.title,
//     required this.value,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Responsive width calculation based on screen size
//     final screenWidth = MediaQuery.of(context).size.width;
//     final cardWidth = (screenWidth - 48) / 2; // 16 * 2 padding + 16 spacing / 2 columns

//     return Container(
//       width: cardWidth > 300 ? 300 : cardWidth, // Max width limit for large screens
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Icon(icon, color: iconColor, size: 28),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: iconColor.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   title.split(' ')[0], // Papers, Average, Best
//                   style: TextStyle(
//                     color: iconColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 10,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.w800,
//               color: Colors.black87,
//             ),
//           ),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.black54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ResultStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? badge;
  final Color? badgeColor;
  final bool showTrophy;

  const ResultStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.badge,
    this.badgeColor,
    this.showTrophy = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
              if (showTrophy) ...[
                const SizedBox(width: 8),
                Icon(Icons.emoji_events, color: Colors.amber[700], size: 24),
              ],
            ],
          ),
        ],
      ),
    );
  }
}


