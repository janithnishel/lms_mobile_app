// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:lms_app/logic/auth/auth_cubit.dart';
// import 'package:lms_app/widgets/custom_text_form_field.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   bool _isPasswordVisible = false;

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _signIn(dynamic passwordController, dynamic usernameController) {
//     if (_formKey.currentState!.validate()) {
//       context.read<AuthCubit>().login(
//         usernameController.text,
//         passwordController.text,
//       );

//       // Navigate to Home page
//       context.goNamed('home');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE8EEF7),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Container(
//               constraints: const BoxConstraints(maxWidth: 450),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 20,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(32),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Title
//                     const Text(
//                       'Welcome Back',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),

//                     // Subtitle
//                     const Text(
//                       'Sign in to access your learning dashboard',
//                       style: TextStyle(fontSize: 15, color: Colors.black54),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),

//                     // Underline
//                     Center(
//                       child: Container(
//                         width: 60,
//                         height: 3,
//                         decoration: BoxDecoration(
//                           color: Colors.blue,
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 32),

//                     // Username Field
//                     CustomTextField(
//                       controller: _usernameController,
//                       label: 'Username',
//                       hintText: 'Enter your username',
//                       prefixIcon: Icons.person_outline,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your username';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),

//                     // Password Field
//                     CustomTextField(
//                       controller: _passwordController,
//                       label: 'Password',
//                       hintText: 'Enter your password',
//                       prefixIcon: Icons.lock_outline,
//                       isPassword: true,
//                       isPasswordVisible: _isPasswordVisible,
//                       onTogglePasswordVisibility: () {
//                         setState(() {
//                           _isPasswordVisible = !_isPasswordVisible;
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your password';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 24),

//                     // Sign In Button
//                     ElevatedButton(
//                       onPressed: () =>
//                           _signIn(_passwordController, _usernameController),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: const Text(
//                         'Sign In to Dashboard',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // Forgot Password Link
//                     Center(
//                       child: TextButton(
//                         onPressed: () {
//                           // Navigate to forgot password
//                         },
//                         child: const Text(
//                           'Forgot your password?',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.blue,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Divider
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Divider(color: Colors.grey[300], thickness: 1),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: Text(
//                             'New to EduFlow?',
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: Divider(color: Colors.grey[300], thickness: 1),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),

//                     // Create Account Link
//                     TextButton(
//                       onPressed: () {
//                         context.goNamed('register');
//                       },
//                       child: const Text(
//                         'Create New Account',
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_app/logic/auth/auth_cubit.dart';
import 'package:lms_app/logic/auth/auth_state.dart'; // 💡 මෙය අලුතින් අවශ්‍යයි
import 'package:lms_app/widgets/custom_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🔑 Cubit වෙතට Login Call එක යවන Method එක
  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
            _usernameController.text.trim(), // trim() භාවිත කරන්න
            _passwordController.text.trim(),
          );
      // ⚠️ Note: Login සාර්ථක වුවහොත් Home එකට Redirect කිරීම GoRouter Redirect Logic එක මඟින් සිදු වේ.
      // මෙතැනදී context.goNamed('home'); ඉවත් කළ යුතුය.
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔑 BlocConsumer මගින් State වෙනස්වීම්වලට සවන් දීම සහ UI ගොඩනැගීම
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF7),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          // ⚠️ පෙර තිබූ SnackBar එකක් ඇත්නම් ඉවත් කරන්න
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // 1. ✅ Login Success Logic
          if (state.status == AuthStatus.authenticated) {
            // GoRouter Home එකට Redirect කරන අතරේ Success Message එක පෙන්වීම
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful! Redirecting to dashboard.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } 
          
          // 2. ❌ Error Logic (unauthenticated වූ විට error message එකක් තිබේ නම්)
          else if (state.status == AuthStatus.unauthenticated && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login Failed: ${state.errorMessage!}'),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          // 💡 Loading තත්ත්වය පරීක්ෂා කිරීම
          final isLoading = state.status == AuthStatus.loading;

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
                        const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        const Text('Sign in to access your learning dashboard', style: TextStyle(fontSize: 15, color: Colors.black54), textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Center(child: Container(width: 60, height: 3, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(2)))),
                        const SizedBox(height: 32),

                        // Username Field (unchanged)
                        CustomTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hintText: 'Enter your username',
                          prefixIcon: Icons.person_outline,
                          validator: (value) => value == null || value.isEmpty ? 'Please enter your username' : null,
                        ),
                        const SizedBox(height: 20),

                        // Password Field (unchanged)
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          onTogglePasswordVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
                        ),
                        const SizedBox(height: 24),

                        // 🔑 Sign In Button (Loader/Disable Logic)
                        ElevatedButton(
                          // 💡 Loading නම් Button එක Disable කරන්න.
                          onPressed: isLoading ? null : _submitLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                        const SizedBox(height: 20),

                        // Forgot Password Link (unchanged)
                        Center(
                          child: TextButton(
                            onPressed: isLoading ? null : () {
                              // Navigate to forgot password
                            },
                            child: const Text('Forgot your password?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Divider (unchanged)
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('New to EduFlow?', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Create Account Link
                        TextButton(
                          onPressed: isLoading ? null : () {
                            context.goNamed('register');
                          },
                          child: const Text('Create New Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.blue)),
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