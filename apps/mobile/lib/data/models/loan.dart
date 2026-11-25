import 'package:nepal_lend/core/utils/demo_clock.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/models/enums.dart';

/// Legal loan transitions. Rejected, expired, cancelled, repaid and defaulted
/// are terminal. Agreement signing moves `open → funded → active`.
class LoanTransitions {
  const LoanTransitions._();

  static const Map<LoanStatus, Set<LoanStatus>> allowed = {
    LoanStatus.draft: {LoanStatus.pendingReview, LoanStatus.open},
    LoanStatus.pendingReview: {LoanStatus.open, LoanStatus.rejected},
    LoanStatus.open: {LoanStatus.funded, LoanStatus.expired, LoanStatus.cancelled},
    LoanStatus.funded: {LoanStatus.active, LoanStatus.cancelled},
    LoanStatus.active: {
      LoanStatus.repaid,
      LoanStatus.overdue,
      LoanStatus.defaulted,
    },
    LoanStatus.overdue: {LoanStatus.active, LoanStatus.defaulted},
  };

  static bool canTransition(LoanStatus from, LoanStatus to) =>
      allowed[from]?.contains(to) ?? false;

  static void check(LoanStatus from, LoanStatus to) {
    if (!canTransition(from, to)) {
      throw AppFailure(
        'invalid_transition',
        'Cannot move a loan from ${from.name} to ${to.name}.',
      );
    }
  }
}

enum RiskDirection { positive, neutral, negative }

class RiskFactor {
  const RiskFactor({
    required this.name,
    required this.direction,
    required this.note,
  });

  final String name;
  final RiskDirection direction;
  final String note;

  RiskFactor copyWith({String? name, RiskDirection? direction, String? note}) =>
      RiskFactor(
        name: name ?? this.name,
        direction: direction ?? this.direction,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'direction': direction.name,
        'note': note,
      };

  factory RiskFactor.fromJson(Map<String, dynamic> json) => RiskFactor(
        name: json['name'] as String? ?? '',
        direction: RiskDirection.values.firstWhere(
          (value) => value.name == json['direction'],
          orElse: () => RiskDirection.neutral,
        ),
        note: json['note'] as String? ?? '',
      );
}

class RiskAssessment {
  const RiskAssessment({
    required this.score,
    required this.grade,
    required this.band,
    required this.rateBps,
    required this.factors,
    this.modelVersion = 'v1',
    this.requiresReview = false,
  });

  final int score;
  final String grade;
  final RiskBand band;
  final int rateBps;
  final List<RiskFactor> factors;
  final String modelVersion;
  final bool requiresReview;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'score': score,
        'grade': grade,
        'band': band.name,
        'rateBps': rateBps,
        'factors': factors.map((factor) => factor.toJson()).toList(),
        'modelVersion': modelVersion,
        'requiresReview': requiresReview,
      };

  factory RiskAssessment.fromJson(Map<String, dynamic> json) => RiskAssessment(
        score: (json['score'] as num?)?.toInt() ?? 0,
        grade: json['grade'] as String? ?? 'D',
        band: RiskBand.values.firstWhere(
          (value) => value.name == json['band'],
          orElse: () => RiskBand.high,
        ),
        rateBps: (json['rateBps'] as num?)?.toInt() ?? 0,
        factors: (json['factors'] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (item) => RiskFactor.fromJson(item as Map<String, dynamic>),
            )
            .toList(growable: false),
        modelVersion: json['modelVersion'] as String? ?? 'v1',
        requiresReview: json['requiresReview'] as bool? ?? false,
      );
}

class Agreement {
  const Agreement({
    required this.id,
    required this.loanId,
    required this.termsVersion,
    required this.termsHash,
    required this.signedBy,
    required this.signedAt,
    required this.disbursementJournalId,
  });

