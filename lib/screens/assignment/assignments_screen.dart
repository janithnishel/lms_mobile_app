import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// ⭐️ New Import: AuthRepository for token access
import 'package:lms_app/core/repositories/auth_repository.dart';
import 'package:lms_app/core/services/quiz_repository.dart';
import 'package:lms_app/logic/assignments/assignments_cubit.dart';
import 'package:lms_app/logic/assignments/assignments_state.dart';
import 'package:lms_app/models/exam_paper_card_model.dart';
import 'package:lms_app/utils/colors.dart';
import 'package:lms_app/widgets/assignments_screen/exam_paper_card.dart';
import 'package:lms_app/widgets/assignments_screen/exam_stats_card.dart';
import 'package:lms_app/widgets/shared/custom_app_bar.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ⭐️ 1. Using FutureBuilder to load the Auth Token asynchronously
    return FutureBuilder<String?>(
      // 🔑 Reads the token using the readToken() method in AuthRepository
      future: AuthRepository().readToken(),
      builder: (context, snapshot) {
        // 1. Loading State: Shown until the token is loaded
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Token Handling
        final String? authToken = snapshot.data;

        // ❌ Error: If the token is not found or is null
        if (authToken == null || authToken.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  '⚠️ Authorization Error: Login token not found. Please login again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        // ⭐️ 3. Loaded State: Creates the BLoC Provider after the token is received
        return BlocProvider(
          create: (context) => AssignmentsCubit(
            // 🔑 Injects the actual token into QuizRepository! (Resolves the Invalid Token error)
            QuizRepository(authToken),
          )..loadAssignments(),
          // 💡 Uses the previous UI as the AssignmentListBody within the BLoC Provider
          child: const AssignmentListBody(),
        );
      },
    );
  }
}

// 💡 4. Separating the Assignment UI Logic into a new Widget (AssignmentListBody)
// 💡 The body part of the Scaffold from the previous AssignmentsScreen has been moved here.
// Modify to support tabs
class AssignmentListBody extends StatefulWidget {
  const AssignmentListBody({super.key});

  @override
  State<AssignmentListBody> createState() => _AssignmentListBodyState();
}

class _AssignmentListBodyState extends State<AssignmentListBody> {
  // Tab management state
  String activeTab = 'not-answered'; // 'not-answered', 'answered', 'expired'
  String paperTypeFilter = 'all'; // 'all', 'mcq', 'structure' - default to all to show all papers

  // Helper method to calculate exam statistics
  Map<String, dynamic> _calculateExamStats(List<ExamPaperCardModel> papers, List<String> attemptedPapers) {
    // Calculate stats based on paper type filter
    final int totalPapers = papers.length;
    final int notAnsweredPapers = papers
        .where((p) => !attemptedPapers.contains(p.id) && !_isExpired(p))
        .length;
    // Completed papers: papers that the student has attempted
    final int completedPapers = attemptedPapers.where((id) => papers.any((p) => p.id == id)).length;
    final int expiredPapers = papers
        .where((p) => _isExpired(p))
        .length;

    return {
      'totalPapers': totalPapers,
      'notAnsweredPapers': notAnsweredPapers,
      'completedPapers': completedPapers,
      'expiredPapers': expiredPapers,
    };
  }

