import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'logic/auth/auth_cubit.dart';
import 'data/repositories/auth_repository.dart';
import 'data/services/auth_api_service.dart';
import 'presentation/navigation/app_router.dart';

//  App starting logic put inside the main()

void main() {
  //need to Widgets binding and initialize because use SharedPrefs
  WidgetsFlutterBinding.ensureInitialized();

  // create the AuthRepository for Token Management
  final authRepository = AuthRepository();

  // create the AuthApiService and parse the AuthRepository as a argument
  final authApiService = AuthApiService(authRepository);

  // create the AuthCubit
  final authCubit = AuthCubit(authRepository, authApiService);

  // Start the GoRouter redirection logic and check the Auth Status
  authCubit.checkAuthStatus();

  // create the GoRouter instance
  final appRouter = AppRouter(authCubit);

  runApp(MyApp(authCubit: authCubit, router: appRouter.router));
}

class MyApp extends StatelessWidget {
  final AuthCubit authCubit;
  final GoRouter router;

  //parse the Cubit and Router to the Constructor
  const MyApp({super.key, required this.authCubit, required this.router});

  @override
  Widget build(BuildContext context) {
    // inject the AuthCubit and BlocProvider.
    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Splash → Onboarding Demo',
        routerConfig: router,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        themeMode: ThemeMode.system,
      ),
    );
  }
}
