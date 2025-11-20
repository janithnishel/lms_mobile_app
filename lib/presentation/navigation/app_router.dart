// import 'dart:async';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_app/logic/auth/auth_cubit.dart';
import 'package:lms_app/logic/auth/auth_state.dart';
import 'package:lms_app/models/paper_intro_details_model.dart';
import 'package:lms_app/screens/assignment/paper_instruction_screen.dart';
import 'package:lms_app/screens/assignment/quiz_screen.dart';
import 'package:lms_app/screens/assignment/results_screen.dart';
import 'package:lms_app/screens/assignment/see_answers_screen.dart';
import 'package:lms_app/screens/assignment/structure_paper_screen.dart';
import 'package:lms_app/screens/auth/login_screen.dart';
import 'package:lms_app/screens/auth/register_screen.dart';
import 'package:lms_app/screens/onboarding/onboarding_screen_one.dart';
import 'package:lms_app/screens/splash/splash_screen.dart';
import 'package:lms_app/widgets/main_screen.dart';

// 💡 සියලුම App Routes (Paths)
abstract class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const register = '/register';
  static const login = '/login';
  static const mainscreen = '/mainscreen';
  static const paperInstruction = '/paperInstruction';
  static const paperQuiz = '/paperQuiz';
  static const structurePaper = '/structurePaper';
}

class AppRouter {
  final GoRouter router;
  final AuthCubit authCubit;

