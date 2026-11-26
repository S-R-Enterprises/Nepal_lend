import 'dart:convert';

import 'package:nepal_lend/core/utils/demo_clock.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/models/app_notification.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory demo database, optionally persisted with SharedPreferences.
///
/// This is the only state store used in `ENV=mock`. Track B replaces it with
/// the HTTP API and PostgreSQL without changing the screens.
class MockDb {
  MockDb._();

  static final MockDb instance = MockDb._();

  static const _userKey = 'nepallend.mock.user';
  static const _kycKey = 'nepallend.mock.kyc';
  static const _journalsKey = 'nepallend.mock.journals';
  static const _intentsKey = 'nepallend.mock.paymentIntents';
  static const _receiptsKey = 'nepallend.mock.receipts';
  static const _loansKey = 'nepallend.mock.loans';
  static const _stakesKey = 'nepallend.mock.stakes';
  static const _notificationsKey = 'nepallend.mock.notifications';

  AppUser? currentUser;
  KycProfile? kycProfile;

  /// Append-only journals. Balances are derived by summing these entries.
  final List<JournalTransaction> journals = <JournalTransaction>[];
  final Map<String, PaymentIntent> paymentIntents =
      <String, PaymentIntent>{};
  final Map<String, PaymentReceipt> receipts = <String, PaymentReceipt>{};

  /// Demo loan applications and agreements, keyed by loan id.
  final Map<String, Loan> loans = <String, Loan>{};

  /// Lender stake rows, keyed by stake id.
  final Map<String, Stake> stakes = <String, Stake>{};

