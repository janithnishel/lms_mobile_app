import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_app/logic/auth/auth_cubit.dart';
import 'package:lms_app/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final instruction = [
  "You can navigate between questions using Next/Previous buttons",
  "Your answers are automatically saved every few seconds",
  "You can only submit this paper once",
  "The paper will auto-submit when time runs out",
  "You'll get warnings when time is running low",
];

//  get the paper details

final paperData = PaperDetailsData().paperDetailsDataList;

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
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
                  child: Icon(
                    FontAwesomeIcons.file,
                    color: Colors.blueAccent,
                    size: 35,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  "al introduction",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  "this is a first paper",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(height: 30),
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 3,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final data = paperData[index];

                  return buildDetailCard(
                    context,
                    data.boxColor,
                    data.contentColor,
                    data.icon,
                    data.title,
                    data.value,
                  );
                },
              ),
              SizedBox(height: 30),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Color(0xFFFFFBEB),
                  border: Border.all(color: Color(0xFFFEF08A)),
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

                      for (int i = 0; i < 5; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15, left: 2),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // ✅ Align icon to top
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(
                                  top: 8,
                                ), // 🔹 Slight tweak for perfect alignment
                                child: Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  instruction[i],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.3,
                                    color: Color(0xFFB45309),
                                    fontWeight: FontWeight.w400,
                                  ), // 🔹 height for spacing
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  // 🔑 AuthCubit එකේ logout() method එක call කිරීම
                  context.read<AuthCubit>().logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('LOGOUT (Test Only)'),
              ),

              SizedBox(height: 10),

              Spacer(),

              Row(
                children: [
                  for (int i = 0; i < 2; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: i == 1 ? 6 : 0,
                          right: i == 0 ? 6 : 0,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: i == 0
                                ? AppColors.lightBackground
                                : AppColors.lightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            i == 0
                                ? print("click")
                                : context.goNamed('quiz');

                        
                          },
                          child: i == 0
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_back, color: Colors.black),
                                    SizedBox(width: 10),
                                    Text(
                                      "Back to Papers",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                )
                              : Center(
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
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailCard(
    BuildContext context,
    Color boxColor,
    Color contentColor,
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: boxColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: contentColor),
            Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
            Text(
              value,
              style: TextStyle(
                color: contentColor,
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

class PaperDetailsModel {
  final Color boxColor;
  final Color contentColor;
  final IconData icon;
  final String title;
  final String value;

  PaperDetailsModel({
    required this.boxColor,
    required this.contentColor,
    required this.icon,
    required this.title,
    required this.value,
  });
}

class PaperDetailsData {
  final paperDetailsDataList = [
    PaperDetailsModel(
      boxColor: Color(0xFFEFF6FF),
      contentColor: Color(0xFF2563EB),
      icon: Icons.person_outline,
      title: "Questions",
      value: "1",
    ),
    PaperDetailsModel(
      boxColor: Color(0xFFECFDF5),
      contentColor: Color(0xFF059669),
      icon: Icons.timer,
      title: "Time Limit",
      value: "60 mins",
    ),
    PaperDetailsModel(
      boxColor: Color(0xFFFFF7ED),
      contentColor: Color(0xFFF97316),
      icon: Icons.calendar_today_outlined,
      title: "Due Date",
      value: "19/10/2025",
    ),
  ];
}
