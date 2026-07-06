import 'package:dio/dio.dart';

/// Fire-and-forget submission of the landing-page early-access form to a
/// Google Form, so responses land in its linked Google Sheet.
///
/// How to wire up:
/// 1. Create a Google Form with fields: Email, Role, Country, Phone, Message.
/// 2. Open the form's kebab menu -> "Get pre-filled link", fill dummy values,
///    copy the generated URL.
/// 3. From that URL take the long id after `/forms/d/e/` into [_formId], and
///    each `entry.NNNNNNN=` parameter name into the matching field below.
///
/// The browser blocks reading Google's response (CORS), but the POST itself
/// is delivered, so errors are intentionally swallowed. The role is submitted
/// in English regardless of the visitor's language to keep the sheet
/// filterable.
abstract final class EarlyAccessSubmission {
  static const _formId =
      '1FAIpQLSezijb7oBPXnygRh_i0fLiYE2XuA_LushKW8_7JY0suCHvwRA';

  static const _emailEntry = 'entry.1377907578';
  static const _roleEntry = 'entry.1975305958';
  static const _countryEntry = 'entry.1064544260';
  static const _phoneEntry = 'entry.1465073069';
  static const _messageEntry = 'entry.1304500921';

  static bool get isConfigured => _formId.isNotEmpty;

  static Future<void> submit({
    required String email,
    required String role,
    required String country,
    required String phone,
    required String message,
  }) async {
    if (!isConfigured) return;
    try {
      await Dio().post<void>(
        'https://docs.google.com/forms/d/e/$_formId/formResponse',
        data: {
          _emailEntry: email,
          _roleEntry: role,
          _countryEntry: country,
          _phoneEntry: phone,
          _messageEntry: message,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (_) => true,
        ),
      );
    } catch (_) {
      // Expected on web: CORS hides the response, but the POST still lands.
    }
  }
}
