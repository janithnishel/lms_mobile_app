import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart'; // 💡 Dio Package
import 'package:lms_app/core/repositories/see_answers_repository.dart';
import 'package:lms_app/core/services/see_answers_api_service.dart';
import 'logic/auth/auth_cubit.dart';
import 'core/repositories/auth_repository.dart';
import 'core/services/auth_api_service.dart';
import 'presentation/navigation/app_router.dart';

// 💡 New Imports for SeeAnswers Feature

// ⚠️ මේ URL එක ඔබගේ Backend Server එකේ නිවැරදි Base URL එකට වෙනස් කරන්න.
const String API_BASE_URL = 'http://10.0.2.2:5000';

void main() {
  // Need to Widgets binding and initialize because use SharedPrefs (AuthRepository)
  WidgetsFlutterBinding.ensureInitialized();

  // --- 1. Core Services ---
  // Dio instance එක create කරලා, Base URL එක define කිරීම
  final dio = Dio(BaseOptions(baseUrl: API_BASE_URL));

  // --- 2. Auth Setup (Existing Logic) ---
  final authRepository = AuthRepository();
  final authApiService = AuthApiService(authRepository);
  final authCubit = AuthCubit(authRepository, authApiService);
  authCubit.checkAuthStatus();

  // --- 3. Router Setup (Existing Logic) ---
  final appRouter = AppRouter(authCubit);

  runApp(
    MyApp(
      authCubit: authCubit,
      router: appRouter.router,
      dio: dio, // Dio instance එක MyApp එකට pass කිරීම
      authRepository: authRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthCubit authCubit;
  final GoRouter router;
  final Dio dio; // Dio instance එක
  final AuthRepository authRepository;

  // Parse the Cubit, Router, and Dio to the Constructor
  const MyApp({
    super.key,
    required this.authCubit,
    required this.router,
    required this.dio,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    // 🚀 FIX: MultiRepositoryProvider එකෙන් Dio, API Service, සහ Repository provide කිරීම.
    return MultiRepositoryProvider(
      providers: [
        // Dio instance එක Global Access සඳහා Provide කිරීම
        RepositoryProvider<Dio>.value(value: dio),

        // SeeAnswersApiService (AuthRepository depend කර ගනී)
        RepositoryProvider<SeeAnswersApiService>(
          create: (context) => SeeAnswersApiService(authRepository),
        ),

        // SeeAnswersRepository (SeeAnswersApiService depend කර ගනී)
        RepositoryProvider<SeeAnswersRepository>(
          create: (context) =>
              SeeAnswersRepository(context.read<SeeAnswersApiService>()),
        ),

        // 💡 (Optional): AuthRepository එකත් Global access සඳහා Provide කරන්න පුළුවන්.
        // RepositoryProvider<AuthRepository>.value(value: AuthRepository()),
      ],
      // Inject the AuthCubit
      child: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'LMS App',
          routerConfig: router,
          theme: ThemeData(
            primarySwatch: Colors.teal,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          themeMode: ThemeMode.system,
        ),
      ),
    );
  }
}
