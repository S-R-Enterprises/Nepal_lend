import 'package:nepal_lend/data/models/enums.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.role,
    this.kycState = KycStatus.notStarted,
    this.status = AccountStatus.active,
    this.avatarPath,
    this.firebaseUid,
  });

  final String id;
  final String phone;
  final String? name;
  final String? email;
  final UserRole? role;
  final KycStatus kycState;
  final AccountStatus status;
  final String? avatarPath;
  final String? firebaseUid;

  bool get isVerified => kycState == KycStatus.verified;
  bool get isActive => status == AccountStatus.active;

  AppUser copyWith({
    String? name,
    String? email,
    UserRole? role,
    KycStatus? kycState,
    AccountStatus? status,
    String? avatarPath,
  }) {
    return AppUser(
      id: id,
      phone: phone,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      kycState: kycState ?? this.kycState,
      status: status ?? this.status,
      avatarPath: avatarPath ?? this.avatarPath,
      firebaseUid: firebaseUid,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'name': name,
        'email': email,
        'role': role?.name,
        'kycState': kycState.name,
        'status': status.name,
        'avatarPath': avatarPath,
        'firebaseUid': firebaseUid,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: _enum<UserRole>(json['role'], UserRole.values),
      kycState: _enum<KycStatus>(json['kycState'], KycStatus.values) ??
          KycStatus.notStarted,
      status: _enum<AccountStatus>(json['status'], AccountStatus.values) ??
          AccountStatus.active,
      avatarPath: json['avatarPath'] as String?,
      firebaseUid: json['firebaseUid'] as String?,
    );
  }

  static T? _enum<T extends Enum>(Object? value, List<T> values) {
    if (value == null) return null;
    for (final item in values) {
      if (item.name == value) return item;
    }
    return null;
  }
}
