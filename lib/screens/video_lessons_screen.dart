import 'package:flutter/material.dart';
import 'package:lms_app/widgets/shared/custom_app_bar.dart';
import 'package:lms_app/widgets/video_lesson_screen/video_grid_view.dart';
import 'package:lms_app/widgets/video_lesson_screen/video_header.dart';
import 'package:lms_app/widgets/video_lesson_screen/video_stats_section.dart';

class VideoLessonsScreen extends StatelessWidget {
  const VideoLessonsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            CustomAppBar(),
            // 1. Header (Title, Subtitle, Search Bar)
            VideoHeader(),

            // 2. Stats Cards
            SliverToBoxAdapter(child: VideoStatsSection()),

            // 3. Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 10,
                ),
                child: Text(
                  'All Course Videos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // 4. Video Grid View (SliverGrid)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              // 💡 VideoGridView එක Grid එකක් (Sliver) return කරන නිසා, 'sliver' පාවිච්චි කරයි.
              sliver: VideoGridView(),
            ),

            SliverPadding(padding: EdgeInsets.only(bottom: 20)),
          ],
        ),
      ),
    );
  }
}
