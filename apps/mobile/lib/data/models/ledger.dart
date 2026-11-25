import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/models/enums.dart';

/// Stable account identifiers. A wallet balance is never stored directly — it
/// is always the sum of the signed entries in [LedgerAccount.userWallet].
class LedgerAccount {
  const LedgerAccount._();

  static String userWallet(String userId) => 'user_wallet:$userId';
  static String loanEscrow(String loanId) => 'loan_escrow:$loanId';
  static const String platformFee = 'platform_fee';

  /// Off-platform settlement account. Top-ups debit it; withdrawals credit it.
  static const String externalCash = 'external:cash';

  static bool isUserWallet(String accountId) =>
      accountId.startsWith('user_wallet:');
}

class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.journalId,
    required this.accountId,
    required this.amountPaisa, // signed: credit +, debit -
  });

  final String id;
  final String journalId;
  final String accountId;
  final int amountPaisa;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'journalId': journalId,
        'accountId': accountId,
        'amountPaisa': amountPaisa,
      };

  factory LedgerEntry.fromJson(Map<String, dynamic> json) => LedgerEntry(
        id: json['id'] as String,
        journalId: json['journalId'] as String,
        accountId: json['accountId'] as String,
        amountPaisa: (json['amountPaisa'] as num).toInt(),
      );
}

class JournalTransaction {
  const JournalTransaction({
    required this.id,
    required this.kind,
    required this.referenceId,
    required this.idempotencyKey,
    required this.createdAt,
    required this.entries,
    this.reversalOfId,
  });

  final String id;
  final JournalKind kind;
  final String referenceId;
  final String idempotencyKey;
  final DateTime createdAt;
  final List<LedgerEntry> entries;
  final String? reversalOfId;

  /// A valid journal always sums to zero paisa.
  int get sumPaisa =>
      entries.fold<int>(0, (total, entry) => total + entry.amountPaisa);

  int amountFor(String accountId) => entries
      .where((entry) => entry.accountId == accountId)
      .fold<int>(0, (total, entry) => total + entry.amountPaisa);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'kind': kind.name,
        'referenceId': referenceId,
        'idempotencyKey': idempotencyKey,
        'createdAt': createdAt.toIso8601String(),
        'reversalOfId': reversalOfId,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };

  factory JournalTransaction.fromJson(Map<String, dynamic> json) {
    JournalKind kind = JournalKind.topup;
    for (final value in JournalKind.values) {
      if (value.name == json['kind']) kind = value;
    }
    return JournalTransaction(
      id: json['id'] as String,
      kind: kind,
      referenceId: json['referenceId'] as String? ?? '',
      idempotencyKey: json['idempotencyKey'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      reversalOfId: json['reversalOfId'] as String?,
      entries: (json['entries'] as List<dynamic>)
          .map((item) => LedgerEntry.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

/// One line in the wallet history, derived from a journal (never stored).
class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.kind,
    required this.title,
    required this.amountPaisa,
    required this.createdAt,
    this.status = 'completed',
  });

  final String id;
  final JournalKind kind;
  final String title;
  final int amountPaisa;
  final DateTime createdAt;
  final String status;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'kind': kind.name,
        'title': title,
        'amountPaisa': amountPaisa,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    JournalKind kind = JournalKind.topup;
    for (final value in JournalKind.values) {
      if (value.name == json['kind']) kind = value;
    }
    return WalletTransaction(
      id: json['id'] as String,
      kind: kind,
      title: json['title'] as String? ?? 'Wallet transaction',
      amountPaisa: (json['amountPaisa'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String? ?? 'completed',
    );
  }

  static WalletTransaction fromJournal(
    JournalTransaction journal,
    String walletAccountId,
  ) {
    final amount = journal.amountFor(walletAccountId);
    return WalletTransaction(
      id: journal.id,
      kind: journal.kind,
      title: switch (journal.kind) {
        JournalKind.topup => 'Wallet top-up',
        JournalKind.withdrawal => 'Withdrawal',
        JournalKind.fund => 'Loan funding',
        JournalKind.disburse => 'Loan disbursement',
        JournalKind.repayment =>
          amount >= 0 ? 'Repayment received' : 'Repayment paid',
        JournalKind.fee => 'Platform fee',
        JournalKind.reversal => 'Reversal',
      },
      amountPaisa: amount,
      createdAt: journal.createdAt,
    );
  }
}

/// Wallet screen data. `balancePaisa` is computed, not a mutable column.
class WalletSnapshot {
  const WalletSnapshot({
    required this.accountId,
    required this.balancePaisa,
    required this.transactions,
  });

  final String accountId;
  final int balancePaisa;
  final List<WalletTransaction> transactions;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'accountId': accountId,
        'balancePaisa': balancePaisa,
        'transactions': transactions.map((item) => item.toJson()).toList(),
      };

  factory WalletSnapshot.fromJson(Map<String, dynamic> json) => WalletSnapshot(
        accountId: json['accountId'] as String,
        balancePaisa: (json['balancePaisa'] as num).toInt(),
        transactions: (json['transactions'] as List<dynamic>)
            .map(
              (item) =>
                  WalletTransaction.fromJson(item as Map<String, dynamic>),
            )
            .toList(growable: false),
      );
}

/// Thin validation helper shared by the mock DB and property tests.
void assertBalancedJournal(List<LedgerEntry> entries) {
  final sum = entries.fold<int>(0, (total, entry) => total + entry.amountPaisa);
  if (sum != 0) {
    throw AppFailure(
      'ledger_unbalanced',
      'Journal entries must sum to zero (got $sum paisa).',
    );
  }
}
