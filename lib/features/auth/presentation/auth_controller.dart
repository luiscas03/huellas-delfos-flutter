import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_client.dart';
import '../data/auth_repository.dart';
import '../data/profile_repository.dart';

class AuthState {
  final Session? session;
  final bool loading;
  final String? error;

  const AuthState({this.session, this.loading = false, this.error});

  AuthState copyWith({Session? session, bool? loading, String? error}) {
    return AuthState(
      session: session ?? this.session,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo, this._profiles) : super(AuthState(session: _repo.currentSession));

  final AuthRepository _repo;
  final ProfileRepository _profiles;

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final res = await _repo.signInWithPassword(email: email, password: password);
      final user = res.user;
      if (user != null) {
        final profile = await _profiles.getProfile(user.id);
        if (profile == null) {
          final visitor = await _profiles.getVisitorByEmail(user.email ?? '');
          await _profiles.createProfile(
            userId: user.id,
            email: user.email ?? email,
            fullName: visitor?['full_name'] as String?,
          );
        }
      }
      state = state.copyWith(session: res.session, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final res = await _repo.signUp(email: email, password: password);
      state = state.copyWith(session: res.session, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.resetPasswordViaEdge(email);
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.signInWithGoogle();
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = state.copyWith(session: null);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(supabaseProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.read(supabaseProvider));
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authRepositoryProvider), ref.read(profileRepositoryProvider));
});
