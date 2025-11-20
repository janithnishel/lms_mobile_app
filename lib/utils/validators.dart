// Comprehensive validation utilities for LMS App

// Form Validators
class Validators {
  // Email validation
  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Required field validator
  static String? requiredValidator(String? value, {String message = 'This field is required'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  // Minimum length validator
  static String? minLengthValidator(String? value, int min, {String? fieldName}) {
    if (value == null || value.length < min) {
      return '${fieldName ?? 'Field'} must be at least $min characters long';
    }
    return null;
  }

  // Maximum length validator
  static String? maxLengthValidator(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'Field'} cannot exceed $max characters';
    }
    return null;
  }

  // Password strength validator
  static String? passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  // Confirm password validator
  static String? confirmPasswordValidator(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Paper ID validator (24-character hex string for MongoDB ObjectId)
  static String? paperIdValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Paper ID is required';
    }
    final objectIdRegex = RegExp(r'^[0-9a-fA-F]{24}$');
    if (!objectIdRegex.hasMatch(value)) {
      return 'Invalid paper ID format';
    }
    return null;
  }

  // Phone number validator
  static String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Remove spaces, hyphens, parentheses for validation
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(cleanNumber)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}

// Extension methods for easier validation chaining
extension ValidatorExtensions on String {
  String? validateEmail() => Validators.emailValidator(this);
  String? validateRequired({String message = 'This field is required'}) =>
      Validators.requiredValidator(this, message: message);
  String? validateMinLength(int min, {String? fieldName}) =>
      Validators.minLengthValidator(this, min, fieldName: fieldName);
  String? validateMaxLength(int max, {String? fieldName}) =>
      Validators.maxLengthValidator(this, max, fieldName: fieldName);
  String? validatePassword() => Validators.passwordValidator(this);
  String? validatePaperId() => Validators.paperIdValidator(this);
  String? validatePhone() => Validators.phoneValidator(this);
}
