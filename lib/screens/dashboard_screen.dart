import 'package:flutter/material.dart';
import 'package:lms_app/widgets/dashboard_screen/learning_activity_section.dart';
import 'package:lms_app/widgets/dashboard_screen/quick_access_section.dart';
import 'package:lms_app/widgets/dashboard_screen/stats_section.dart';
import 'package:lms_app/widgets/dashboard_screen/video_list_section.dart';
import 'package:lms_app/widgets/dashboard_screen/welcome_card.dart';
import 'package:lms_app/widgets/shared/custom_app_bar.dart';
import '../widgets/shared/search_bar.dart'; // Reusable SearchBar එක Import කරයි

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar (No change needed here)
            CustomAppBar(),

            // Content Sections
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WelcomeCard(),
                    const SizedBox(height: 20),

                    // Stats Cards Section
                    const StatsSection(),
                    const SizedBox(height: 24),

                    // Continue Learning Header
                    const Text(
                      'Continue Learning',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 💡 Reusable Search Bar එක භාවිතා කරයි
                    const CustomSearchBar(hintText: 'Search lessons...'),
                    const SizedBox(height: 16),

                    // Video List Section
                    const VideoListSection(),
                    const SizedBox(height: 24),

                    // Quick Access Section
                    const Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const QuickAccessSection(),
                    const SizedBox(height: 24),

                    // Learning Activity Section
                    const Text(
                      'Learning Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const LearningActivitySection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
