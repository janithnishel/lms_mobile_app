import 'package:flutter/material.dart';
import 'package:lms_app/screens/assignment/assignments_screen.dart';
import 'package:lms_app/screens/dashboard_screen.dart';
import 'package:lms_app/screens/my_grades_screen.dart';
import 'package:lms_app/screens/schedule_screen.dart';
import 'package:lms_app/screens/video_lessons_screen.dart';
import 'package:lms_app/widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  final int initialTab;
  const MainScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const VideoLessonsScreen(),
    const AssignmentsScreen(),
    const MyGradesScreen(),
    const ScheduleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
