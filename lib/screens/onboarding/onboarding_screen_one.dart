// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../state/auth/auth_cubit.dart';

// class OnboardingView extends StatefulWidget {
//   const OnboardingView({super.key});

//   @override
//   State<OnboardingView> createState() => _OnboardingViewState();
// }

// class _OnboardingViewState extends State<OnboardingView> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   final int _pageCount = 2;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     // Skip/Get Started Logic
//     void handleNavigation() {
//       // 1. Cubit update:
//       // 💡 මෙය isRegistered = true කරයි
//       context.read<AuthCubit>().setOnboardingSeen();

//       // 2. Register Page එකට යන්න. (router.dart එකේ 'register' name එක තිබිය යුතුය)
//       context.goNamed('register');
//     }

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // ------------------ 1. Skip Button Area ------------------
//             Padding(
//               padding: const EdgeInsets.only(top: 16.0, right: 24.0),
//               child: Align(
//                 alignment: Alignment.topRight,
//                 child: TextButton(
//                   onPressed: handleNavigation, // Skip කිරීමත් Registration වෙත යයි
//                   child: Text(
//                     'Skip',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       color: theme.colorScheme.onBackground.withOpacity(0.6),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // ------------------ 2. Main Page View (Swipe Area) ------------------
//             Expanded(
//               child: PageView(
//                 controller: _pageController,
//                 onPageChanged: (index) {
//                   setState(() {
//                     _currentPage = index;
//                   });
//                 },
//                 children: const [
//                   // 1. Onboarding Screen 1
//                   _OnboardingPage(
//                     title: 'EduFlow: Begin Your Learning Adventure',
//                     subtitle: 'Dive into our specialized ICT Learning Hub and start mastering programming and theoretical concepts.',
//                     imageAsset: Icons.lightbulb_outline,
//                   ),

//                   // 2. Onboarding Screen 2
//                   _OnboardingPage(
//                     title: 'Unlock Your ICT A-Level Potential',
//                     subtitle: 'Join our vibrant community and unlock access to programming tutorials, structured assignments, and focused exam preparation resources.',
//                     imageAsset: Icons.school_outlined,
//                   ),
//                 ],
//               ),
//             ),

//             // ------------------ 3. Dots and Navigation Buttons ------------------
//             Padding(
//               padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Dot Indicators
//                   Row(
//                     children: List.generate(_pageCount, (index) {
//                       return AnimatedContainer(
//                         duration: const Duration(milliseconds: 300),
//                         margin: const EdgeInsets.symmetric(horizontal: 4),
//                         height: 10,
//                         width: _currentPage == index ? 24 : 10,
//                         decoration: BoxDecoration(
//                           color: _currentPage == index
//                               ? theme.colorScheme.primary
//                               : theme.colorScheme.secondaryContainer, // SecondaryContainer is usually better for dark/light mode
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                       );
//                     }),
//                   ),

//                   // Next/Get Started Button
//                   ElevatedButton(
//                     onPressed: () {
//                       if (_currentPage < _pageCount - 1) { // 1 වෙනුවට _pageCount - 1 යොදන්න
//                         // Next Page එකට Swipe කරන්න
//                         _pageController.nextPage(
//                           duration: const Duration(milliseconds: 400),
//                           curve: Curves.easeIn,
//                         );
//                       } else {
//                         // අවසාන Page එකේ නම්, Register Page එකට යන්න
//                         handleNavigation();
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                     ),
//                     child: Text(_currentPage == _pageCount - 1 ? 'Get Started' : 'Next'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ----------------------------------------------------
// // Custom Widget for Onboarding Page Content
// // ----------------------------------------------------

// class _OnboardingPage extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData imageAsset;

//   const _OnboardingPage({
//     required this.title,
//     required this.subtitle,
//     required this.imageAsset,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final size = MediaQuery.of(context).size;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Illustration Area
//           Container(
//             height: size.height * 0.4,
//             width: size.width * 0.8,
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primaryContainer, // PrimaryContainer is often a good background color
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Center(
//               child: Icon(imageAsset, size: 100, color: theme.colorScheme.primary),
//             ),
//           ),

//           const SizedBox(height: 50),

//           // Title
//           Text(
//             title,
//             style: theme.textTheme.headlineMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: theme.colorScheme.onBackground,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),

//           // Description
//           Text(
//             subtitle,
//             style: theme.textTheme.bodyLarge?.copyWith(
//               color: theme.colorScheme.onBackground.withOpacity(0.7),
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_app/logic/auth/auth_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      icon: Icons.lightbulb_outline,
      title: 'Begin Your\nLearning Adventure',
      description:
          'Dive into our specialized ICT Learning Hub and start mastering programming and theoretical concepts.',
      gradientColors: [const Color(0xFF6B5CE7), const Color(0xFF8B7FE8)],
    ),
    OnboardingData(
      icon: Icons.school_outlined,
      title: 'Unlock Your ICT A-Level\nPotential',
      description:
          'Join our vibrant community and unlock access to programming tutorials, structured assignments, and focused exam preparation resources.',
      gradientColors: [const Color(0xFF5B7CE7), const Color(0xFF7B9CE8)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _handleNavigation();
    }
  }

  void _skip() {
    _handleNavigation();
  }

  void _handleNavigation() {
    // 1. Cubit update:
    // 💡 මෙය isRegistered = true කරයි
    context.read<AuthCubit>().completeOnboarding();

    // 2. Register Page එකට යන්න. (router.dart එකේ 'register' name එක තිබිය යුතුය)
    context.goNamed('register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _onboardingData[index]);
                },
              ),
            ),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF6B5CE7)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next/Get Started Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6B5CE7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container with Gradient
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            height: MediaQuery.of(context).size.width * 0.75,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  data.gradientColors[0].withOpacity(0.15),
                  data.gradientColors[1].withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: data.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: data.gradientColors[0].withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(data.icon, size: 60, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            data.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
  });
}
