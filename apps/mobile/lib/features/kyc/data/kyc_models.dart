class KycStep {
  const KycStep({
    required this.id,
    required this.label,
    required this.status,
    this.updatedAt,
  });

  final String id;
  final String label;
  final String status;
  final String? updatedAt;

  bool get isApproved => status == 'Approved';

  factory KycStep.fromJson(Map<String, dynamic> json) => KycStep(
        id: json['id'] as String,
        label: json['label'] as String,
        status: json['status'] as String,
        updatedAt: json['updatedAt'] as String?,
      );
}

class KycStatus {
  const KycStatus({required this.state, required this.steps});

  /// `unstarted` | `in_review` | `verified` | `rejected`
  final String state;
  final List<KycStep> steps;

  bool get isVerified => state == 'verified';
  int get approvedCount => steps.where((s) => s.isApproved).length;

  factory KycStatus.fromJson(Map<String, dynamic> json) => KycStatus(
        state: json['state'] as String,
        steps: (json['steps'] as List<dynamic>)
            .map((e) => KycStep.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
