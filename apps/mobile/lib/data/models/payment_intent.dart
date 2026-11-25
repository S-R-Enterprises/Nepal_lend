import 'package:nepal_lend/data/models/enums.dart';

enum PaymentIntentKind { topup, withdrawal, repayment }

enum PaymentIntentStatus { pending, succeeded, failed }

/// A recorded request to move money. The idempotency key is the client's
/// guarantee that retrying a money action cannot post a second journal.
class PaymentIntent {
  const PaymentIntent({
    required this.id,
    required this.userId,
    required this.kind,
    required this.amountPaisa,
    required this.provider,
    required this.idempotencyKey,
    required this.status,
    required this.createdAt,
    this.referenceId,
    this.journalId,
  });

  final String id;
  final String userId;
  final PaymentIntentKind kind;
  final int amountPaisa;
  final String provider;
  final String idempotencyKey;
  final PaymentIntentStatus status;
  final DateTime createdAt;
  final String? referenceId;
  final String? journalId;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'kind': kind.name,
        'amountPaisa': amountPaisa,
        'provider': provider,
        'idempotencyKey': idempotencyKey,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'referenceId': referenceId,
        'journalId': journalId,
      };

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    PaymentIntentKind kind = PaymentIntentKind.topup;
    for (final value in PaymentIntentKind.values) {
      if (value.name == json['kind']) kind = value;
    }
    PaymentIntentStatus status = PaymentIntentStatus.pending;
    for (final value in PaymentIntentStatus.values) {
      if (value.name == json['status']) status = value;
    }
    return PaymentIntent(
      id: json['id'] as String,
      userId: json['userId'] as String,
      kind: kind,
      amountPaisa: (json['amountPaisa'] as num).toInt(),
      provider: json['provider'] as String? ?? 'simulated',
      idempotencyKey: json['idempotencyKey'] as String,
      status: status,
      createdAt: DateTime.parse(json['createdAt'] as String),
      referenceId: json['referenceId'] as String?,
      journalId: json['journalId'] as String?,
    );
  }
}

/// Returned after a successful money move. `replayed` is true when the same
/// idempotency key was seen before, so the caller can show the original receipt
/// without creating a second journal.
class PaymentReceipt {
  const PaymentReceipt({
    required this.id,
    required this.journalId,
    required this.paymentIntentId,
    required this.idempotencyKey,
    required this.kind,
    required this.amountPaisa,
    required this.createdAt,
    this.referenceId,
    this.replayed = false,
  });

  final String id;
  final String journalId;
  final String paymentIntentId;
  final String idempotencyKey;
  final PaymentIntentKind kind;
  final int amountPaisa;
  final DateTime createdAt;
  final String? referenceId;
  final bool replayed;

  PaymentReceipt copyWith({bool? replayed}) => PaymentReceipt(
        id: id,
        journalId: journalId,
        paymentIntentId: paymentIntentId,
        idempotencyKey: idempotencyKey,
        kind: kind,
        amountPaisa: amountPaisa,
        createdAt: createdAt,
        referenceId: referenceId,
        replayed: replayed ?? this.replayed,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'journalId': journalId,
        'paymentIntentId': paymentIntentId,
        'idempotencyKey': idempotencyKey,
        'kind': kind.name,
        'amountPaisa': amountPaisa,
        'createdAt': createdAt.toIso8601String(),
        'referenceId': referenceId,
        'replayed': replayed,
      };

  factory PaymentReceipt.fromJson(Map<String, dynamic> json) {
    PaymentIntentKind kind = PaymentIntentKind.topup;
    for (final value in PaymentIntentKind.values) {
      if (value.name == json['kind']) kind = value;
    }
    return PaymentReceipt(
      id: json['id'] as String,
      journalId: json['journalId'] as String,
      paymentIntentId: json['paymentIntentId'] as String,
      idempotencyKey: json['idempotencyKey'] as String,
      kind: kind,
      amountPaisa: (json['amountPaisa'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      referenceId: json['referenceId'] as String?,
      replayed: json['replayed'] as bool? ?? false,
    );
  }

  JournalKind get journalKind => switch (kind) {
        PaymentIntentKind.topup => JournalKind.topup,
        PaymentIntentKind.withdrawal => JournalKind.withdrawal,
        PaymentIntentKind.repayment => JournalKind.repayment,
      };
}
