import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';

void main() {
  test('user json round-trips role and KYC state', () {
    const user = AppUser(
      id: 'u-1',
      phone: '+9779800000000',
      name: 'Sita',
      role: UserRole.lender,
      kycState: KycStatus.verified,
    );

    final restored = AppUser.fromJson(user.toJson());

    expect(restored.id, user.id);
    expect(restored.phone, user.phone);
    expect(restored.role, UserRole.lender);
    expect(restored.kycState, KycStatus.verified);
    expect(restored.isVerified, isTrue);
    expect(restored.isActive, isTrue);
  });

  test('copyWith keeps identity fields', () {
    const user = AppUser(id: 'u-2', phone: '+9779800000001');
    final updated = user.copyWith(role: UserRole.borrower);
    expect(updated.id, 'u-2');
    expect(updated.phone, '+9779800000001');
    expect(updated.role, UserRole.borrower);
  });
}
