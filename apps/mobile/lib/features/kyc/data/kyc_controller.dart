import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/kyc/data/document_picker.dart';
import 'package:nepal_lend/features/kyc/data/kyc_repository.dart';

class KycState {
  const KycState({
    required this.profile,
    this.isBusy = false,
    this.uploading = false,
    this.error,
  });

  final KycProfile profile;
  final bool isBusy;
  final bool uploading;
  final String? error;

  KycState copyWith({
    KycProfile? profile,
    bool? isBusy,
    bool? uploading,
    String? error,
    bool clearError = false,
  }) {
    return KycState(
      profile: profile ?? this.profile,
      isBusy: isBusy ?? this.isBusy,
      uploading: uploading ?? this.uploading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// Holds the checklist state and keeps the router's auth snapshot in sync
/// when verification changes.
class KycController extends Notifier<KycState> {
  @override
  KycState build() => KycState(profile: KycProfile.initial());

  KycRepository get _repository => ref.read(kycRepositoryProvider);

  Future<void> load() async {
    state = state.copyWith(isBusy: true, clearError: true);
    await _run(() => _repository.load(), uploading: false);
  }

  Future<bool> submitDocument(
    KycStepKind kind, {
    required PickedDocument document,
  }) async {
    state = state.copyWith(uploading: true, clearError: true);
    return _run(
      () => _repository.submitDocument(kind, document: document),
      uploading: true,
    );
  }

  Future<bool> submitPersonalDetails(Map<String, String> details) async {
    state = state.copyWith(uploading: true, clearError: true);
    return _run(
      () => _repository.submitPersonalDetails(details),
      uploading: true,
    );
  }

  Future<bool> decide(
    KycStepKind kind,
    KycStatus decision, {
    String? reason,
  }) async {
    state = state.copyWith(isBusy: true, clearError: true);
    return _run(
      () => _repository.decide(kind, decision, reason: reason),
      uploading: false,
    );
  }

  Future<bool> approveAll() async {
    state = state.copyWith(isBusy: true, clearError: true);
    return _run(() => _repository.approveAll(), uploading: false);
  }

  void clearError() => state = state.copyWith(clearError: true);

  Future<bool> _run(
    Future<KycProfile> Function() action, {
    required bool uploading,
  }) async {
    try {
      final profile = await action();
      state = KycState(profile: profile);
      await ref.read(authProvider.notifier).refresh();
      return true;
    } on AppFailure catch (failure) {
      state = KycState(
        profile: state.profile,
        error: failure.message,
        uploading: uploading,
      );
      return false;
    }
  }
}

final kycProvider = NotifierProvider<KycController, KycState>(KycController.new);
