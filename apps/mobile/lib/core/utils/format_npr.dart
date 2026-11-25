/// Display helpers for Nepali currency. Amounts are always integer paisa.
String formatNPR(
  int paisa, {
  bool showPaisa = true,
  bool withSymbol = true,
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
