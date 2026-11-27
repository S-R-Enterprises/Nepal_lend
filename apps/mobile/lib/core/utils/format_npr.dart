/// Display helpers for Nepali currency. Amounts are always integer paisa.
final Map<int, String> _fullCache = <int, String>{};
final Map<int, String> _compactCache = <int, String>{};
const int _maxCachedAmounts = 512;

String formatNPR(
  int paisa, {
  bool showPaisa = true,
  bool withSymbol = true,
}) {
  if (showPaisa && withSymbol) {
    return _cached(
      _fullCache,
      paisa,
      () => _formatNPR(paisa, showPaisa: true, withSymbol: true),
    );
  }
  if (!showPaisa && withSymbol) {
    return _cached(
      _compactCache,
      paisa,
      () => _formatNPR(paisa, showPaisa: false, withSymbol: true),
    );
  }
  return _formatNPR(paisa, showPaisa: showPaisa, withSymbol: withSymbol);
}

String _cached(Map<int, String> cache, int key, String Function() build) {
  final cached = cache[key];
  if (cached != null) return cached;
  if (cache.length >= _maxCachedAmounts) cache.clear();
  final value = build();
  cache[key] = value;
  return value;
}

String _formatNPR(
  int paisa, {
  required bool showPaisa,
  required bool withSymbol,
}) {
  final negative = paisa < 0;
  final absolute = paisa.abs();
  final rupees = absolute ~/ 100;
  final fraction = absolute % 100;
  final grouped = _groupLakh(rupees.toString());
  final amount = showPaisa
      ? '$grouped.${fraction.toString().padLeft(2, '0')}'
      : grouped;
  return '${negative ? '-' : ''}${withSymbol ? 'NPR ' : ''}$amount';
}

/// Compact form for cards and list tiles: "NPR 2,00,000".
String formatNPRCompact(int paisa) => formatNPR(paisa, showPaisa: false);

/// Indian/Nepali lakh grouping: 200000 -> 2,00,000.
String _groupLakh(String digits) {
  if (digits.length <= 3) return digits;
  final tail = digits.substring(digits.length - 3);
  var head = digits.substring(0, digits.length - 3);
  final groups = <String>[];
  while (head.length > 2) {
    groups.insert(0, head.substring(head.length - 2));
    head = head.substring(0, head.length - 2);
  }
  if (head.isNotEmpty) groups.insert(0, head);
  return [...groups, tail].join(',');
}

/// "1400" -> "14.00%".
String formatBps(int bps) =>
    '${bps ~/ 100}.${(bps % 100).abs().toString().padLeft(2, '0')}%';
