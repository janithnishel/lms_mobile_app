// Import necessary packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_app/logic/auth/auth_cubit.dart';
// Import the Auth State file
import 'package:lms_app/logic/auth/auth_state.dart';
// Path for Custom Text Field has been corrected (previously in shared folder).
import 'package:lms_app/widgets/shared/custom_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Note: Password visibility is handled inside CustomTextField, so this is no longer needed.
  // bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method to send login call to Cubit
  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      // 1. Remove any previous error message
      // Logic to set errorMessage to null in the Cubit state during login method too.

      // 2. Send login call
      context.read<AuthCubit>().login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      // ⚠️ Note: Navigation should be handled by the BlocListener/BlocConsumer based on AuthState changes.
      // context.goNamed('home'); is removed here.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using BlocConsumer to listen for state changes and build UI
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF7),
      body: BlocConsumer<AuthCubit, AuthState>(
        // Listening to state changes (for navigation and snackbar display)
        listener: (context, state) {
          // Hide any previous SnackBar if present
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // 1. Login Success Logic
          if (state.status == AuthStatus.authenticated) {
            // Show success message while redirecting to Home with GoRouter
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful! Redirecting to dashboard.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            // If navigation is done through GoRouter redirect logic (router.go)
            // No need to call navigation from here.
            // But if no GoRouter redirect logic, use context.goNamed('home') here.
          }
          // 2. Error Logic (if unauthenticated and there is an error message)
          else if (state.status == AuthStatus.unauthenticated &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login Failed: ${state.errorMessage!}'),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        // UI building
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

          // For showing error text if login attempt failed
          final loginErrorText =
              state.status == AuthStatus.unauthenticated &&
                  state.errorMessage != null
              ? 'Invalid username or password.'
              : null; // To pass to errorText prop of CustomTextField

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title and Subtitle (unchanged)
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to access your learning dashboard',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Container(
                            width: 60,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Username Field (Props Changed)
                        CustomTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hint:
                              'Enter your username', // hint instead of hintText
                          icon:
                              Icons.person_outline, // icon instead of prefixIcon
                          // To show error message when login attempt fails
                          errorText: loginErrorText,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your username'
                              : null,
                          // Use onChanged to clear error state
                          onChanged: (_) {
                            if (state.errorMessage != null) {
                              context.read<AuthCubit>().clearError();
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field (Props Changed)
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint:
                              'Enter your password', // hint instead of hintText
                          icon: Icons.lock_outline, // icon instead of prefixIcon
                          isPassword: true,
                          // isPasswordVisible and onTogglePasswordVisibility are removed.
                          // To show error message when login attempt fails
                          errorText: loginErrorText,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your password'
                              : null,
                          // Use onChanged to clear error state
                          onChanged: (_) {
                            if (state.errorMessage != null) {
                              context.read<AuthCubit>().clearError();
                            }
                          },
                        ),
                        const SizedBox(height: 24),

                        // Sign In Button (Loader/Disable Logic)
                        ElevatedButton(
                          // Disable button if loading.
                          onPressed: isLoading ? null : _submitLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Sign In to Dashboard',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),

                        // Other elements (unchanged)
                        Center(
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    /* Navigate to forgot password */
                                  },
                            child: const Text(
                              'Forgot your password?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'New to EduFlow?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.goNamed('register'),
                          child: const Text(
                            'Create New Account',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
