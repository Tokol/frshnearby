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
