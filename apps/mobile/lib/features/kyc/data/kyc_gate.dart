import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';

/// Provider-level gate for money-moving actions.
///
/// Loan requests and funding must call this before any state is changed. The
/// router hides the shells from unverified users, but the domain guard is the
/// enforcement point: a deep link, stale widget, or future screen cannot slip
/// through by bypassing navigation.
final requireVerifiedUserProvider = Provider<AppUser Function()>((ref) {
  return () {
    final user = ref.read(authProvider).user;
    if (user == null) {
      throw const AppFailure('unauthorized', 'Please sign in again.');
    }
    if (!user.isVerified) {
      throw const AppFailure(
        'kyc_required',
        'Complete verification before requesting or funding a loan.',
      );
    }
    return user;
  };
});
