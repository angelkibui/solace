import 'package:flutter_test/flutter_test.dart';
import 'package:solace/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty input', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('rejects malformed addresses', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('missing@domain'), isNotNull);
    });

    test('accepts a well-formed address', () {
      expect(Validators.email('kevin@example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects short passwords', () {
      expect(Validators.password('abc123'), isNotNull);
    });

    test('rejects passwords missing a number', () {
      expect(Validators.password('longenoughpassword'), isNotNull);
    });

    test('accepts a password with a letter and a number, 8+ chars', () {
      expect(Validators.password('password1'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('flags mismatch', () {
      expect(Validators.confirmPassword('password1', 'password2'), isNotNull);
    });

    test('passes on match', () {
      expect(Validators.confirmPassword('password1', 'password1'), isNull);
    });
  });

  group('Validators.alias', () {
    test('rejects blank alias', () {
      expect(Validators.alias('   '), isNotNull);
    });

    test('rejects alias shorter than 3 characters', () {
      expect(Validators.alias('ab'), isNotNull);
    });

    test('rejects alias longer than 24 characters', () {
      expect(Validators.alias('a' * 25), isNotNull);
    });

    test('accepts a reasonable alias', () {
      expect(Validators.alias('BraveRiver12345'), isNull);
    });
  });
}