  AppRouter(this.authCubit)
    : router = GoRouter(
        // ⚠️ Auth Cubit State එක වෙනස් වෙද්දී router එක update කරන්න
        refreshListenable: GoRouterRefreshStream(authCubit.stream),
        initialLocation: AppRoutes.splash,
        // 🚨 DEBUGGING සඳහා මෙය සක්‍රිය කරන්න
        debugLogDiagnostics: true,

        // 🔑 ප්‍රධාන Navigation Logic එක
        redirect: (BuildContext context, GoRouterState state) {
          final status = authCubit.state.status;
          final isOnboarded = authCubit.state.isOnboarded;
          // state.matchedLocation යනු යාමට උත්සාහ කරන path එකයි.
          final path = state.matchedLocation;

          // ------------------------------------------------------------------
          // Routes ලයිස්තුව: Auth නොමැතිව යා හැකි Pages
          // ------------------------------------------------------------------
          final bool isPublicPath =
              path == AppRoutes.splash ||
              path == AppRoutes.onboarding ||
              path == AppRoutes.login ||
              path == AppRoutes.register;

          // ------------------------------------------------------------------
          // 1. INITIAL/SPLASH (Token පරීක්ෂා කරනවා)
          // ------------------------------------------------------------------
          if (status == AuthStatus.initial) {
            // Token Check එක අවසන් වන තෙක් Splash Screen එකේම ඉන්න
            return path == AppRoutes.splash ? null : AppRoutes.splash;
          }

          // ------------------------------------------------------------------
          // 2. AUTHENTICATED (LOGGED IN) - 🔑 FIX එක මෙතන
          // ------------------------------------------------------------------
          if (status == AuthStatus.authenticated) {
            // Logged in user කෙනෙක් Public (Splash, Login, Register, Onboarding) pages වලට යන්න උත්සාහ කරනවා නම්,
            // ඊට ඉඩ නොදී Home එකටම Redirect කරන්න.
            if (isPublicPath) {
              return AppRoutes.mainscreen;
            }

            // ➡️ allow going to all other routes (like Home, Quiz)
            return null;
          }

          // ------------------------------------------------------------------
          // 3. UNAUTHENTICATED (LOGGED OUT)
          // ------------------------------------------------------------------
          if (status == AuthStatus.unauthenticated) {
            // User Public Path එකක (Login, Onboarding) නම්, එතනම ඉන්න ඉඩ දෙන්න
            if (isPublicPath) {
              // නමුත් Splash වලින් ඉවත් කළ යුතුයි
              if (path == AppRoutes.splash) {
                // if Onboarding not seen, send to Onboarding
                return isOnboarded ? AppRoutes.login : AppRoutes.onboarding;
              }
              return null; // Login/Register/Onboarding වලට ඉඩ දෙන්න
            }

            // User ආරක්ෂිත (Protected) තැනක (Home, Quiz) නම්, Redirect කරන්න
            // Onboarding බලලා නැත්නම් (New Device)
            if (!isOnboarded) {
              return AppRoutes.onboarding;
            }

            // Onboarding බලලා නම් (Registered User)
            return AppRoutes.login;
          }

          // 💡 If no other condition matches, no redirect.
          return null;
        },
        // ------------------------------------------------------------------
        // 4. ROUTE DEFINITIONS
        // ------------------------------------------------------------------
        routes: [
          GoRoute(
            path: AppRoutes.splash,
            name: 'splash',
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: AppRoutes.onboarding,
            name: 'onboarding',
            builder: (context, state) => const OnboardingScreen(),
          ),
          GoRoute(
            path: AppRoutes.register,
            name: 'register',
            builder: (context, state) => const RegistrationScreen(),
          ),
          GoRoute(
            path: AppRoutes.login,
            name: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: AppRoutes.mainscreen,
            name: 'mainscreen',
            builder: (context, state) {
              final int? initialTab = state.extra as int?;
              return MainScreen(initialTab: initialTab ?? 0);
            },
          ),

          GoRoute(
            path: AppRoutes.paperInstruction,
            name: 'paperInstruction',
            builder: (context, state) {
              // extra parameter එකෙන් PaperIntroDetails object එක retrieve කිරීම
              final PaperIntroDetailsModel details =
                  state.extra as PaperIntroDetailsModel;
              return PaperInstructionScreen(details: details);
            },
          ),
          GoRoute(
            path: AppRoutes.paperQuiz,
            name: 'paperQuiz',
            builder: (context, state) {
              final String paperId = state.extra as String;
              return QuizScreen(paperId: paperId);
            },
          ),
          GoRoute(
            path: AppRoutes.structurePaper,
            name: 'structurePaper',
            builder: (context, state) {
              return StructurePaperScreen();
            },
          ),
          GoRoute(
            path: '/results/:resultId',
            name: 'results',
            builder: (BuildContext context, GoRouterState state) {
              return const ResultsScreen();
            },
          ),

          GoRoute(
            path: '/see-answers/:paperId',
            name: 'see-answers',
            builder: (BuildContext context, GoRouterState state) {
              final paperId = state.pathParameters['paperId'] ?? '';
              final extra = state.extra;

              if (paperId.isEmpty) {
                return const Scaffold(
                  body: Center(
                    child: Text('Error: Paper ID missing for review.'),
                  ),
                );
              }

              // Handle different types of extra data
              if (extra is Map<String, dynamic>) {
                // If we have attempt data, use the full constructor
                // --- FIX: Robust Paper Title Extraction Logic ---
                String title = 'Review Answers';

                // 1. Check for 'paperTitle' key (simplest case)
                if (extra['paperTitle'] is String &&
                    (extra['paperTitle'] as String).isNotEmpty) {
                  title = extra['paperTitle'] as String;
                }
                // 2. Check for 'paperId' or 'paper' object and extract its title
                else {
                  final paperObj = extra['paperId'] ?? extra['paper'];
                  if (paperObj is Map &&
                      paperObj['title'] is String &&
                      (paperObj['title'] as String).isNotEmpty) {
                    title = paperObj['title'] as String;
                  }
                }

                return SeeAnswersScreen(
                  attemptData: extra,
                  paperId: paperId,
                  paperTitle: title,
                );
              } else if (extra is String && extra.isNotEmpty) {
                // If we have paperTitle as a string in extra, use the new constructor
                return SeeAnswersScreen.fromPaperIdWithTitle(
                  paperId: paperId,
                  paperTitle: extra,
                );
              } else {
                // If no extra data, use the original constructor that fetches it
                return SeeAnswersScreen.fromPaperId(paperId: paperId);
              }
            },
          ),
        ],
      );
}

// Cubit/Bloc State changes වලට GoRouter එකට සවන් දීමට අවශ්‍ය Class එක
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    // State changes වලට සවන් දී router එකට දැනුම් දෙයි.
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
