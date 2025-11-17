// import 'package:flutter/material.dart';

// class VideoCard extends StatelessWidget {
//   final String title;
//   final String description;
//   final String author;
//   final String date;
//   final String classTag;
//   final String yearTag;

//   const VideoCard({
//     Key? key,
//     required this.title,
//     required this.description,
//     required this.author,
//     required this.date,
//     required this.classTag,
//     required this.yearTag,
//   }) : super(key: key);

//   // Reusable Chip Widget for tags
//   Widget _buildTagChip(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.bold,
//           color: color,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 1.5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey[200]!, width: 0.5),
//       ),
//       margin: EdgeInsets.zero,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 📺 Video Thumbnail Placeholder (dark box like in the screenshot)
//           Container(
//             height: 150,
//             decoration: const BoxDecoration(
//               color: Color(0xFF1E293B), // Dark Navy/Slate color
//               borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Title
//                 Text(
//                   title,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),

//                 // Description
//                 Text(
//                   description,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // Tags/Chips Row
//                 Row(
//                   children: [
//                     _buildTagChip(classTag, Colors.blue[700]!),
//                     const SizedBox(width: 8),
//                     _buildTagChip(yearTag, Colors.green[600]!),
//                   ],
//                 ),
//                 const SizedBox(height: 10),

//                 // Author and Date
//                 Row(
//                   children: [
//                     Icon(Icons.person, size: 14, color: Colors.grey[500]),
//                     const SizedBox(width: 4),
//                     Text(
//                       author,
//                       style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//                     ),
//                     const Spacer(),
//                     Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
//                     const SizedBox(width: 4),
//                     Text(
//                       date,
//                       style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//                     ),
//                   ],
//                 ),
//                 const Divider(height: 20),

//                 // Watch Lesson Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       // Lesson බලන්න අවශ්‍ය code එක මෙතනට දාන්න
//                       print('Watching lesson: $title');
//                     },
//                     icon: const Icon(Icons.play_circle_fill, size: 18),
//                     label: const Text(
//                       'Watch Lesson',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.white,
//                       backgroundColor: const Color(0xFF007BFF),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 10),
//                       elevation: 0,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:lms_app/widgets/shared/video_tag.dart';

class VideoCard extends StatelessWidget {
  final String title;
  final String description;
  final String teacher;
  final String date;
  final String author;
  final String year;

  const VideoCard({
    Key? key,
    required this.title,
    required this.description,
    required this.teacher,
    required this.date,
    required this.author,
    required this.year,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // 📺 Video Thumbnail
          Container(
            height: 180, // Height reduced.
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E), // Dark Navy/Slate color
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Video Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Tags
                Row(
                  children: [
                    // Changed icons
                    VideoTag(
                      // Adds only the text of the Tag instead of Icon
                      icon: Icons.person_pin_circle,
                      text: author,
                      backgroundColor: Colors.blue[50]!,
                      textColor: Colors.blue[700]!,
                    ),
                    const SizedBox(width: 8),
                    VideoTag(
                      icon: Icons.calendar_today,
                      text: year,
                      backgroundColor: Colors.green[50]!,
                      textColor: Colors.green[700]!,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Teacher and Date
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey[600],
                    ), // Icon changed
                    const SizedBox(width: 4),
                    Text(
                      teacher,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ), // Icon changed
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 🚀 Watch Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    // Used ElevatedButton instead of OutlinedButton
                    onPressed: () {},
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Watch Lesson',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF), // Primary blue
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
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
