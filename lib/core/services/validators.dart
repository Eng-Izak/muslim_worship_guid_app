// ──────────────────────────────────────────────────────────────
// VALIDATORS
// ──────────────────────────────────────────────────────────────
// Reusable input validation for forms.
//
// Every validator returns a [ValidationResult] containing:
//   - isValid (bool): whether validation passed
//   - errorMessage (String?): why it failed (null if valid)
//
// Usage in a TextFormField:
//   TextFormField(
//     validator: (value) => Validators.email(value).errorMessage,
//   )

class ValidationResult {
  const ValidationResult({required this.isValid, this.errorMessage});

  factory ValidationResult.valid() => const ValidationResult(isValid: true);

  factory ValidationResult.invalid(String message) => ValidationResult(isValid: false, errorMessage: message);
  final bool isValid;
  final String? errorMessage;
}

class Validators {
  Validators._();

  /// Validates an email address format.
  static ValidationResult email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return .invalid('Email is required');
    }
    final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return .invalid('Enter a valid email address');
    }
    return .valid();
  }

  /// Validates password strength (minimum 6 characters).
  static ValidationResult password(String? value) {
    if (value == null || value.isEmpty) {
      return .invalid('Password is required');
    }
    if (value.length < 6) {
      return .invalid('Password must be at least 6 characters');
    }
    if (value.length > 100) {
      return .invalid('Password must be less than 100 characters');
    }
    return .valid();
  }

  /// Validates a name (minimum 2 characters).
  static ValidationResult name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return .invalid('Name is required');
    }
    if (value.trim().length < 2) {
      return .invalid('Name must be at least 2 characters');
    }
    return .valid();
  }

  /// Validates a phone number format.
  static ValidationResult phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return .invalid('Phone number is required');
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return .invalid('Enter a valid phone number');
    }
    return .valid();
  }

  /// Generic "required field" validator for any text input.
  static ValidationResult required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return .invalid('$fieldName is required');
    }
    return .valid();
  }

  /// Validates a URL format.
  static ValidationResult url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return .invalid('URL is required');
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return .invalid('Enter a valid URL');
    }
    return .valid();
  }
}
