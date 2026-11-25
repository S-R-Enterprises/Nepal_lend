import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simulated screen state used by the mock-only state switcher.
///
/// Production builds never watch this provider, so the four states always come
/// from real async data instead of a manual override.
enum DemoUiState { normal, loading, empty, error, offline }

class DemoUiStateController extends Notifier<DemoUiState> {
  @override
  DemoUiState build() => DemoUiState.normal;

  void select(DemoUiState next) => state = next;
}

final demoUiStateProvider =
    NotifierProvider<DemoUiStateController, DemoUiState>(
      DemoUiStateController.new,
    );