  final String id;
  final String loanId;
  final String termsVersion;
  final String termsHash;
  final String signedBy;
  final DateTime signedAt;
  final String disbursementJournalId;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'loanId': loanId,
        'termsVersion': termsVersion,
        'termsHash': termsHash,
        'signedBy': signedBy,
        'signedAt': signedAt.toIso8601String(),
        'disbursementJournalId': disbursementJournalId,
      };

  factory Agreement.fromJson(Map<String, dynamic> json) => Agreement(
        id: json['id'] as String,
        loanId: json['loanId'] as String,
        termsVersion: json['termsVersion'] as String? ?? 'v1',
        termsHash: json['termsHash'] as String? ?? '',
        signedBy: json['signedBy'] as String? ?? '',
        signedAt: DateTime.tryParse(json['signedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        disbursementJournalId: json['disbursementJournalId'] as String? ?? '',
      );
}

class Loan {
  const Loan({
    required this.id,
    required this.borrowerId,
    required this.purpose,
    required this.amountPaisa,
    required this.tenorMonths,
    required this.rateBps,
    required this.status,
    this.borrowerName,
    this.monthlyIncomePaisa = 0,
    this.fundedPaisa = 0,
    this.riskGrade,
    this.riskBand,
    this.assessment,
    this.agreement,
    this.instalments = const <Instalment>[],
    this.fundingDeadline,
    this.createdAt,
    this.fundedAt,
    this.lastRepaymentAt,
  });

  final String id;
  final String borrowerId;
  final String purpose;
  final int amountPaisa;
  final int tenorMonths;
  final int rateBps;
  final LoanStatus status;
  final String? borrowerName;
  final int monthlyIncomePaisa;
  final int fundedPaisa;
  final String? riskGrade;
  final RiskBand? riskBand;
  final RiskAssessment? assessment;
  final Agreement? agreement;
  final List<Instalment> instalments;
  final DateTime? fundingDeadline;
  final DateTime? createdAt;
  final DateTime? fundedAt;
  final DateTime? lastRepaymentAt;

  int get remainingPaisa => amountPaisa - fundedPaisa;

  /// The earliest unpaid instalment. Repayments always target this row so a
  /// borrower cannot skip ahead while an older instalment is still due.
  Instalment? get nextInstalment {
    final unpaid = instalments.where((item) => !item.isPaid).toList()
      ..sort((a, b) => a.number.compareTo(b.number));
    return unpaid.isEmpty ? null : unpaid.first;
  }

  int get paidInstalmentCount =>
      instalments.where((item) => item.isPaid).length;

  bool get isFullyRepaid =>
      instalments.isNotEmpty && paidInstalmentCount == instalments.length;

  /// Only used by the progress widget, never for ledger or money maths.
  double get fundingProgress =>
      amountPaisa == 0 ? 0 : (fundedPaisa / amountPaisa).clamp(0, 1);

  bool isDeadlinePassed(DateTime now) =>
      fundingDeadline != null && now.isAfter(fundingDeadline!);

  bool get canFund =>
      status == LoanStatus.open &&
      remainingPaisa > 0 &&
      !isDeadlinePassed(DemoClock.instance.now);

  /// Signing is only valid after lenders have filled the escrow. Phase 5
  /// simulated escrow; Phase 6 makes funding the only path to `funded`.
  bool get canSign =>
      agreement == null &&
      status == LoanStatus.funded &&
      fundedPaisa >= amountPaisa;
  bool get needsReview => assessment?.requiresReview ?? false;

  Loan copyWith({
    String? purpose,
    int? amountPaisa,
    int? tenorMonths,
    int? rateBps,
    LoanStatus? status,
    String? borrowerName,
    int? monthlyIncomePaisa,
    int? fundedPaisa,
    String? riskGrade,
    RiskBand? riskBand,
    RiskAssessment? assessment,
    Agreement? agreement,
    List<Instalment>? instalments,
    DateTime? fundingDeadline,
    DateTime? createdAt,
    DateTime? fundedAt,
    DateTime? lastRepaymentAt,
    bool clearLastRepaymentAt = false,
  }) =>
      Loan(
        id: id,
        borrowerId: borrowerId,
        purpose: purpose ?? this.purpose,
        amountPaisa: amountPaisa ?? this.amountPaisa,
        tenorMonths: tenorMonths ?? this.tenorMonths,
        rateBps: rateBps ?? this.rateBps,
        status: status ?? this.status,
        borrowerName: borrowerName ?? this.borrowerName,
        monthlyIncomePaisa: monthlyIncomePaisa ?? this.monthlyIncomePaisa,
        fundedPaisa: fundedPaisa ?? this.fundedPaisa,
        riskGrade: riskGrade ?? this.riskGrade,
        riskBand: riskBand ?? this.riskBand,
        assessment: assessment ?? this.assessment,
        agreement: agreement ?? this.agreement,
        instalments: instalments ?? this.instalments,
        fundingDeadline: fundingDeadline ?? this.fundingDeadline,
        createdAt: createdAt ?? this.createdAt,
        fundedAt: fundedAt ?? this.fundedAt,
        lastRepaymentAt:
            clearLastRepaymentAt ? null : lastRepaymentAt ?? this.lastRepaymentAt,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'borrowerId': borrowerId,
        'purpose': purpose,
        'amountPaisa': amountPaisa,
        'tenorMonths': tenorMonths,
        'rateBps': rateBps,
        'status': status.name,
        'borrowerName': borrowerName,
        'monthlyIncomePaisa': monthlyIncomePaisa,
        'fundedPaisa': fundedPaisa,
        'riskGrade': riskGrade,
        'riskBand': riskBand?.name,
        'assessment': assessment?.toJson(),
        'agreement': agreement?.toJson(),
        'instalments': instalments.map((item) => item.toJson()).toList(),
        'fundingDeadline': fundingDeadline?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'fundedAt': fundedAt?.toIso8601String(),
        'lastRepaymentAt': lastRepaymentAt?.toIso8601String(),
      };

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
        id: json['id'] as String,
        borrowerId: json['borrowerId'] as String,
        purpose: json['purpose'] as String? ?? '',
        amountPaisa: (json['amountPaisa'] as num?)?.toInt() ?? 0,
        tenorMonths: (json['tenorMonths'] as num?)?.toInt() ?? 0,
        rateBps: (json['rateBps'] as num?)?.toInt() ?? 0,
        status: LoanStatus.values.firstWhere(
          (value) => value.name == json['status'],
          orElse: () => LoanStatus.draft,
        ),
        borrowerName: json['borrowerName'] as String?,
        monthlyIncomePaisa:
            (json['monthlyIncomePaisa'] as num?)?.toInt() ?? 0,
        fundedPaisa: (json['fundedPaisa'] as num?)?.toInt() ?? 0,
        riskGrade: json['riskGrade'] as String?,
        riskBand: json['riskBand'] == null
            ? null
            : RiskBand.values.firstWhere(
                (value) => value.name == json['riskBand'],
                orElse: () => RiskBand.high,
              ),
        assessment: json['assessment'] == null
            ? null
            : RiskAssessment.fromJson(
                json['assessment'] as Map<String, dynamic>,
              ),
        agreement: json['agreement'] == null
            ? null
            : Agreement.fromJson(json['agreement'] as Map<String, dynamic>),
        instalments: (json['instalments'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => Instalment.fromJson(item as Map<String, dynamic>))
            .toList(growable: false),
        fundingDeadline:
            DateTime.tryParse(json['fundingDeadline'] as String? ?? ''),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        fundedAt: DateTime.tryParse(json['fundedAt'] as String? ?? ''),
        lastRepaymentAt:
            DateTime.tryParse(json['lastRepaymentAt'] as String? ?? ''),
      );
}

class Stake {
  const Stake({
    required this.id,
    required this.loanId,
    required this.lenderId,
    required this.amountPaisa,
    required this.idempotencyKey,
    required this.fundingJournalId,
    this.status = 'active',
    this.createdAt,
    this.returnedAt,
    this.reversalJournalId,
    this.principalRepaidPaisa = 0,
    this.interestRepaidPaisa = 0,
    this.feePaidPaisa = 0,
    this.lastRepaymentJournalId,
  });

  final String id;
  final String loanId;
  final String lenderId;
  final int amountPaisa;
  final String idempotencyKey;
  final String fundingJournalId;
  final String status;
  final DateTime? createdAt;
  final DateTime? returnedAt;
  final String? reversalJournalId;
  final int principalRepaidPaisa;
  final int interestRepaidPaisa;
  final int feePaidPaisa;
  final String? lastRepaymentJournalId;

  bool get isActive => status == 'active';
  bool get isReturned => status == 'returned';

  /// Cash the lender has actually received, net of the platform fee.
  int get netRepaidPaisa =>
      principalRepaidPaisa + interestRepaidPaisa - feePaidPaisa;

  /// Principal capital that is still outstanding on this stake.
  int get outstandingPaisa => amountPaisa - principalRepaidPaisa;

  Stake copyWith({
    String? status,
    DateTime? returnedAt,
    String? reversalJournalId,
    int? principalRepaidPaisa,
    int? interestRepaidPaisa,
    int? feePaidPaisa,
    String? lastRepaymentJournalId,
  }) =>
      Stake(
        id: id,
        loanId: loanId,
        lenderId: lenderId,
        amountPaisa: amountPaisa,
        idempotencyKey: idempotencyKey,
        fundingJournalId: fundingJournalId,
        status: status ?? this.status,
        createdAt: createdAt,
        returnedAt: returnedAt ?? this.returnedAt,
        reversalJournalId: reversalJournalId ?? this.reversalJournalId,
        principalRepaidPaisa:
            principalRepaidPaisa ?? this.principalRepaidPaisa,
        interestRepaidPaisa: interestRepaidPaisa ?? this.interestRepaidPaisa,
        feePaidPaisa: feePaidPaisa ?? this.feePaidPaisa,
        lastRepaymentJournalId:
            lastRepaymentJournalId ?? this.lastRepaymentJournalId,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'loanId': loanId,
        'lenderId': lenderId,
        'amountPaisa': amountPaisa,
        'idempotencyKey': idempotencyKey,
        'fundingJournalId': fundingJournalId,
        'status': status,
        'createdAt': createdAt?.toIso8601String(),
        'returnedAt': returnedAt?.toIso8601String(),
        'reversalJournalId': reversalJournalId,
        'principalRepaidPaisa': principalRepaidPaisa,
        'interestRepaidPaisa': interestRepaidPaisa,
        'feePaidPaisa': feePaidPaisa,
        'lastRepaymentJournalId': lastRepaymentJournalId,
      };

  factory Stake.fromJson(Map<String, dynamic> json) => Stake(
        id: json['id'] as String,
        loanId: json['loanId'] as String,
        lenderId: json['lenderId'] as String,
        amountPaisa: (json['amountPaisa'] as num?)?.toInt() ?? 0,
        idempotencyKey: json['idempotencyKey'] as String? ?? '',
        fundingJournalId: json['fundingJournalId'] as String? ?? '',
        status: json['status'] as String? ?? 'active',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        returnedAt: DateTime.tryParse(json['returnedAt'] as String? ?? ''),
        reversalJournalId: json['reversalJournalId'] as String?,
        principalRepaidPaisa:
            (json['principalRepaidPaisa'] as num?)?.toInt() ?? 0,
        interestRepaidPaisa:
            (json['interestRepaidPaisa'] as num?)?.toInt() ?? 0,
        feePaidPaisa: (json['feePaidPaisa'] as num?)?.toInt() ?? 0,
        lastRepaymentJournalId: json['lastRepaymentJournalId'] as String?,
      );
}

class Instalment {
  const Instalment({
    required this.id,
    required this.loanId,
    required this.number,
    required this.dueDate,
    required this.principalPaisa,
    required this.interestPaisa,
    this.status = 'due',
    this.paidAt,
    this.paymentJournalId,
    this.paymentProvider,
  });

  final String id;
  final String loanId;
  final int number;
  final DateTime dueDate;
  final int principalPaisa;
  final int interestPaisa;
  final String status;
  final DateTime? paidAt;
  final String? paymentJournalId;
  final String? paymentProvider;

  int get totalPaisa => principalPaisa + interestPaisa;

  bool get isPaid => status == 'paid';

  Instalment copyWith({
    String? status,
    DateTime? paidAt,
    String? paymentJournalId,
    String? paymentProvider,
  }) =>
      Instalment(
        id: id,
        loanId: loanId,
        number: number,
        dueDate: dueDate,
        principalPaisa: principalPaisa,
        interestPaisa: interestPaisa,
        status: status ?? this.status,
        paidAt: paidAt ?? this.paidAt,
        paymentJournalId: paymentJournalId ?? this.paymentJournalId,
        paymentProvider: paymentProvider ?? this.paymentProvider,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'loanId': loanId,
        'number': number,
        'dueDate': dueDate.toIso8601String(),
        'principalPaisa': principalPaisa,
        'interestPaisa': interestPaisa,
        'status': status,
        'paidAt': paidAt?.toIso8601String(),
        'paymentJournalId': paymentJournalId,
        'paymentProvider': paymentProvider,
      };

  factory Instalment.fromJson(Map<String, dynamic> json) => Instalment(
        id: json['id'] as String,
        loanId: json['loanId'] as String,
        number: (json['number'] as num?)?.toInt() ?? 0,
        dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        principalPaisa: (json['principalPaisa'] as num?)?.toInt() ?? 0,
        interestPaisa: (json['interestPaisa'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? 'due',
        paidAt: DateTime.tryParse(json['paidAt'] as String? ?? ''),
        paymentJournalId: json['paymentJournalId'] as String?,
        paymentProvider: json['paymentProvider'] as String?,
      );
}
