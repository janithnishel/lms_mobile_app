// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:lms_app/logic/auth/auth_cubit.dart';
// import 'package:lms_app/widgets/custom_text_form_field.dart';

// class RegistrationScreen extends StatefulWidget {
//   const RegistrationScreen({Key? key}) : super(key: key);

//   @override
//   State<RegistrationScreen> createState() => _RegistrationScreenState();
// }

// class _RegistrationScreenState extends State<RegistrationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   bool _isPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   void _createAccount() {
//     if (_formKey.currentState!.validate()) {
//       // 2. 💡 Confirm Password Check (Client-Side Validation)
//       if (_passwordController.text != _confirmPasswordController.text) {
//         // Passwords match කරන්නේ නැත්නම් error එකක් පෙන්වන්න
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Passwords do not match!'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return; // Stop the function execution
//       }
//       context.read<AuthCubit>().completeRegistration(
//         _usernameController.text, // 👈 Username argument එක යැවීම
//         _passwordController.text, // 👈 Password argument එක යැවීම
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE8F5F3),
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
//                       'Create Account',
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
//                       'Join our learning community today',
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
//                           color: Colors.teal,
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 32),

//                     // Username Field
//                     CustomTextField(
//                       controller: _usernameController,
//                       label: 'Username',
//                       hintText: 'Choose a username',
//                       prefixIcon: Icons.person_outline,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter a username';
//                         }
//                         if (value.length < 3) {
//                           return 'Username must be at least 3 characters';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),

//                     // Password Field
//                     CustomTextField(
//                       controller: _passwordController,
//                       label: 'Password',
//                       hintText: 'Create a strong password',
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
//                           return 'Please enter a password';
//                         }
//                         if (value.length < 6) {
//                           return 'Password must be at least 6 characters';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),

//                     // Confirm Password Field
//                     CustomTextField(
//                       controller: _confirmPasswordController,
//                       label: 'Confirm Password',
//                       hintText: 'Confirm your password',
//                       prefixIcon: Icons.lock_outline,
//                       isPassword: true,
//                       isPasswordVisible: _isConfirmPasswordVisible,
//                       onTogglePasswordVisibility: () {
//                         setState(() {
//                           _isConfirmPasswordVisible =
//                               !_isConfirmPasswordVisible;
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please confirm your password';
//                         }
//                         if (value != _passwordController.text) {
//                           return 'Passwords do not match';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 32),

//                     // Create Account Button
//                     ElevatedButton(
//                       onPressed: _createAccount,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.teal,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: const Text(
//                         'Create Account',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // Divider
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Divider(color: Colors.grey[300], thickness: 1),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: Text(
//                             'Already have an account?',
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

//                     // Sign In Link
//                     TextButton(
//                       onPressed: () {
//                         context.goNamed('login');
//                       },
//                       child: const Text(
//                         'Sign In Instead',
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.teal,
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
import 'package:lms_app/logic/auth/auth_state.dart'; // 💡 මෙය අත්‍යවශ්‍යයි
import 'package:lms_app/widgets/custom_text_form_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _createAccount() {
    if (_formKey.currentState!.validate()) {
      // 💡 Password Match Check එක Validator එකෙන් handle වෙනවා
      context.read<AuthCubit>().completeRegistration( // ⚠️ completeRegistration වෙනුවට register යැයි උපකල්පනය කරමි
            _usernameController.text.trim(), 
            _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F3),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // 1. ✅ Registration Success Logic
          // 💡 Cubit එකේදී Registration සාර්ථක වූ පසු, සාමාන්‍යයෙන් Success Message එක 
          // `errorMessage` ලෙස දමා `AuthStatus.unauthenticated` Emit කරයි.
          if (state.status == AuthStatus.unauthenticated && 
              state.errorMessage != null &&
              state.errorMessage!.contains('successful')) { // ⬅️ Success Message එක contain වෙනවාද බලන්න
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!), // ⬅️ Success Message එක පෙන්වන්න
                backgroundColor: Colors.teal,
                duration: const Duration(seconds: 3),
              ),
            );
            // Login Page එකට යැවීම
            context.goNamed('login');
          } 
          
          // 2. ❌ Error Logic (සාමාන්‍ය Error එකක් නම්)
          else if (state.status == AuthStatus.unauthenticated && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registration Failed: ${state.errorMessage!}'),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          
          // 💡 Note: AuthCubit එකේ `register` method එක අවසානයේදී `errorMessage` එක `null` වෙත යළි සකසනවාදැයි බැලීම හොඳයි.
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
                        const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        const Text('Join our learning community today', style: TextStyle(fontSize: 15, color: Colors.black54), textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Center(child: Container(width: 60, height: 3, decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(2)))),
                        const SizedBox(height: 32),

                        // Username Field (unchanged)
                        CustomTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hintText: 'Choose a username',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter a username';
                            if (value.length < 3) return 'Username must be at least 3 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field (unchanged)
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: 'Create a strong password',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          onTogglePasswordVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter a password';
                            if (value.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password Field (unchanged)
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hintText: 'Confirm your password',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          isPasswordVisible: _isConfirmPasswordVisible,
                          onTogglePasswordVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please confirm your password';
                            if (value != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // 🔑 Create Account Button (Loader/Disable Logic)
                        ElevatedButton(
                          // 💡 Loading නම් Button එක Disable කරන්න.
                          onPressed: isLoading ? null : _createAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
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
                                  'Create Account',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                        const SizedBox(height: 24),

                        // Divider (unchanged)
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Already have an account?', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Sign In Link
                        TextButton(
                          onPressed: isLoading ? null : () {
                            context.goNamed('login');
                          },
                          child: const Text('Sign In Instead', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.teal)),
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