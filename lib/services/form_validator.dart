class FormValidator {
  static const int maxDescriptionLength = 500;
  static const int minPasswordLength = 6;

  // Email validation regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates email format
  /// Returns error message if invalid, null if valid
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validates password length
  /// Returns error message if invalid, null if valid
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password cannot be empty';
    }
    
    if (password.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    
    return null;
  }

  /// Validates complaint description
  /// Returns error message if invalid, null if valid
  static String? validateDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return 'Description cannot be empty';
    }
    
    if (description.length > maxDescriptionLength) {
      return 'Description must be $maxDescriptionLength characters or less';
    }
    
    return null;
  }

  /// Helper method to check if email format is valid
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }
}
