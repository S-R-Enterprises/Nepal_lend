class OtpChallenge {
  const OtpChallenge({
    required this.requestId,
    required this.maskedPhone,
    required this.expiresInSeconds,
  });

  final String requestId;
  final String maskedPhone;
  final int expiresInSeconds;

  factory OtpChallenge.fromJson(Map<String, dynamic> json) => OtpChallenge(
        requestId: json['requestId'] as String,
        maskedPhone: (json['maskedPhone'] ?? json['phone']) as String,
        expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt() ?? 120,
      );
}

class ApiUser {
  const ApiUser({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    required this.kycState,
  });

  final String id;
  final String phone;
  final String? name;
  final String role;
  final String kycState;

  factory ApiUser.fromJson(Map<String, dynamic> json) => ApiUser(
        id: json['id'] as String,
        phone: json['phone'] as String,
        name: json['name'] as String?,
        role: json['role'] as String? ?? 'borrower',
        kycState: json['kycState'] as String? ?? 'unstarted',
      );
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final bool isNewUser;
  final ApiUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        isNewUser: json['isNewUser'] as bool? ?? false,
        user: ApiUser.fromJson(json['user'] as Map<String, dynamic>),
      );
}
