class FormValidator {
  static const int maxDescriptionLength = 500;
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password cannot be empty';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return 'Description cannot be empty';
    }
    if (description.length > maxDescriptionLength) {
      return 'Description must be $maxDescriptionLength characters or less';
    }
    return null;
  }

  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }
}
