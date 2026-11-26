/// Phone-number helpers shared by UI validation and both auth providers.
class NepaliPhone {
  NepaliPhone._();

  static String normalize(String phone) =>
      phone.replaceAll(RegExp(r'[^0-9]'), '');

  /// Strip the country code so requests and verification use one key.
  static String localDigits(String phone) {
    final digits = normalize(phone);
    return digits.startsWith('977') ? digits.substring(3) : digits;
  }

  static String toE164(String phone) => '+977${localDigits(phone)}';

  static bool isValid(String phone) =>
      RegExp(r'^9[0-9]{9}$').hasMatch(localDigits(phone));
}
