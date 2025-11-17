import 'package:flutter/material.dart';
import 'video_card_dashboard.dart'; // Reusable VideoItem එක Import කරයි

class VideoListSection extends StatelessWidget {
  const VideoListSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 💡 VideoItem එක re-use කරයි
        VideoCard(title: 'sample video.jvhvjhvhjkv', author: 'Sipta', date: '11/08/2025'),
        VideoCard(title: 'python video', author: 'Sipta', date: '16/08/2025'),
        VideoCard(title: 'sampel voide', author: 'Sipta', date: '16/08/2025'),
        VideoCard(title: 'hvc', author: 'Sipta', date: '09/10/2025'),
        
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View All Videos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}