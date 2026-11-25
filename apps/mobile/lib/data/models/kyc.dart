import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/models/enums.dart';

/// One of the four verification steps required before borrowing or funding.
extension KycStepInfo on KycStepKind {
  String get label => switch (this) {
        KycStepKind.citizenship => 'Citizenship document',
        KycStepKind.selfie => 'Selfie',
        KycStepKind.personalDetails => 'Personal details',
        KycStepKind.bankStatement => 'Bank statement',
      };

  String get description => switch (this) {
        KycStepKind.citizenship =>
          'Front and back of your citizenship certificate.',
        KycStepKind.selfie => 'A clear photo of your face.',
        KycStepKind.personalDetails =>
          'Name, citizenship number, date of birth and bank account.',
        KycStepKind.bankStatement =>
          'Latest statement or passbook page showing your name.',
      };

  bool get isDocument => this != KycStepKind.personalDetails;

  String get routeSegment => name;
}

/// Legal transitions for a single step. Verified is terminal; a rejected
/// step goes back to in_review on retry.
class KycTransitions {
  const KycTransitions._();

  static const Map<KycStatus, Set<KycStatus>> allowed = {
    KycStatus.notStarted: {KycStatus.inReview},
    KycStatus.inReview: {KycStatus.verified, KycStatus.rejected},
    KycStatus.rejected: {KycStatus.inReview},
  };

  static bool canTransition(KycStatus from, KycStatus to) =>
      allowed[from]?.contains(to) ?? false;

  static void check(KycStatus from, KycStatus to) {
    if (!canTransition(from, to)) {
      throw AppFailure(
        'invalid_transition',
        'Cannot move verification from ${from.name} to ${to.name}.',
      );
    }
  }
}

class KycStep {
  const KycStep({
    required this.kind,
    this.status = KycStatus.notStarted,
    this.documentPath,
    this.documentName,
    this.reason,
    this.submittedAt,
    this.reviewedAt,
  });

  final KycStepKind kind;
  final KycStatus status;
  final String? documentPath;
  final String? documentName;
  final String? reason;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  bool get isVerified => status == KycStatus.verified;
  bool get isInReview => status == KycStatus.inReview;
  bool get isRejected => status == KycStatus.rejected;
  bool get canSubmit =>
      status == KycStatus.notStarted || status == KycStatus.rejected;

  KycStep copyWith({
    KycStatus? status,
    String? documentPath,
    String? documentName,
    String? reason,
    bool clearReason = false,
    DateTime? submittedAt,
    DateTime? reviewedAt,
  }) {
    return KycStep(
      kind: kind,
      status: status ?? this.status,
      documentPath: documentPath ?? this.documentPath,
      documentName: documentName ?? this.documentName,
      reason: clearReason ? null : reason ?? this.reason,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'status': status.name,
        'documentPath': documentPath,
        'documentName': documentName,
        'reason': reason,
        'submittedAt': submittedAt?.toIso8601String(),
        'reviewedAt': reviewedAt?.toIso8601String(),
      };

  factory KycStep.fromJson(Map<String, dynamic> json) {
    return KycStep(
      kind: KycStepKind.values.firstWhere(
        (item) => item.name == json['kind'],
        orElse: () => KycStepKind.citizenship,
      ),
      status: KycStatus.values.firstWhere(
        (item) => item.name == json['status'],
        orElse: () => KycStatus.notStarted,
      ),
      documentPath: json['documentPath'] as String?,
      documentName: json['documentName'] as String?,
      reason: json['reason'] as String?,
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? ''),
      reviewedAt: DateTime.tryParse(json['reviewedAt'] as String? ?? ''),
    );
  }
}

/// The four steps plus any typed-in personal details. Overall verification is
/// derived from the steps — it is never stored independently.
class KycProfile {
  const KycProfile({
    required this.steps,
    this.details = const <String, String>{},
  });

  factory KycProfile.initial() => KycProfile(
        steps: KycStepKind.values
            .map((kind) => KycStep(kind: kind))
            .toList(growable: false),
      );

  final List<KycStep> steps;
  final Map<String, String> details;

  int get completedCount =>
      steps.where((step) => step.status == KycStatus.verified).length;

