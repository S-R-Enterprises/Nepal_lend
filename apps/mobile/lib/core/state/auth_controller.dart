import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../routes.dart';

/// Holds the signed-in user's [UserRole] and persists it across launches.
///
/// Replaces the former global mutable `Session.role` static.
class AuthController extends Notifier<UserRole> {
  static const _roleKey = 'session.role';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  UserRole build() {
    _restore();
    return UserRole.borrower;
  }

  Future<void> _restore() async {
    try {
      final stored = await _storage.read(key: _roleKey);
      if (stored == null) return;
      final role = UserRole.values.cast<UserRole?>().firstWhere(
            (r) => r!.name == stored,
            orElse: () => null,
          );
      if (role != null) state = role;
    } catch (_) {
      // Storage unavailable (tests, missing plugin) — keep the default.
    }
  }

  Future<void> setRole(UserRole role) async {
    state = role;
    try {
      await _storage.write(key: _roleKey, value: role.name);
    } catch (_) {
      // Persistence is best-effort; in-memory state is already correct.
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, UserRole>(AuthController.new);
