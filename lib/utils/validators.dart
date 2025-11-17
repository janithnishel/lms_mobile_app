String? requiredValidator(String? value, {String message = 'This field is required'}) {
  if (value == null || value.trim().isEmpty) return message;
  return null;
}

String? minLengthValidator(String? value, int min) {
  if (value == null || value.length < min) {
    return 'Minimum $min characters required';
  }
  return null;
}

String? confirmPasswordValidator(String? password, String? confirmPassword) {
  if (confirmPassword == null || confirmPassword.isEmpty) {
    return 'Please confirm your password';
  }
  if (password != confirmPassword) {
    return 'Passwords do not match';
  }
  return null;
}
