/// Shared form validators (Part D14). Every auth screen — Login, Register,
/// Forgot Password — should validate through here instead of writing its
/// own regex, so the rules (and their error copy) stay in one place.
class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w-]+(\.[\w-]+)*$');

  /// Requires a plausible `name@domain.tld` shape. Deliberately permissive —
  /// full RFC 5322 validation isn't worth the false negatives here.
  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email is required.';
    if (!_emailRegex.hasMatch(trimmed)) return 'Enter a valid email address.';
    return null;
  }

  /// Minimum bar for account security: 8+ characters with at least one
  /// letter and one number. Not maximalist on purpose — this is a mental
  /// health app for people who may already feel like access is a hurdle.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    if (!RegExp(r'[A-Za-z]').hasMatch(value))
      return 'Include at least one letter.';
    if (!RegExp(r'[0-9]').hasMatch(value))
      return 'Include at least one number.';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password.';
    if (value != original) return 'Passwords do not match.';
    return null;
  }

  /// Aliases are the user-facing identity everywhere in the app (see
  /// UserModel.alias), so keep them short enough to fit in a chat bubble
  /// header but long enough to not be blank/accidental.
  static String? alias(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Choose an alias.';
    if (trimmed.length < 3) return 'Alias must be at least 3 characters.';
    if (trimmed.length > 24) return 'Alias must be under 24 characters.';
    return null;
  }
}
