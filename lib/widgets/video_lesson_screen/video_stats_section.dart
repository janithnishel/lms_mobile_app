// import 'package:flutter/material.dart';
// import '../shared/stat_card.dart'; // Imports reusable StatCard

// class VideoStatsSection extends StatelessWidget {
//   const VideoStatsSection({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: StatCard(
//                   // Updated to have 5 'Available Videos' as per the screenshot
//                   title: 'Available Videos',
//                   icon: Icons.videocam_outlined, 
//                   value: '5',
//                   bgColor: Colors.blue[50]!,
//                   iconColor: Colors.blue,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: StatCard(
//                   title: 'My Classes',
//                   icon: Icons.account_balance_outlined,
//                   value: '1',
//                   bgColor: Colors.green[50]!,
//                   iconColor: Colors.green,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: StatCard(
//                   title: 'Learning Progress',
//                   icon: Icons.lightbulb_outline,
//                   value: '65%',
//                   bgColor: Colors.purple[50]!,
//                   iconColor: Colors.purple,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: StatCard(
//                   title: 'Hours Watched',
//                   icon: Icons.access_time_filled,
//                   value: '24.5hrs',
//                   bgColor: Colors.orange[50]!,
//                   iconColor: Colors.orange,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:lms_app/widgets/shared/video_stats_card.dart';

class VideoStatsSection extends StatelessWidget {
  const VideoStatsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: VideoStatsCard(
                  title: 'Available Videos',
                  value: '5',
                  icon: Icons.video_library,
                  bgColor: Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: VideoStatsCard(
                  title: 'My Classes',
                  value: '1',
                  icon: Icons.school,
                  bgColor: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: VideoStatsCard(
                  title: 'Learning Progress',
                  value: '65%',
                  icon: Icons.school_outlined,
                  bgColor: Colors.purple,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: VideoStatsCard(
                  title: 'Hours Watched',
                  value: '24.5hrs',
                  icon: Icons.access_time,
                  bgColor: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
