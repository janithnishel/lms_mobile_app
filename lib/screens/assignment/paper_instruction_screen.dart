import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

// Core Imports:
import 'package:lms_app/logic/auth/auth_cubit.dart';
import 'package:lms_app/models/paper_intro_details_model.dart';
import 'package:lms_app/utils/colors.dart';

// 🔑 Model Imports - ⚠️ මේවා දැන් ඔබේ "models" folder එකෙන් load විය යුතුයි.
// Note: ExamPaperModel එක PaperIntroDetails model එක ඇතුළෙ භාවිත වෙන නිසා,
// ඒක මේ screen එකට import කරන්න අවශ්‍ය නැහැ.

// ----------------------------------------------------------------------
// 1. Data Models (Model Definitions ඉවත් කර ඇත - Type Duplication වැළැක්වීමට)
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------
// 2. Reusable Widget (DetailCard)
// ----------------------------------------------------------------------

/// Reusable widget for displaying an individual metric card in the grid.
// This DetailCard is also better to move to a separate widget file.
class DetailCard extends StatelessWidget {
  final DetailCardModel data;

  const DetailCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: data.boxColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(data.icon, color: data.contentColor),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            Text(
              data.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: data.contentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 3. Screen Widget (PaperInstructionScreen)
// ----------------------------------------------------------------------

class PaperInstructionScreen extends StatelessWidget {
  // 🔑 Non-nullable ලෙස වෙනස් කළා
  final PaperIntroDetailsModel details;

  const PaperInstructionScreen({super.key, required this.details});

  final List<String> instructions = const [
    "You can navigate between questions using Next/Previous buttons",
    "Your answers are automatically saved every few seconds",
    "You can only submit this paper once",
    "The paper will auto-submit when time runs out",
    "You'll get warnings when time is running low",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Paper Instructions'),
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => context.pop(), // Back to main screen
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: const Color.fromARGB(255, 215, 222, 247),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.file,
                    color: Colors.blueAccent,
                    size: 35,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  details.paperTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  details.paperDescription!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // --- Detail Grid ---
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: details.detailCards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final data = details.detailCards[index];
                  return DetailCard(data: data);
                },
              ),
              const SizedBox(height: 30),
              // --- Instructions Container ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFFFFBEB),
                  border: Border.all(color: const Color(0xFFFEF08A)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFF92400E),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Important Instructions",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Instruction List
                      ...instructions
                          .map(
                            (text) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 15,
                                left: 2,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Icon(
                                      Icons.circle,
                                      size: 6,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      text,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.3,
                                        color: Color(0xFFB45309),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ),
              // --- End Instructions Container ---
              const SizedBox(height: 20),

              // --- Logout Button (Test) ---
              ElevatedButton(
                onPressed: () {
                  // Cubit භාවිතා කරමින් Logout
                  context.read<AuthCubit>().logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('LOGOUT (Test Only)'),
              ),

              const SizedBox(height: 10),

              // --- Action Buttons ---
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          // 🔑 Back to Papers
                          Navigator.pop(context);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back, color: Colors.black),
                            SizedBox(width: 10),
                            Text(
                              "Back to Papers",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          // 🔑 Start Paper Button Logic: Quiz Screen එකට යන්න
                          context.goNamed(
                            'paperQuiz',
                            extra: details.paperId,
                          );
                        },
                        child: Text(
                          "Start Paper",
                          style: TextStyle(
                            color: AppColors.lightBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
