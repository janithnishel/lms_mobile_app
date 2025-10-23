import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_app/logic/auth/auth_cubit.dart';
import 'package:lms_app/logic/auth/auth_state.dart';
import 'package:lms_app/screens/assignment/quiz_screen.dart';
import 'package:lms_app/screens/auth/login_screen.dart';
import 'package:lms_app/screens/auth/register_screen.dart';
import 'package:lms_app/screens/home/home_screen.dart';
import 'package:lms_app/screens/onboarding/onboarding_screen_one.dart';
import 'package:lms_app/screens/splash/splash_screen.dart';

// 💡 සියලුම App Routes (Paths)
abstract class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const register = '/register';
  static const login = '/login';
  static const home = '/home';
  static const quiz = '/quiz';
}

class AppRouter {
  final GoRouter router;
  final AuthCubit authCubit;

  AppRouter(this.authCubit)
    : router = GoRouter(
        // ⚠️ Auth Cubit State එක වෙනස් වෙද්දී router එක update කරන්න
        refreshListenable: GoRouterRefreshStream(authCubit.stream),
        initialLocation: AppRoutes.splash,

        // 🔑 ප්‍රධාන Navigation Logic එක
        redirect: (BuildContext context, GoRouterState state) {
          final status = authCubit.state.status;
          final isOnboarded = authCubit.state.isOnboarded;
          final path = state.matchedLocation;

          // 💡 Login/Register Flow එක අතරතුර Splash Flash එක වැලක්වීමට
          // if (status == AuthStatus.loading &&
          //     (path == AppRoutes.login || path == AppRoutes.register)) {
          //   return null;
          // }

          // ------------------------------------------------------------------
          // 1. INITIAL/SPLASH (Token පරීක්ෂා කරනවා)
          // ------------------------------------------------------------------
          if (status == AuthStatus.initial) {
            // Token Check එක අවසන් වන තෙක් Splash Screen එකේම ඉන්න
            return path == AppRoutes.splash ? null : AppRoutes.splash;
          }

          // ------------------------------------------------------------------
          // 2. AUTHENTICATED (LOGGED IN)
          // ------------------------------------------------------------------
          if (status == AuthStatus.authenticated) {
            // 🔑 Home Screen එකට යවන්න (Home එකේ නම් එතනම ඉන්න)
            return path == AppRoutes.home ? null : AppRoutes.home;
          }

          if (status == AuthStatus.unauthenticated) {
            // 🎯 FIX: යම්කිසි හේතුවක් නිසා user දැනටමත් Onboarding, Register, හෝ Login Screen එකක සිටී නම්,
            // (උදාහරණ: Login Fail වීම නිසා) එතනින් වෙන තැනකට යවන්නේ නැහැ.
            final isAuthPath =
                path == AppRoutes.login || path == AppRoutes.register;
            final isOnboardingPath = path == AppRoutes.onboarding;

            if (isAuthPath || isOnboardingPath) {
              // ➡️ Login Failed නම්, Login Screen එකේම ඉන්නවා (නැවත Onboarding යන්නේ නැහැ)
              return null;
            }

            // 3A. User වෙනත් තැනක (Home වැනි ආරක්ෂිත තැනක) ඉඳලා Log Out උනා නම්

            // Onboarding බලලා නැත්නම් (New Device)
            if (!isOnboarded) {
              return AppRoutes.onboarding;
            }

            // Onboarding බලලා නම් (Registered User)
            return AppRoutes.login;
          }

          // 💡 වෙනත් කිසිදු තත්ත්වයකට අසුවන්නේ නැතිනම්, කිසිදු Redirect එකක් නැත.
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
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.quiz,
            name: 'quiz',
            builder: (context, state) => const QuizScreen(),
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
