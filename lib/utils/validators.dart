String? requiredValidator(String? value, {String message = 'අවශ්‍ය ක්ෂේත්‍රයකි'}) {
  if (value == null || value.trim().isEmpty) return message;
  return null;
}

String? minLengthValidator(String? value, int min) {
  if (value == null || value.length < min) {
    return 'අවම අක්ෂර ගණන $min යි';
  }
  return null;
}

String? confirmPasswordValidator(String? password, String? confirmPassword) {
  if (confirmPassword == null || confirmPassword.isEmpty) {
    return 'මුරපදය තහවුරු කරන්න';
  }
  if (password != confirmPassword) {
    return 'මුරපද එක නොගැලපේ';
  }
  return null;
}
