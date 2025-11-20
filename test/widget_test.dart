// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

import 'package:lms_app/main.dart';
import 'package:lms_app/logic/auth/auth_cubit.dart';
import 'package:lms_app/core/repositories/auth_repository.dart';
import 'package:lms_app/core/services/auth_api_service.dart';
import 'package:lms_app/presentation/navigation/app_router.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  // Build our app and trigger a frame.
  // Provide the required constructor args for MyApp (authCubit and router)
  final authRepository = AuthRepository();
  final authApiService = AuthApiService(authRepository);
  final authCubit = AuthCubit(authRepository, authApiService);
  final appRouter = AppRouter(authCubit);

  await tester.pumpWidget(MyApp(
    authCubit: authCubit,
    router: appRouter.router,
    dio: Dio(BaseOptions(baseUrl: 'http://10.0.2.2:5000')),
    authRepository: authRepository,
  ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
