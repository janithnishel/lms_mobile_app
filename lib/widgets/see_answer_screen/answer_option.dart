// import 'package:flutter/material.dart';

// class AnswerOption extends StatelessWidget {
//   final String label;
//   final String text;
//   final bool isCorrect;
//   final bool isUserAnswer;

//   const AnswerOption({
//     Key? key,
//     required this.label,
//     required this.text,
//     required this.isCorrect,
//     required this.isUserAnswer,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColor;
//     Color borderColor;
//     Color textColor;
//     IconData? icon;
//     Color? iconColor;
//     String? statusText;

//     if (isCorrect) {
//       backgroundColor = const Color(0xFFE8F5E9);
//       borderColor = const Color(0xFF4CAF50);
//       textColor = const Color(0xFF2E7D32);
//       icon = Icons.check_circle;
//       iconColor = const Color(0xFF4CAF50);
//       statusText = 'Correct Answer';
//     } else if (isUserAnswer) {
//       backgroundColor = const Color(0xFFFFEBEE);
//       borderColor = const Color(0xFFF44336);
//       textColor = const Color(0xFFC62828);
//       icon = Icons.error;
//       iconColor = const Color(0xFFF44336);
//       statusText = 'Your Answer';
//     } else {
//       backgroundColor = Colors.white;
//       borderColor = Colors.grey[300]!;
//       textColor = Colors.black87;
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         border: Border.all(
//           color: borderColor,
//           width: isCorrect || isUserAnswer ? 2 : 1,
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: borderColor,
//                 width: 2,
//               ),
//               color: isCorrect || isUserAnswer 
//                   ? Colors.transparent 
//                   : Colors.grey[100],
//             ),
//             child: Center(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: textColor,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 15,
//                 color: textColor,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           if (icon != null && statusText != null) ...[
//             const SizedBox(width: 12),
//             Row(
//               children: [
//                 Icon(icon, color: iconColor, size: 18),
//                 const SizedBox(width: 6),
//                 Text(
//                   statusText,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: iconColor,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class AnswerOption extends StatelessWidget {
  final String label;
  final String text;
  final bool isCorrect;
  final bool isUserAnswer; // isUserAnswer is TRUE only if the user selected this option AND it is NOT the correct answer.

  const AnswerOption({
    Key? key,
    required this.label,
    required this.text,
    required this.isCorrect,
    required this.isUserAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;
    Color? iconColor;
    String? statusText;

    if (isCorrect) {
      backgroundColor = const Color(0xFFE8F5E9);
      borderColor = const Color(0xFF4CAF50);
      textColor = const Color(0xFF2E7D32);
      icon = Icons.check_circle;
      iconColor = const Color(0xFF4CAF50);
      statusText = 'Correct Answer';
    } else if (isUserAnswer) {
      // This path handles incorrect user answers (user selected it, but it's wrong)
      backgroundColor = const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFF44336);
      textColor = const Color(0xFFC62828);
      icon = Icons.error;
      iconColor = const Color(0xFFF44336);
      statusText = 'Your Answer';
    } else {
      // Default state for unselected, incorrect options
      backgroundColor = Colors.white;
      borderColor = Colors.grey[300]!;
      textColor = Colors.black87;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: isCorrect || isUserAnswer ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
              color: isCorrect || isUserAnswer 
                  ? Colors.transparent 
                  : Colors.grey[100],
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (icon != null && statusText != null) ...[
            const SizedBox(width: 12),
            Row(
              children: [
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}