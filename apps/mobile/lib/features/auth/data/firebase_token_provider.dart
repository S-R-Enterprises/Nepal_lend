import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Attaches the current Firebase ID token to API requests.
final firebaseIdTokenProvider = Provider<Future<String?> Function()>((ref) {
  return () async {
    if (Firebase.apps.isEmpty) return null;
    try {
      return await FirebaseAuth.instance.currentUser?.getIdToken();
    } catch (_) {
      // No signed-in user or plugin unavailable in tests.
      return null;
    }
  };
});
