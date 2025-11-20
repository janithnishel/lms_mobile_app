import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_app/core/repositories/auth_repository.dart';
import 'package:lms_app/core/services/quiz_repository.dart';
import 'package:lms_app/logic/quiz/quiz_cubit.dart';
import 'package:lms_app/logic/quiz/quiz_state.dart';
import 'package:lms_app/utils/colors.dart';
// Widgets
import 'package:lms_app/widgets/quiz_screen/bottom_navigation.dart';
import 'package:lms_app/widgets/quiz_screen/question_badge.dart';
import 'package:lms_app/widgets/quiz_screen/question_navigator_drawer.dart';
import 'package:lms_app/widgets/quiz_screen/question_option_tile.dart';
import 'package:lms_app/widgets/quiz_screen/time_display.dart';

// ----------------------------------------------------------------------
// ⭐️ QuizScreen Class
// ----------------------------------------------------------------------
class QuizScreen extends StatefulWidget {
  final String paperId;
  const QuizScreen({Key? key, required this.paperId}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final AuthRepository _authRepository = AuthRepository();

  String? _authToken;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    final String? token = await _authRepository.readToken();

    if (mounted) {
      setState(() {
        _authToken = token;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_authToken == null || _authToken!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text(
            'Authentication Error: Token is missing. Please log in again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => QuizCubit(
        paperId: widget.paperId,
        repository: QuizRepository(_authToken!),
      ),
      child: const _QuizView(),
    );
  }
}

// ---
// 💻 LMS-Style Time Banner (Continuous when <= 5 minutes, no blink)
// ---

class _LMSStyleTimeWarning extends StatefulWidget {
  const _LMSStyleTimeWarning({Key? key}) : super(key: key);

  @override
  State<_LMSStyleTimeWarning> createState() => _LMSStyleTimeWarningState();
}

class _LMSStyleTimeWarningState extends State<_LMSStyleTimeWarning>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Set up background blinking animation (standard LMS style)
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _colorAnimation =
        ColorTween(
          begin: const Color(0xFFFFF3CD), // Light warning yellow
          end: const Color(0xFFFFE066), // Brighter warning yellow
        ).animate(
          CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
        );

    _blinkController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFC107), width: 2),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning, color: Color(0xFFFF8F00), size: 24),
              const SizedBox(width: 12),
              Text(
                'WARNING: Less than 5 minutes remaining!',
                style: const TextStyle(
                  color: Color(0xFF8B4513),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 💻 _QuizView

class _QuizView extends StatefulWidget {
  const _QuizView();

  @override
  State<_QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<_QuizView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Cache for computed final image URLs per question index to avoid
  // recomputing and re-printing the URL on every rebuild.
  final Map<int, String> _imageUrlCache = {};

  // ⚠️ IMPORTANT: Set your server's base URL here!
  // Place your real server URL here
  final String _imageBaseUrl = 'http://10.0.2.2:5000';

  // Normalize image paths returned by the server so the client doesn't need
  // the backend to change. Handles cases where the API returns:
  // - absolute URLs (http...)
  // - "/api/uploads/..." (already correct)
  // - "/uploads/..." (replace -> "/api/uploads/...")
  // - "/paper-options/..." or "/explanations/..." (prefix with "/api/uploads")
  // - relative paths without leading slash
  String _normalizeImageUrl(String raw) {
    if (raw.isEmpty) return '';
    // Already absolute
    if (raw.startsWith('http')) return raw;

    String path = raw;

    if (path.startsWith('/api/uploads')) {
      return '$_imageBaseUrl$path';
    }

    if (path.startsWith('/uploads')) {
      // Replace leading /uploads with /api/uploads
      path = path.replaceFirst('/uploads', '/api/uploads');
      return '$_imageBaseUrl$path';
    }

    // If path starts with '/' but not /uploads or /api/uploads -> prefix /api/uploads
    if (path.startsWith('/')) {
      return '$_imageBaseUrl/api/uploads$path';
    }

    // No leading slash -> assume it's a relative path under uploads
    return '$_imageBaseUrl/api/uploads/$path';
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _indexToLetter(int index) {
    // Converts 0 to 'A', 1 to 'B', etc.
    return String.fromCharCode('A'.codeUnitAt(0) + index);
  }

  void _showSubmitConfirmationDialog(
    BuildContext context,
    int answeredCount,
    int totalQuestions,
  ) {
    final cubit = context.read<QuizCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Ready to Submit?')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You have answered $answeredCount out of $totalQuestions questions.',
            ),
            const SizedBox(height: 12),
            const Text(
              'This cannot be changed after submission.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.lightBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
          // Submit button (styled like "Start Paper")
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  cubit.submitPaper();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
            ],
          )
          // Cancel button (styled like "Back to Papers")
          
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuizCubit>();

    return BlocConsumer<QuizCubit, QuizState>(
      listener: (context, state) {
        if (state is QuizSubmissionSuccess) {
          // 1. 🔑 FIX: Getting result ID as Key from Map
          // Specify the name of the ID in your API Output here ('_id' or 'resultId' etc.)
          final String resultId =
              state.resultDetails['_id']?.toString() ?? 'unknown';

          // 2. 🔑 FIX: Using pathParameters to go to Route
          context.goNamed(
            'results', // Correct name in app_router.dart
            pathParameters: {'resultId': resultId}, // Sending Path Parameter
            extra: state.resultDetails, // Sending Result Object
          );
        }
        if (state is QuizFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
        }
      },
      builder: (context, state) {
        // 1. Loading State
        if (state is QuizLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Preparing the exam paper...',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        }

        // 2. Failure State
        if (state is QuizFailure) {
          return Scaffold(
            body: Center(
              child: Text('Error loading exam paper: ${state.error}'),
            ),
          );
        }

        // 3. Active State
        if (state is QuizActive) {
          final userState = state.userState;
          final currentQuestionIndex = userState.currentQuestionIndex;
          final currentQ = userState.questions[currentQuestionIndex];
          final totalQuestions = userState.questions.length;
          final answeredCount = userState.userAnswers.values
              .where((v) => v != null)
              .length;

          // 🔑 Get the question image URL
          final String? questionImageUrl = currentQ.questionImageUrl;

          final currentQuestionId = currentQ.questionId;
          final selectedAnswerId = userState.userAnswers[currentQuestionId];

          final Map<int, String?> indexedAnswers = {};

          for (int i = 0; i < totalQuestions; i++) {
            final qId = userState.questions[i].questionId;
            final selectedId = userState.userAnswers[qId];
            indexedAnswers[i] = selectedId != null ? 'answered' : null;
          }

          return Scaffold(
            key: _scaffoldKey,

            // Drawer for Question Navigation
            drawer: QuestionNavigatorDrawer(
              totalQuestions: totalQuestions,
              currentQuestion: currentQuestionIndex,
              answers: indexedAnswers,
              jumpToQuestion: cubit.jumpToQuestion,
              answeredCount: answeredCount,
            ),

            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.blue),
                onPressed: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
              ),
              title: Text(
                state.paperDetails.title,
                style: const TextStyle(color: Colors.black87),
              ),
              actions: [
                TimeDisplay(
                  timeRemaining: userState.timeRemainingSeconds,
                  formatTime: formatTime,
                ),
              ],
            ),

            body: Column(
                children: [
                  // --- LMS Time Warning: Show when 5 minutes or less remaining ---
                  if (userState.timeRemainingSeconds <= 300) ...[
                    const _LMSStyleTimeWarning(), // Static banner when < 5 minutes
                  ],

                  // --- Status Bar ---
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${currentQuestionIndex + 1} of $totalQuestions',
                      ),
                      Text('$answeredCount/$totalQuestions Answered'),
                    ],
                  ),
                ),

                // ----------------------------------------------------------
                // --- Question Content (Image Above Text) ---
                // ----------------------------------------------------------
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. 🖼️ Question Image (NOW at the very top, before the text)
                        if (questionImageUrl != null &&
                            questionImageUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Builder(
                                builder: (context) {
                                  // Compute a stable finalImageUrl and cache it per
                                  // question index so repeated rebuilds don't flood
                                  // the logs and repeatedly re-request the image.
                                  final raw = questionImageUrl;
                                  final int qIndex = currentQuestionIndex;
                                  final String finalImageUrl = _imageUrlCache
                                      .putIfAbsent(
                                        qIndex,
                                        () => _normalizeImageUrl(raw),
                                      );

                                  if (finalImageUrl.isNotEmpty) {
                                    // ignore: avoid_print
                                    print(
                                      'DEBUG: Loading question image -> $finalImageUrl',
                                    );
                                  }

                                  return SizedBox(
                                    height: 180,
                                    width: double.infinity,
                                    child: Image.network(
                                      finalImageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              height: 150,
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Text(
                                                  'Question Image not available',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        // 2. 📝 Question Number (Badge) and Text
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question Badge (1, 2, 3...)
                            QuestionBadge(
                              currentQuestion: currentQuestionIndex,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                currentQ.questionText,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- Options ---
                        ...currentQ.options.asMap().entries.map<Widget>((
                          entry,
                        ) {
                          final index = entry.key;
                          final option = entry.value;

                          return QuestionOptionTile(
                            option: {
                              'id': option.id,
                              'optionText': option.optionText,
                              'optionImageUrl': option.optionImageUrl,
                            },
                            optionLabel: _indexToLetter(index),
                            isSelected: selectedAnswerId == option.id,
                            // 🔑 FIX: answerQuestion function එකට Arguments 2ම යැවීම
                            onTap: (selectedOptionId) => cubit.answerQuestion(
                              currentQuestionId,
                              selectedOptionId, // 🛑 Missing Argument එක
                            ),
                            // 🔑 Passing the Base URL to Option Tile
                            imageBaseUrl: _imageBaseUrl,
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // --- Navigation Bar ---
                BottomNavigation(
                  currentQuestion: currentQuestionIndex,
                  totalQuestions: totalQuestions,
                  answeredCount: answeredCount,
                  nextQuestion: cubit.nextQuestion,
                  previousQuestion: cubit.previousQuestion,
                  showSubmitConfirmationDialog: () =>
                      _showSubmitConfirmationDialog(
                        context,
                        answeredCount,
                        totalQuestions,
                      ),
                ),
              ],
            ),
          );
        }

        // 4. Unknown State
        return const Scaffold(body: Center(child: Text('Unknown State')));
      },
    );
  }
}
