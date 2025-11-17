import 'package:flutter/material.dart';
import '../shared/video_stats_card.dart'; // Reusable StatCard එක Import කරයි

class StatsSection extends StatelessWidget {
  const StatsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: VideoStatsCard(
                title: 'Available Videos',
                value: '5',
                icon: Icons.video_library,
                bgColor: Colors.blue[50]!,
                iconColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: VideoStatsCard(
                title: 'Subjects',
                value: '1',
                icon: Icons.book,
                bgColor: Colors.green[50]!,
                iconColor: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: VideoStatsCard(
                title: 'Hours Watched',
                value: '24.5hrs',
                icon: Icons.access_time,
                bgColor: Colors.purple[50]!,
                iconColor: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: VideoStatsCard(
                title: 'Progress',
                value: '85%',
                icon: Icons.military_tech,
                bgColor: Colors.orange[50]!,
                iconColor: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}