  // Helper method to build the common header section
  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assignment,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Examination Hub',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Access your ICT A-Level examination papers',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.lightPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to my results screen
                  context.go('/results/my');
                },
                icon: const Icon(
                  Icons.emoji_events,
                  size: 18,
                  color: AppColors.lightBackground,
                ),
                label: const Text(
                  'My Results',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Beautiful MCQ/Structure Sliding Tab View
            _buildPaperTypeTabView(),
            const SizedBox(height: 30),
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search papers...',
                hintStyle: TextStyle(
                  color: AppColors.lightRing,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.lightRing,
                ),
                filled: true,
                fillColor: AppColors.lightBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.lightRing,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.lightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTab(
                    'Active',
                    'not-answered',
                    Icons.assignment_outlined,
                  ),
                  _buildTab(
                    'Completed',
                    'answered',
                    Icons.check_circle_outline,
                  ),
                  _buildTab('Expired', 'expired', Icons.schedule),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build stats cards section
  Widget _buildStatsCardsSection({
    required int totalPapers,
    required int activePapers,
    required int completedPapers,
    required int expiredPapers,
    required String paperTypeFilter,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ExamStatsCard(
                    title: 'Total Papers',
                    value: totalPapers.toString(),
                    icon: Icons.assignment,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ExamStatsCard(
                    title: 'Active Papers',
                    value: activePapers.toString(),
                    icon: Icons.access_time,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ExamStatsCard(
                    title: 'Completed Papers',
                    value: completedPapers.toString(),
                    icon: Icons.check_circle,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ExamStatsCard(
                    title: 'Expired Papers',
                    value: expiredPapers.toString(),
                    icon: Icons.schedule,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build papers list section
  Widget _buildPapersListSection(List<Widget> paperCards, String emptyMessage) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: paperCards.isEmpty
          ? SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Text(
                    emptyMessage,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
          : SliverList(
              delegate: SliverChildListDelegate(paperCards),
            ),
    );
  }

  // Helper method to determine active tab index
  int _getPaperTypeIndex() {
    switch (paperTypeFilter) {
      case 'mcq':
        return 0;
      case 'structure':
        return 1;
      default:
        return 0;
    }
  }

  // Helper method to handle paper type tab tap
  void _onPaperTypeTap(int index) {
    final String newFilter = index == 0 ? 'mcq' : 'structure';
    if (paperTypeFilter == newFilter) return;
    setState(() => paperTypeFilter = newFilter);
  }

  // Beautiful sliding indicator tab system (adapted from provided code)
  Widget _buildPaperTypeTabView() {
    // Define gorgeous gradients
    final Gradient activeGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8E2DE2), Color(0xFFff6a88)], // purple -> pink
    );

    final Gradient inactiveGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFb69cf4), Color(0xFFf7a6b8)], // softer toned
    );

    // Compact sizes to fix horizontal overlap and smaller button size
    final double width =
        MediaQuery.of(context).size.width *
        0.85; // Less width to prevent overlap
    final double btnWidth =
        (width - 8) / 2; // Smaller gap, more compact buttons
    final int selectedIndex = _getPaperTypeIndex();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSlidingButton(
          index: 0,
          width: btnWidth,
          label: 'MCQ',
          icon: Icons.quiz_outlined,
          isSelected: selectedIndex == 0,
          activeGradient: activeGradient,
          inactiveGradient: inactiveGradient,
        ),
        const SizedBox(width: 8), // Consistent gap
        _buildSlidingButton(
          index: 1,
          width: btnWidth,
          label: 'Structured',
          icon: Icons.article_outlined,
          isSelected: selectedIndex == 1,
          activeGradient: activeGradient,
          inactiveGradient: inactiveGradient,
        ),
      ],
    );
  }

  Widget _buildSlidingButton({
    required int index,
    required double width,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Gradient activeGradient,
    required Gradient inactiveGradient,
  }) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label tab',
      child: InkWell(
        onTap: () => _onPaperTypeTap(index),
        borderRadius: BorderRadius.circular(10),
        splashFactory: InkRipple.splashFactory,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: width,
          height: 40, // Smaller height for compact design
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ), // Slightly less padding
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
          decoration: BoxDecoration(
            gradient: isSelected ? activeGradient : inactiveGradient,
            borderRadius: BorderRadius.circular(10),
            // subtle border to separate when not selected
            border: isSelected
                ? null
                : Border.all(color: Colors.white.withOpacity(0.6), width: 1),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build tabs
  Widget _buildTab(String title, String tabId, IconData icon) {
    final bool isSelected = activeTab == tabId;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeTab = tabId),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.blue[600] : Colors.grey[600],
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.blue[600] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to check if a paper is expired
  bool _isExpired(ExamPaperCardModel paper) {
    final String display = paper.timeLeftDisplay;
    return display == 'Overdue'; // Based on the model logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: BlocBuilder<AssignmentsCubit, AssignmentsState>(
          builder: (context, state) {
            // -----------------------------------------------------------
            // 1. Loading State (BLoC Loading)
            // -----------------------------------------------------------
            if (state is AssignmentsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // --------------------------------------------------------------
            // 3. New AssignmentsWithStatusLoaded State (for tab filtering)
            // --------------------------------------------------------------

            if (state is AssignmentsWithStatusLoaded) {
              final allPapers = state.data.papers;
              final attemptedPapers = state.data.attemptedPapers;

              // Filter papers based on active tab AND paper type (double filtering)
              final List<ExamPaperCardModel> filteredPapers = allPapers.where((
                paper,
              ) {
                final isAnswered = attemptedPapers.contains(paper.id);
                final isExpired = _isExpired(paper);

                // Step 1: Filter by status tab
                final statusMatch = switch (activeTab) {
                  'not-answered' => !isAnswered && !isExpired,
                  'answered' => isAnswered,
                  'expired' => isExpired,
                  _ => true,
                };

                // Step 2: Filter by paper type (if not 'all')
                final typeMatch =
                    paperTypeFilter == 'all' ||
                    (paperTypeFilter == 'mcq' &&
                        paper.paperType.toUpperCase() == 'MCQ') ||
                    (paperTypeFilter == 'structure' &&
                        paper.paperType.toUpperCase() == 'STRUCTURE');

                // Both conditions must be true
                return statusMatch && typeMatch;
              }).toList();

              final List<Widget> paperCards = filteredPapers.map((paper) {
                return ExamPaperCard(paper: paper, currentTab: activeTab);
              }).toList();

              // Stats Calculations based on PAPER TYPE filter (dynamic)
              // Filter for paper type only (not status tab)
              final List<ExamPaperCardModel> paperTypeFilteredPapers = allPapers
                  .where((paper) {
                    return paperTypeFilter == 'all' ||
                        (paperTypeFilter == 'mcq' &&
                            paper.paperType.toUpperCase() == 'MCQ') ||
                        (paperTypeFilter == 'structure' &&
                            paper.paperType.toUpperCase() == 'STRUCTURE');
                  })
                  .toList();

              final stats = _calculateExamStats(paperTypeFilteredPapers, attemptedPapers);
              final int totalPapers = stats['totalPapers'] as int;
              final int notAnsweredPapers = stats['notAnsweredPapers'] as int;
              final int completedPapers = stats['completedPapers'] as int;
              final int expiredPapers = stats['expiredPapers'] as int;

              // Use the shared UI components instead of duplicating code
              return CustomScrollView(
                slivers: [
                  const CustomAppBar(),
                  _buildHeaderSection(),
                  _buildStatsCardsSection(
                    totalPapers: totalPapers,
                    activePapers: notAnsweredPapers,
                    completedPapers: completedPapers,
                    expiredPapers: expiredPapers,
                    paperTypeFilter: paperTypeFilter,
                  ),
                  _buildPapersListSection(paperCards, 'No papers in this category.'),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                ],
              );
            }

            // --------------------------------------------------------------
            // Fallback: Old AssignmentsLoaded State (for backward compatibility)
            // --------------------------------------------------------------
            if (state is AssignmentsLoaded) {
              final List<ExamPaperCardModel> papers = state.papers;

              final List<Widget> paperCards = papers.map((paper) {
                return ExamPaperCard(paper: paper, currentTab: 'all');
              }).toList();

              // Stats Calculations (Same Mock Logic for Live Data)
              final int availablePapers = papers.length;
              final int activePapers = papers
                  .where((p) => p.isAvailableToStart && !p.isCompleted)
                  .length;
              final int completedPapers = papers
                  .where((p) => p.isCompleted)
                  .length;

              final completedScores = papers
                  .where(
                    (p) => p.isCompleted && p.studentScorePercentage != null,
                  )
                  .map((p) {
                    final scoreString = p.studentScorePercentage!.replaceAll(
                      '%',
                      '',
                    );
                    return int.tryParse(scoreString) ?? 0;
                  })
                  .toList();

              final String averageScore = completedScores.isNotEmpty
                  ? '${(completedScores.reduce((a, b) => a + b) / completedScores.length).round()}%'
                  : '0%';

              // Use the shared UI components instead of duplicating code
              return CustomScrollView(
                slivers: [
                  const CustomAppBar(),
                  _buildHeaderSection(),
                  _buildStatsCardsSection(
                    totalPapers: availablePapers,
                    activePapers: activePapers,
                    completedPapers: completedPapers,
                    expiredPapers: 0, // Old state doesn't have expired count
                    paperTypeFilter: 'all', // For old state compatibility
                  ),
                  _buildPapersListSection(paperCards, 'No Exam Papers.'),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                ],
              );
            }

            // 4. Default Case (No papers/Initial state when not loading)
            return const Center(child: Text('No Exam Papers.'));
          },
        ),
      ),
    );
  }
}