  bool get allVerified =>
      steps.length == KycStepKind.values.length && completedCount == steps.length;

  KycStatus get overallState {
    if (allVerified) return KycStatus.verified;
    if (steps.any((step) => step.isRejected)) return KycStatus.rejected;
    if (steps.any((step) => step.isInReview)) return KycStatus.inReview;
    return KycStatus.notStarted;
  }

  KycStep step(KycStepKind kind) =>
      steps.firstWhere((item) => item.kind == kind);

  KycProfile _withStep(KycStep updated) => KycProfile(
        steps: steps
            .map((item) => item.kind == updated.kind ? updated : item)
            .toList(growable: false),
        details: details,
      );

  /// Submit one step. Only not_started or rejected steps may be submitted.
  KycProfile submit(
    KycStepKind kind, {
    String? documentPath,
    String? documentName,
    Map<String, String>? newDetails,
    DateTime? now,
  }) {
    final current = step(kind);
    KycTransitions.check(current.status, KycStatus.inReview);
    if (kind.isDocument && (documentPath == null || documentPath.isEmpty)) {
      throw const AppFailure(
        'validation_error',
        'Capture or choose a document before submitting.',
      );
    }
    final updated = current.copyWith(
      status: KycStatus.inReview,
      documentPath: documentPath ?? current.documentPath,
      documentName: documentName ?? current.documentName,
      reason: null,
      clearReason: true,
      submittedAt: now ?? DateTime.now(),
    );
    return KycProfile(
      steps: steps
          .map((item) => item.kind == kind ? updated : item)
          .toList(growable: false),
      details: <String, String>{...details, ...?newDetails},
    );
  }

  /// Demo admin decision. In Track B this is an authenticated admin endpoint.
  KycProfile decide(
    KycStepKind kind,
    KycStatus decision, {
    String? reason,
    DateTime? now,
  }) {
    if (decision != KycStatus.verified && decision != KycStatus.rejected) {
      throw const AppFailure(
        'invalid_transition',
        'A decision must be verified or rejected.',
      );
    }
    final current = step(kind);
    KycTransitions.check(current.status, decision);
    if (decision == KycStatus.rejected &&
        (reason == null || reason.trim().isEmpty)) {
      throw const AppFailure(
        'validation_error',
        'Give a reason when rejecting a document.',
      );
    }
    return _withStep(current.copyWith(
      status: decision,
      reason: decision == KycStatus.rejected ? reason?.trim() : null,
      clearReason: decision == KycStatus.verified,
      reviewedAt: now ?? DateTime.now(),
    ));
  }

  /// Demo shortcut used by the mock checklist to reach a verified account.
  KycProfile approveAll({DateTime? now}) {
    var result = this;
    for (final kind in KycStepKind.values) {
      final current = result.step(kind);
      if (current.isVerified) continue;
      if (current.status == KycStatus.notStarted ||
          current.status == KycStatus.rejected) {
        result = result.submit(
          kind,
          documentPath: 'demo://${kind.name}',
          documentName: 'demo-${kind.name}',
          newDetails: kind == KycStepKind.personalDetails
              ? const {
                  'fullName': 'Demo User',
                  'citizenshipNumber': '000-00-000000',
                  'dateOfBirth': '2000-01-01',
                  'bankName': 'Demo Bank',
                  'accountNumber': '0000000000',
                }
              : null,
          now: now,
        );
      }
      result = result.decide(kind, KycStatus.verified, now: now);
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        'steps': steps.map((step) => step.toJson()).toList(),
        'details': details,
        'state': overallState.name,
        'completedCount': completedCount,
      };

  factory KycProfile.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'] as List<dynamic>? ?? const <dynamic>[];
    final restored = rawSteps
        .map((item) => KycStep.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    final byKind = <KycStepKind, KycStep>{
      for (final step in restored) step.kind: step,
    };
    final complete = KycStepKind.values
        .map((kind) => byKind[kind] ?? KycStep(kind: kind))
        .toList(growable: false);
    final rawDetails = json['details'] as Map<dynamic, dynamic>? ?? const {};
    return KycProfile(
      steps: complete,
      details: rawDetails.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
    );
  }
}
