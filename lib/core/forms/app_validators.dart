import '../l10n/generated/app_localizations.dart';

class AppValidators {
  const AppValidators._();

  static String? required(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validationRequired;
    }
    return null;
  }

  static String? email(AppLocalizations l10n, String? value) {
    final requiredMessage = required(l10n, value);
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if (!value!.contains('@')) {
      return l10n.validationEmail;
    }
    return null;
  }

  static String? password(AppLocalizations l10n, String? value) {
    final requiredMessage = required(l10n, value);
    if (requiredMessage != null) {
      return requiredMessage;
    }
    final password = value!;
    if (password.length <= 6) {
      return 'Use at least 7 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Add at least one uppercase letter.';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Add at least one special character.';
    }
    return null;
  }

  static String? confirmPassword(
    AppLocalizations l10n,
    String? value,
    String password,
  ) {
    final passwordMessage = AppValidators.password(l10n, value);
    if (passwordMessage != null) {
      return passwordMessage;
    }
    if (value != password) {
      return 'Passwords do not match.';
    }
    return null;
  }

  static String? positiveNumber(AppLocalizations l10n, String? value) {
    final requiredMessage = required(l10n, value);
    if (requiredMessage != null) {
      return requiredMessage;
    }
    final number = double.tryParse(value!);
    if (number == null || number <= 0) {
      return l10n.validationPositiveNumber;
    }
    return null;
  }

  static String? coordinate(AppLocalizations l10n, String? value) {
    final requiredMessage = required(l10n, value);
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if (double.tryParse(value!) == null) {
      return l10n.validationNumber;
    }
    return null;
  }
}
