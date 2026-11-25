import 'package:nepal_lend/core/config/product_rules.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';

/// Deterministic agreement copy. Track B stores the signed text in immutable
/// storage; the hash here is enough to show the demo version is not editable.
class LoanTerms {
  const LoanTerms._();

  static const String version = 'v1';

  static String text({
    required int amountPaisa,
    required int rateBps,
    required int tenorMonths,
    required String purpose,
  }) =>
      'NepalLend agreement $version: ${formatNPR(amountPaisa)} at '
      '${(rateBps / 100).toStringAsFixed(2)}% p.a. for $tenorMonths months. '
      'Purpose: $purpose. Platform fee is '
      '${(ProductRules.feeBpsOfInterest / 100).toStringAsFixed(0)}% of interest. '
      'Repayments follow the reducing-balance schedule.';

  /// FNV-1a, rendered as 8 hex digits. Not cryptographic; only a tamper-evident
  /// marker for the demo terms string.
  static String hash(String text) {
    var hash = 0x811c9dc5;
    for (final codeUnit in text.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toUnsigned(32).toRadixString(16).padLeft(8, '0');
  }
}
