import 'dart:async'; // 💡 Timer එක සඳහා
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms_app/widgets/registration_screen/bullet_point.dart';
import 'package:lms_app/widgets/registration_screen/custom_stepper.dart';
import 'package:lms_app/widgets/registration_screen/id_card_upload.dart';
import 'package:permission_handler/permission_handler.dart';

// 💡 BLOC/CUBIT Imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_app/logic/auth/auth_cubit.dart';
import 'package:lms_app/logic/auth/auth_state.dart';

// Imports for your custom Widgets
import 'package:lms_app/widgets/registration_screen/primary_button.dart';
import 'package:lms_app/widgets/registration_screen/secondary_button.dart';
import 'package:lms_app/widgets/shared/custom_text_form_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _isLoading = false;

  final GlobalKey<FormState> _stepOneFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _stepTwoFormKey = GlobalKey<FormState>();

  // --- Form controllers ---
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _telegramController = TextEditingController();

  // 🛠️ ID Card Image State Variables
  String? _frontIDCardImage;
  String? _backIDCardImage;

  // --- State variables for logic ---
  String? _usernameError;
  bool _isUsernameChecking = false; // 💡 Loading Indicator එක සඳහා
  Timer? _debounce; // 🔑 Debouncing Timer එක

  String? _passwordStrength;
  Color _passwordStrengthColor = Colors.grey;
  bool _passwordsMatch = false;

  // 🛠️ Image Picker Instance
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 🔑 Username Field එකට listener එකක් දාන්න
    _usernameController.addListener(_onUsernameChanged);

    _passwordController.addListener(() {
      _checkPasswordStrength(_passwordController.text);
      _checkPasswordMatch(_confirmPasswordController.text);
    });
    _confirmPasswordController.addListener(
      () => _checkPasswordMatch(_confirmPasswordController.text),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel(); // 🔑 Timer එක Disposed කිරීම අත්‍යවශ්‍යයයි
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.removeListener(
      _onUsernameChanged,
    ); // 💡 Listener එක ඉවත් කිරීම
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------
  // 🔑 NEW ASYNC USERNAME VALIDATION LOGIC
  // --------------------------------------------------------

  // 💡 TextField එකේ text වෙනස් වන විට Call වන method එක
  void _onUsernameChanged() {
    _validateUsername(_usernameController.text);
  }

  // 🔑 Debounced Async Validation
  // A. _validateUsername(String username) method එක
  void _validateUsername(String username) {
    // Required Error Clear Logic.
    if (_usernameError == 'Username is required') {
      setState(() {
        _usernameError = null;
      });
    }

    // 1. --- Local Validation (Required/Length) ---
    if (username.isEmpty) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      setState(() {
        _usernameError = null;
        _isUsernameChecking = false;
      });
      return;
    }

    // Length Check: 4 Characters වලට වඩා අඩුවෙන් ඇත්නම්, OnChange Error Message එක සෙට් කරයි.
    if (username.length < 4) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      setState(() {
        _usernameError = 'Username must be at least 4 characters';
        _isUsernameChecking = false;
      });
      return;
    }
    // ... (අනෙක් API Check Logic එලෙසම තබන්න, එය 'Username is already taken' සෙට් කරයි.) ...
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() {
      /* ... */
    });
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      // 🛑 FIX: මෙන්න මේ line එක එකතු කරන්න.
      final bool isAvailable = await context
          .read<AuthCubit>()
          .checkUsernameAvailability(username);

      // 4. State එක Update කරන්න
      if (mounted) {
        setState(() {
          _isUsernameChecking = false;

          if (isAvailable) {
            // දැන් 'isAvailable' variable එක Define කරලා තියෙනවා.
            _usernameError = null; // ✅ Available
          } else {
            _usernameError = 'Username is already taken';
          }
        });
      }
    });
  }

  // --- Navigation & Validation ---
  GlobalKey<FormState>? _getCurrentFormKey() {
    if (_currentPage == 0) return _stepOneFormKey;
    if (_currentPage == 1) return _stepTwoFormKey;
    return null;
  }

  // 💡 RegistrationScreen State Class එක ඇතුළේ

  // C. _nextPage() method එක
  void _nextPage() {
    final currentFormKey =
        _getCurrentFormKey(); // ⚠️ ඔබගේ _getCurrentFormKey() method එක තිබිය යුතුය.
    bool isStepValidated = true;

    // 1. Form Validation Check
    if (currentFormKey != null && currentFormKey.currentState != null) {
      // CustomTextField තුළ ඇති validator() එක මෙහිදී run වේ.
      isStepValidated = currentFormKey.currentState!.validate();

      // Step 1 (Username) වලදී විශේෂ පරීක්ෂාව:
      // Form Validation (Required/Length) OK වූවත්, 'Taken' Error එකක් _usernameError තුළ තිබිය හැක.
      if (_currentPage == 0 && (isStepValidated && _usernameError != null)) {
        // Error එකක් set වී ඇත්නම්, Validation Fail ලෙස සලකයි.
        isStepValidated = false;
      }
    }

    // 2. Step 3 විශේෂ පරීක්ෂාව (ID Upload)
    // ⚠️ _frontIDCardImage සහ _backIDCardImage වැනි variables ඔබගේ class එකේ තිබිය යුතුය.
    if (_currentPage == 2) {
      // ID Cards දෙකම upload කර ඇත්දැයි පරීක්ෂා කිරීම.
      if (_frontIDCardImage == null || _backIDCardImage == null) {
        isStepValidated = false;
        // SnackBar Logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please upload both the front and back of the ID Card.',
            ),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }

    // 3. Navigation/Registration Logic
    if (isStepValidated) {
      // ✅ Validation OK නම්: ඊළඟ Page එකට යන්න.
      if (_currentPage < 2) {
        _pageController.animateToPage(
          // ⚠️ _pageController තිබිය යුතුය.
          _currentPage + 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // 🎯 Final Step: Registration සම්පූර්ණ කරන්න.
        _completeRegistration(); // ⚠️ _completeRegistration() method එක තිබිය යුතුය.
      }
    } else {
      // ❌ Validation Fail නම්: Error Message එක Overwrite කිරීම.

      // Next Button එක එබූ පසු, 'Username is already taken' error එක
      // 'Please choose a different username' බවට වෙනස් කිරීම.
      if (_currentPage == 0 && _usernameError == 'Username is already taken') {
        setState(() {
          _usernameError = 'Please choose a different username';
        });
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 🎯 යාවත්කාලීන කළ Registration Call එක
  void _completeRegistration() async {
    // 1. String? variables වල Null Check එක:
    if (_frontIDCardImage == null || _backIDCardImage == null) {
      return;
    }

    // 2. 🎯 FIX: String Path එක File Object බවට Convert කිරීම
    // _frontIDCardImage සහ _backIDCardImage දැන් String? වන නිසා.
    final File frontImageFile = File(_frontIDCardImage!);
    final File backImageFile = File(_backIDCardImage!);

    setState(() {
      _isLoading = true;
    });

    try {
      if (mounted) {
        // 🚀 සැබෑ Cubit/API Call එක
        await context.read<AuthCubit>().completeRegistration(
          username: _usernameController.text,
          password: _passwordController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          address: _addressController.text,
          whatsappNumber: _whatsappController.text,
          telegram: _telegramController.text,

          // ✅ UPDATED: File Objects Pass කිරීම
          frontIdImage: frontImageFile,
          backIdImage: backImageFile,
        );
      }
      // Success/Error handling is done by BlocListener
    } catch (e) {
      // If necessary, handle local errors here
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --------------------------------------------------------
  // 🛠️ Image Picker and Permission Handling Logic (No Change)
  // --------------------------------------------------------

  Future<bool> _requestPermission(ImageSource source) async {
    try {
      // Platform-specific handling: iOS uses Permission.photos, Android should
      // request storage / camera permissions. Android 13+ uses READ_MEDIA_IMAGES
      // but permission_handler exposes Permission.storage as a safe fallback.
      if (Platform.isAndroid) {
        if (source == ImageSource.camera) {
          final status = await Permission.camera.status;
          if (status.isGranted) return true;
          final newStatus = await Permission.camera.request();
          if (newStatus.isGranted) return true;
          if (newStatus.isPermanentlyDenied) {
            _showSettingsDialog();
            return false;
          }
          return false;
        } else {
          // Gallery/photo access on Android: try storage (covers many Android versions)
          PermissionStatus status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
          }
          if (status.isGranted) return true;
          if (status.isPermanentlyDenied) {
            _showSettingsDialog();
            return false;
          }

          // Fallback: some platforms/plugins map to photos permission
          final fallback = await Permission.photos.request();
          if (fallback.isGranted) return true;
          if (fallback.isPermanentlyDenied) {
            _showSettingsDialog();
            return false;
          }
          return false;
        }
      } else {
        // iOS / other platforms
        final perm = source == ImageSource.camera ? Permission.camera : Permission.photos;
        final status = await perm.status;
        if (status.isGranted) return true;
        final newStatus = await perm.request();
        if (newStatus.isGranted) return true;
        if (newStatus.isPermanentlyDenied) {
          _showSettingsDialog();
          return false;
        }
        return false;
      }
    } catch (e, st) {
      // Log full error for easier debugging
      // ignore: avoid_print
      print('Permission request error: $e\n$st');
      return false;
    }
  }

  Future<void> _pickImage(bool isFront, ImageSource source) async {
    bool hasPermission = await _requestPermission(source);
    if (!hasPermission) return;

    try {
      // Diagnostic log: mark start of pick flow
      // ignore: avoid_print
      print('DEBUG: Starting image pick (isFront=$isFront, source=$source)');
      final XFile? pickedFile = await _picker.pickImage(source: source);
      // Diagnostic log: result from picker
      // ignore: avoid_print
      print('DEBUG: pickImage returned: ${pickedFile?.path}');
      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            if (isFront) {
              _frontIDCardImage = pickedFile.path;
            } else {
              _backIDCardImage = pickedFile.path;
            }
          });

          // Diagnostic log: after setState
          // ignore: avoid_print
          print('DEBUG: setState updated image path (isFront=$isFront)');
          // 🛑 FIX 1: Native Engine එකට sync වීමට පොඩි delay එකක් දාන්න
          await Future.delayed(const Duration(milliseconds: 100));
          // මේක නැතිනම් Android වල Black Screen/Crash වෙන්න පුළුවන්.
        }
      }
    } catch (e) {
      // ... (Error Handling)
      // ignore: avoid_print
      print('DEBUG: pickImage caught exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selection error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog(bool isFront) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF1F2937),
                ),
                title: const Text('Photo Library (Gallery)'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(isFront, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: Color(0xFF1F2937),
                ),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(isFront, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Permission Required"),
          content: const Text(
            "To upload images, you must grant Camera and Photos (Gallery) permissions in your App Settings.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Later",
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Go to Settings",
                style: TextStyle(color: Color(0xFF10B981)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // From Permission Handler
              },
            ),
          ],
        );
      },
    );
  }

  // --- Validation Logic ---
  // ❌ _checkUsername method එක ඉවත් කර ඇත. ඒ වෙනුවට _validateUsername යොදා ඇත.

  void _checkPasswordStrength(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = null;
        _passwordStrengthColor = Colors.grey;
        _checkPasswordMatch(_confirmPasswordController.text);
        return;
      }

      final hasMinLength = password.length >= 8;
      final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      final hasDigit = RegExp(r'\d').hasMatch(password);
      final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

      int ruleCount = 0;
      if (hasMinLength) ruleCount++;
      if (hasUppercase) ruleCount++;
      if (hasDigit) ruleCount++;
      if (hasSpecial) ruleCount++;

      if (password.length < 8 || ruleCount < 3) {
        _passwordStrength = 'Weak';
        _passwordStrengthColor = Colors.red;
      } else if (ruleCount < 4) {
        _passwordStrength = 'Medium';
        _passwordStrengthColor = Colors.orange;
      } else {
        _passwordStrength = 'Strong';
        _passwordStrengthColor = Colors.green;
      }

      _checkPasswordMatch(_confirmPasswordController.text);
    });
  }

  void _checkPasswordMatch(String confirmPassword) {
    setState(() {
      _passwordsMatch =
          confirmPassword.isNotEmpty &&
          confirmPassword == _passwordController.text;
    });
  }

  // -------------------------

  @override
  Widget build(BuildContext context) {
    final bool isLoading = _isLoading;

    final Widget buttonChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          )
        : Text(
            _currentPage == 2 ? 'Complete Registration' : 'Next Step',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          // 💡 BlocListener එක මෙතන
          listener: (context, state) {
            // 🚨 Error Message Handling
            if (state.errorMessage != null) {
              // Registration successful message (Success)
              if (state.errorMessage!.contains('Registration successful')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: const Color(
                      0xFF10B981,
                    ), // Green for success
                  ),
                );
                context
                    .read<AuthCubit>()
                    .clearError(); // Clear error state immediately
                context.goNamed('login'); // Redirect to Login
              }
              // Other Errors (Failure)
              else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: const Color(0xFFEF4444), // Red for error
                  ),
                );
                context.read<AuthCubit>().clearError(); // Clear error state
              }
            }
          },
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- Header ---
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Join our learning community today',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      // 🛠️ Green line
                      Container(
                        width: 70,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- Stepper (CustomStepper widget) ---
                      CustomStepper(currentStep: _currentPage),
                      const SizedBox(height: 32),

                      // --- PageView (Form Steps) ---
                      SizedBox(
                        height: _currentPage == 2 ? 450 : 550,
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          children: [
                            _buildStepOne(),
                            _buildStepTwo(),
                            _buildStepThree(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Navigation Buttons ---
                      Row(
                        children: [
                          if (_currentPage > 0)
                            Expanded(
                              child: SecondaryButton(
                                onPressed: isLoading ? null : _previousPage,
                                child: const Icon(Icons.arrow_back),
                              ),
                            ),
                          if (_currentPage > 0) const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: PrimaryButton(
                              onPressed: isLoading ? null : _nextPage,
                              child: buttonChild,
                            ),
                          ),
                        ],
                      ),

                      // --- Sign In Link ---
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    context.goNamed('login');
                                  },
                            child: const Text(
                              'Sign In Instead',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Step 1 Widget (Basic Info) ---
  Widget _buildStepOne() {
    return Form(
      key: _stepOneFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // First Name
            CustomTextField(
              controller: _firstNameController,
              label: 'First Name',
              hint: 'Enter your first name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'First Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Last Name
            CustomTextField(
              controller: _lastNameController,
              label: 'Last Name',
              hint: 'Enter your last name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Last Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Username
            // ...
            // --- RegistrationScreen - _buildStepOne() ---
            // B. CustomTextField Widget එක _buildStepOne() තුළ
            CustomTextField(
              controller: _usernameController,
              label: 'Username',
              hint: 'Choose a username',
              icon: Icons.person,

              // 1. 🛑 FIX 1: errorText නැවත _usernameError වෙත සෙට් කරන්න!
              // මෙය '4 characters' සහ 'already taken' errors වහාම පෙන්වීමට අවශ්‍යයි.
              errorText: _usernameError,

              // 2. Custom Indicator Logic (Length 4)
              customIndicatorText: _isUsernameChecking
                  ? 'Checking availability...'
                  : (_usernameError == null &&
                        _usernameController.text.length >= 4)
                  ? 'Username is available'
                  : null,

              // 3. Custom Indicator Color (Length 4)
              customIndicatorColor: _isUsernameChecking
                  ? Colors.blue
                  : _usernameError == null &&
                        _usernameController.text.length >= 4
                  ? Colors.green
                  : null,

              // 4. OnChanged Listener (මෙය හරි)
              onChanged: (value) {
                _validateUsername(value);
                context.read<AuthCubit>().clearError();
              },

              // 5. Validator (Next Button Logic)
              validator: (value) {
                // 1. 🎯 Required Check: Next Button එක එබූ විට හිස් නම් පෙන්වයි.
                if (value == null || value.isEmpty) {
                  return 'Username is required';
                }

                // 2. Final Length Check: Next Button එක එබූ විට 4 ට අඩුවෙන් ඇත්නම්, Final Error එක පෙන්වයි.
                if (value.length < 4) {
                  return 'Username must be at least 4 characters';
                }

                // 3. 🛑 FIX 2: Double display වැලැක්වීම.
                // _usernameError (Taken/Length) දැනටමත් errorText හරහා පෙන්වන නිසා,
                // validator එකෙන් නැවත එම error එක return නොකරන්න.
                // අපිට Next button එකේ validation state එක (_nextPage() තුළ) පරීක්ෂා කිරීමට
                // _usernameError තවමත් අවශ්‍ය නිසා, මෙහි null return කළ හැක.
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Email
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(
                  r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b',
                ).hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Password Field
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Create a strong password',
              icon: Icons.lock_outline,
              isPassword: true,
              strengthIndicator: _passwordStrength,
              strengthColor: _passwordStrengthColor,
              onChanged: _checkPasswordStrength,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters long.';
                }
                if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                  return 'Password must contain at least one special character.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Confirm Password Field
            CustomTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Confirm your password',
              icon: Icons.lock_outline,
              isPassword: true,
              suffixIcon: _confirmPasswordController.text.isNotEmpty
                  ? Icon(
                      _passwordsMatch ? Icons.check_circle : Icons.cancel,
                      color: _passwordsMatch
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      size: 20,
                    )
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Step 2 Widget (Contact Info) ---
  Widget _buildStepTwo() {
    return Form(
      key: _stepTwoFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Address
            CustomTextField(
              controller: _addressController,
              label: 'Address',
              hint: 'Enter your address',
              icon: Icons.home_outlined,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Phone Number
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone Number is required';
                }
                if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                  return 'Enter a valid 10-digit number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // WhatsApp Number (Optional)
            CustomTextField(
              controller: _whatsappController,
              label: 'WhatsApp Number (Optional)',
              hint: 'Enter your WhatsApp number',
              icon: Icons.chat_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Telegram
            CustomTextField(
              controller: _telegramController,
              label: 'Telegram Username (Optional)',
              hint: 'Enter your Telegram username',
              icon: Icons.telegram_outlined,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepThree() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 🛠️ ID Card Front Image Upload
          IDCardUpload(
            label: 'ID Card Front Image',
            onTap: () => _showImageSourceDialog(true),

            imagePath: _frontIDCardImage,

            onRemove: _frontIDCardImage != null
                ? () {
                    setState(() {
                      _frontIDCardImage = null; // Clear image
                    });
                  }
                : null,
          ),

          const SizedBox(height: 16), // Add a spacer
          IDCardUpload(
            label: 'ID Card Back Image',
            onTap: () => _showImageSourceDialog(false),

            imagePath: _backIDCardImage,

            onRemove: _backIDCardImage != null
                ? () {
                    setState(() {
                      _backIDCardImage = null; // Clear image
                    });
                  }
                : null,
          ),

          const SizedBox(height: 20),

          // ... (අනෙකුත් Container Logic) ...
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5), // Green 100
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Please confirm:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF065F46), // Dark Green
                  ),
                ),
                SizedBox(height: 8),
                BulletPoint(text: 'The ID card image is clear and readable'),
                BulletPoint(text: 'All corners of the ID card are visible'),
                BulletPoint(text: 'The image is not blurry or distorted'),
                BulletPoint(text: 'Your student ID number is clearly visible'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 3 Widget (ID Card Upload) ---
}