  /// In-app notification rows, keyed by notification id.
  final Map<String, AppNotification> notifications =
      <String, AppNotification>{};

  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawUser = prefs.getString(_userKey);
      if (rawUser != null) {
        currentUser = AppUser.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
      }
      final rawKyc = prefs.getString(_kycKey);
      if (rawKyc != null) {
        kycProfile = KycProfile.fromJson(jsonDecode(rawKyc) as Map<String, dynamic>);
      }
      final rawJournals = prefs.getString(_journalsKey);
      if (rawJournals != null) {
        journals
          ..clear()
          ..addAll(
            (jsonDecode(rawJournals) as List<dynamic>)
                .map(
                  (item) => JournalTransaction.fromJson(
                    item as Map<String, dynamic>,
                  ),
                ),
          );
      }
      _loadMap(prefs.getString(_intentsKey), paymentIntents, PaymentIntent.fromJson);
      _loadMap(prefs.getString(_receiptsKey), receipts, PaymentReceipt.fromJson);
      _loadMap(prefs.getString(_loansKey), loans, Loan.fromJson);
      _loadMap(prefs.getString(_stakesKey), stakes, Stake.fromJson);
      _loadMap(
        prefs.getString(_notificationsKey),
        notifications,
        AppNotification.fromJson,
      );
    } catch (_) {
      // Platform plugins are unavailable in unit tests: stay in memory.
    }
    _loaded = true;
  }

  void _loadMap<T>(
    String? raw,
    Map<String, T> target,
    T Function(Map<String, dynamic>) decode,
  ) {
    if (raw == null) return;
    target.clear();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    decoded.forEach((key, value) {
      target[key] = decode(value as Map<String, dynamic>);
    });
  }

  Future<void> persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = currentUser;
      if (user == null) {
        await prefs.remove(_userKey);
      } else {
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
      }
      final profile = kycProfile;
      if (profile == null) {
        await prefs.remove(_kycKey);
      } else {
        await prefs.setString(_kycKey, jsonEncode(profile.toJson()));
      }
      await prefs.setString(
        _journalsKey,
        jsonEncode(journals.map((item) => item.toJson()).toList()),
      );
      await prefs.setString(
        _intentsKey,
        jsonEncode(paymentIntents.map((key, value) => MapEntry(key, value.toJson()))),
      );
      await prefs.setString(
        _receiptsKey,
        jsonEncode(receipts.map((key, value) => MapEntry(key, value.toJson()))),
      );
      await prefs.setString(
        _loansKey,
        jsonEncode(loans.map((key, value) => MapEntry(key, value.toJson()))),
      );
      await prefs.setString(
        _stakesKey,
        jsonEncode(stakes.map((key, value) => MapEntry(key, value.toJson()))),
      );
      await prefs.setString(
        _notificationsKey,
        jsonEncode(
          notifications.map((key, value) => MapEntry(key, value.toJson())),
        ),
      );
    } catch (_) {
      // Ignore: mock state still works for this session.
    }
  }

  Future<void> setUser(AppUser user) async {
    currentUser = user;
    await persist();
  }

  /// Writes the KYC profile and keeps the user's derived state in sync.
  Future<void> setKyc(KycProfile profile) async {
    kycProfile = profile;
    final user = currentUser;
    if (user != null) {
      currentUser = user.copyWith(kycState: profile.overallState);
    }
    await persist();
  }

  /// Clears only the signed-in identity. Mock ledgers and loans survive a
  /// Firebase sign-out so a different phone can sign in on the same device.
  Future<void> clearSession() async {
    currentUser = null;
    kycProfile = null;
    await persist();
  }

  Future<void> clear() async {
    currentUser = null;
    kycProfile = null;
    journals.clear();
    paymentIntents.clear();
    receipts.clear();
    loans.clear();
    stakes.clear();
    notifications.clear();
    await persist();
  }

  Future<void> setLoan(Loan loan) async {
    loans[loan.id] = loan;
    await persist();
  }

  Loan? loan(String id) => loans[id];

  List<Loan> loansFor(String borrowerId) => loans.values
      .where((loan) => loan.borrowerId == borrowerId)
      .toList(growable: false);

  Future<void> setStake(Stake stake) async {
    stakes[stake.id] = stake;
    await persist();
  }

  Stake? stake(String id) => stakes[id];

  Stake? stakeByKey(String idempotencyKey) {
    for (final stake in stakes.values) {
      if (stake.idempotencyKey == idempotencyKey) return stake;
    }
    return null;
  }

  List<Stake> stakesForLoan(String loanId) => stakes.values
      .where((stake) => stake.loanId == loanId)
      .toList(growable: false);

  List<Stake> stakesForLender(String lenderId) => stakes.values
      .where((stake) => stake.lenderId == lenderId)
      .toList(growable: false);

  Future<void> setNotification(AppNotification notification) async {
    notifications[notification.id] = notification;
    await persist();
  }

  AppNotification? notification(String id) => notifications[id];

  List<AppNotification> notificationsFor(String userId) {
    final items = notifications.values
        .where((item) => item.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<AppNotification>.unmodifiable(items);
  }

  int unreadCountFor(String userId) =>
      notificationsFor(userId).where((item) => item.isUnread).length;

  Future<int> markNotificationRead(String id, {DateTime? now}) async {
    final notification = notifications[id];
    if (notification == null || notification.isRead) return 0;
    await setNotification(
      notification.copyWith(readAt: now ?? DemoClock.instance.now),
    );
    return 1;
  }

  Future<int> markAllNotificationsRead(String userId, {DateTime? now}) async {
    final timestamp = now ?? DemoClock.instance.now;
    var changed = 0;
    for (final notification in notificationsFor(userId)) {
      if (notification.isRead) continue;
      await setNotification(notification.copyWith(readAt: timestamp));
      changed++;
    }
    return changed;
  }

  /// Current balance for one account, derived only from ledger entries.
  int balanceFor(String accountId) => journals
      .expand((journal) => journal.entries)
      .where((entry) => entry.accountId == accountId)
      .fold<int>(0, (total, entry) => total + entry.amountPaisa);

  JournalTransaction? journal(String id) {
    for (final journal in journals) {
      if (journal.id == id) return journal;
    }
    return null;
  }

  List<JournalTransaction> journalsFor(String accountId) => journals
      .where((journal) => journal.entries.any(
            (entry) => entry.accountId == accountId,
          ))
      .toList(growable: false);

  /// Appends a balanced journal. A repeated idempotency key returns the stored
  /// receipt with `replayed = true` and does not write a second journal.
  Future<PaymentReceipt> postJournal({
    required String journalId,
    required String paymentIntentId,
    required String idempotencyKey,
    required JournalKind kind,
    required PaymentIntentKind intentKind,
    required String userId,
    required String referenceId,
    required int amountPaisa,
    required List<LedgerEntry> entries,
    String? reversalOfId,
    DateTime? now,
    String provider = 'simulated',
  }) async {
    final existing = receipts[idempotencyKey];
    if (existing != null) return existing.copyWith(replayed: true);

    assertBalancedJournal(entries);
    if (entries.isEmpty) {
      throw const AppFailure(
        'validation_error',
        'A journal needs at least one entry.',
      );
    }

    final deltas = <String, int>{};
    for (final entry in entries) {
      deltas[entry.accountId] =
          (deltas[entry.accountId] ?? 0) + entry.amountPaisa;
    }
    for (final MapEntry(:key, :value) in deltas.entries) {
      if (LedgerAccount.isUserWallet(key) && balanceFor(key) + value < 0) {
        throw const AppFailure(
          'insufficient_balance',
          'Your wallet balance is too low.',
        );
      }
    }

    final timestamp = now ?? DemoClock.instance.now;
    final journal = JournalTransaction(
      id: journalId,
      kind: kind,
      referenceId: referenceId,
      idempotencyKey: idempotencyKey,
      createdAt: timestamp,
      entries: entries,
      reversalOfId: reversalOfId,
    );
    journals.add(journal);
    paymentIntents[paymentIntentId] = PaymentIntent(
      id: paymentIntentId,
      userId: userId,
      kind: intentKind,
      amountPaisa: amountPaisa,
      provider: provider,
      idempotencyKey: idempotencyKey,
      status: PaymentIntentStatus.succeeded,
      createdAt: timestamp,
      referenceId: referenceId,
      journalId: journalId,
    );
    final receipt = PaymentReceipt(
      id: journalId,
      journalId: journalId,
      paymentIntentId: paymentIntentId,
      idempotencyKey: idempotencyKey,
      kind: intentKind,
      amountPaisa: amountPaisa,
      createdAt: timestamp,
      referenceId: referenceId,
    );
    receipts[idempotencyKey] = receipt;
    await persist();
    return receipt;
  }
}
