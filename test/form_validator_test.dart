import 'package:flutter_test/flutter_test.dart';
import 'package:hostel360/services/form_validator.dart';
import 'dart:math';

void main() {
  group('FormValidator - Property Tests', () {
    // Property 4: Email validation rejects invalid formats
    // Feature: hostel360, Property 4: For any string that doesn't match standard email format,
    // email validation should return false
    test('Property 4: Email validation rejects invalid formats', () {
      final random = Random();
      final invalidEmailPatterns = [
        // Missing @
        () => 'user${random.nextInt(1000)}domain.com',
        // Missing domain
        () => 'user${random.nextInt(1000)}@',
        // Missing username
        () => '@domain${random.nextInt(1000)}.com',
        // Invalid characters
        () => 'user ${random.nextInt(1000)}@domain.com',
        // Multiple @
        () => 'user@${random.nextInt(1000)}@domain.com',
        // Missing TLD
        () => 'user${random.nextInt(1000)}@domain',
        // Empty string
        () => '',
        // Just spaces
        () => '   ',
      ];

      for (int i = 0; i < 100; i++) {
        final pattern = invalidEmailPatterns[i % invalidEmailPatterns.length];
        final invalidEmail = pattern();
        
        final result = FormValidator.isValidEmail(invalidEmail);
        expect(result, isFalse,
            reason: 'Invalid email "$invalidEmail" should be rejected');
      }
    });

    // Additional test: Valid emails should pass
    test('Property 4 (complement): Valid email formats are accepted', () {
      final random = Random();
      final validEmailPatterns = [
        'user${random.nextInt(1000)}@example.com',
        'test.user${random.nextInt(1000)}@domain.co.uk',
        'user+tag${random.nextInt(1000)}@example.org',
        'firstname.lastname${random.nextInt(1000)}@company.com',
      ];

      for (final email in validEmailPatterns) {
        final result = FormValidator.isValidEmail(email);
        expect(result, isTrue,
            reason: 'Valid email "$email" should be accepted');
      }
    });

    // Property 5: Password validation enforces minimum length
    // Feature: hostel360, Property 5: For any string with length < 6 characters,
    // password validation should return false
    test('Property 5: Password validation enforces minimum length', () {
      final random = Random();
      
      for (int i = 0; i < 100; i++) {
        // Generate passwords with length 0-5
        final length = random.nextInt(6); // 0 to 5
        final shortPassword = List.generate(
          length,
          (_) => String.fromCharCode(random.nextInt(26) + 97), // a-z
        ).join();
        
        final result = FormValidator.validatePassword(shortPassword);
        expect(result, isNotNull,
            reason: 'Password "$shortPassword" with length $length should be rejected');
      }
    });

    // Additional test: Valid passwords should pass
    test('Property 5 (complement): Passwords with length >= 6 are accepted', () {
      final random = Random();
      
      for (int i = 0; i < 100; i++) {
        // Generate passwords with length 6-20
        final length = 6 + random.nextInt(15); // 6 to 20
        final validPassword = List.generate(
          length,
          (_) => String.fromCharCode(random.nextInt(26) + 97), // a-z
        ).join();
        
        final result = FormValidator.validatePassword(validPassword);
        expect(result, isNull,
            reason: 'Password with length $length should be accepted');
      }
    });

    // Property 9: Empty descriptions are rejected
    // Feature: hostel360, Property 9: For any string composed entirely of whitespace characters,
    // complaint submission should fail with a validation error
    test('Property 9: Empty descriptions are rejected', () {
      final random = Random();
      final emptyDescriptionPatterns = [
        // Empty string
        () => '',
        // Just spaces
        () => ' ' * (1 + random.nextInt(10)),
        // Just tabs
        () => '\t' * (1 + random.nextInt(5)),
        // Just newlines
        () => '\n' * (1 + random.nextInt(5)),
        // Mixed whitespace
        () => '  \t\n  \t',
      ];

      for (int i = 0; i < 100; i++) {
        final pattern = emptyDescriptionPatterns[i % emptyDescriptionPatterns.length];
        final emptyDescription = pattern();
        
        final result = FormValidator.validateDescription(emptyDescription);
        expect(result, isNotNull,
            reason: 'Empty/whitespace description should be rejected');
      }
    });

    // Additional test: Valid descriptions should pass
    test('Property 9 (complement): Non-empty descriptions are accepted', () {
      final random = Random();
      
      for (int i = 0; i < 100; i++) {
        // Generate descriptions with length 1-500
        final length = 1 + random.nextInt(500);
        final validDescription = List.generate(
          length,
          (_) => String.fromCharCode(random.nextInt(26) + 97), // a-z
        ).join();
        
        final result = FormValidator.validateDescription(validDescription);
        expect(result, isNull,
            reason: 'Non-empty description with length $length should be accepted');
      }
    });
  });

  group('FormValidator - Unit Tests', () {
    group('validateEmail', () {
      test('returns error for null email', () {
        expect(FormValidator.validateEmail(null), isNotNull);
      });

      test('returns error for empty email', () {
        expect(FormValidator.validateEmail(''), isNotNull);
      });

      test('returns error for email without @', () {
        expect(FormValidator.validateEmail('userdomain.com'), isNotNull);
      });

      test('returns error for email without domain', () {
        expect(FormValidator.validateEmail('user@'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(FormValidator.validateEmail('user@example.com'), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error for null password', () {
        expect(FormValidator.validatePassword(null), isNotNull);
      });

      test('returns error for empty password', () {
        expect(FormValidator.validatePassword(''), isNotNull);
      });

      test('returns error for password with less than 6 characters', () {
        expect(FormValidator.validatePassword('12345'), isNotNull);
      });

      test('returns null for password with exactly 6 characters', () {
        expect(FormValidator.validatePassword('123456'), isNull);
      });

      test('returns null for password with more than 6 characters', () {
        expect(FormValidator.validatePassword('1234567890'), isNull);
      });
    });

    group('validateDescription', () {
      test('returns error for null description', () {
        expect(FormValidator.validateDescription(null), isNotNull);
      });

      test('returns error for empty description', () {
        expect(FormValidator.validateDescription(''), isNotNull);
      });

      test('returns error for whitespace-only description', () {
        expect(FormValidator.validateDescription('   '), isNotNull);
      });

      test('returns error for description exceeding max length', () {
        final longDescription = 'a' * 501;
        expect(FormValidator.validateDescription(longDescription), isNotNull);
      });

      test('returns null for valid description', () {
        expect(FormValidator.validateDescription('This is a valid complaint'), isNull);
      });

      test('returns null for description at max length', () {
        final maxDescription = 'a' * 500;
        expect(FormValidator.validateDescription(maxDescription), isNull);
      });
    });
  });
}
