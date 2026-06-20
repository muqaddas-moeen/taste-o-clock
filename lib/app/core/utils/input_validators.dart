class InputValidators {
  InputValidators._();

  static const int maxSearchLength = 64;
  static const int maxPhoneLength = 20;
  static const int maxAddressLength = 200;
  static const int maxCityStateLength = 80;
  static const int maxPostalLength = 20;
  static const int maxCardHolderLength = 80;
  static const int maxCardBrandLength = 40;
  static const int maxCartItems = 50;
  static const int maxItemQuantity = 99;

  static final RegExp _controlChars = RegExp(r'[\x00-\x1F\x7F]');
  static final RegExp _phonePattern = RegExp(r'^[+\d\s().-]{7,20}$');
  static final RegExp _cardLast4Pattern = RegExp(r'^\d{4}$');
  static final RegExp _cardHolderPattern = RegExp(r"^[a-zA-Z\s'.-]{2,80}$");

  static String sanitizeText(String value, {int maxLength = 200}) {
    final cleaned = value
        .replaceAll(_controlChars, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.length <= maxLength) return cleaned;
    return cleaned.substring(0, maxLength);
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final phone = sanitizeText(value, maxLength: maxPhoneLength);
    if (!_phonePattern.hasMatch(phone)) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  static String? validateAddressLine(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address line is required.';
    }
    final line = sanitizeText(value, maxLength: maxAddressLength);
    if (line.length < 3) return 'Address is too short.';
    return null;
  }

  static String? validatePostalCode(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final postal = sanitizeText(value, maxLength: maxPostalLength);
    if (!RegExp(r'^[a-zA-Z0-9\s-]{3,20}$').hasMatch(postal)) {
      return 'Enter a valid postal code.';
    }
    return null;
  }

  static String? validateCardLast4(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the last 4 digits of your card.';
    }
    final last4 = value.trim();
    if (!_cardLast4Pattern.hasMatch(last4)) {
      return 'Last 4 digits must be exactly 4 numbers.';
    }
    return null;
  }

  static String? validateCardHolder(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the name on your card.';
    }
    final name = sanitizeText(value, maxLength: maxCardHolderLength);
    if (!_cardHolderPattern.hasMatch(name)) {
      return 'Enter a valid cardholder name.';
    }
    return null;
  }

  static String sanitizeSearchQuery(String value) {
    return sanitizeText(value, maxLength: maxSearchLength);
  }
}
