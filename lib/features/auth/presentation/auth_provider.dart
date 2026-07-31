import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

// 1. Auth States
sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// 2. AuthRepository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// // 3. AuthNotifier Class
// class AuthNotifier extends Notifier<AuthState> {
//   late final AuthRepository _repository;

//   @override
//   AuthState build() {
//     _repository = ref.watch(authRepositoryProvider);
    
//     // Check saved session
//     final savedUser = _repository.getSavedUser();
//     if (savedUser != null) {
//       return AuthSuccess(savedUser);
//     }
//     return AuthInitial();
//   }

//   // Sign In
//   Future<void> login(String email, String password) async {
//     state = AuthLoading();
//     try {
//       final user = await _repository.login(email, password);
//       state = AuthSuccess(user);
//     } catch (e) {
//       state = AuthError(e.toString().replaceAll('Exception: ', ''));
//     }
//   }

//   // Register
//   Future<void> register({
//     required String name,
//     required String email,
//     required String password,
//     required String hospitalId,
//   }) async {
//     state = AuthLoading();
//     try {
//       final user = await _repository.register(
//         name: name,
//         email: email,
//         password: password,
//         hospitalId: hospitalId,
//       );
//       state = AuthSuccess(user);
//     } catch (e) {
//       state = AuthError(e.toString().replaceAll('Exception: ', ''));
//     }
//   }

//   // Sign Out
//   Future<void> logout() async {
//     await _repository.logout();
//     state = AuthInitial();
//   }
// }
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);

    final savedUser = _repository.getSavedUser();
    if (savedUser != null) {
      // Trust the cached session immediately, verify with the server after.
      Future.microtask(_validateSavedSession);
      return AuthSuccess(savedUser);
    }
    return AuthInitial();
  }

  Future<void> _validateSavedSession() async {
    try {
      final user = await _repository.validateSession();
      if (user != null) {
        // Refresh in case role/name changed server-side since last login.
        if (state is AuthSuccess) {
          state = AuthSuccess(user);
        }
      } else {
        // Token was rejected by the server — repository already cleared Hive.
        if (state is AuthSuccess) {
          state = AuthInitial();
        }
      }
    } catch (_) {
      // Never let a background check crash or disrupt the current session.
    }
  }

   // Sign In
  Future<void> login(String email, String password) async {
    state = AuthLoading();
    try {
      final user = await _repository.login(email, password);
      state = AuthSuccess(user);
    } catch (e) {
      state = AuthError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Register
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String hospitalId,
  }) async {
    state = AuthLoading();
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
        hospitalId: hospitalId,
      );
      state = AuthSuccess(user);
    } catch (e) {
      state = AuthError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Sign Out
  Future<void> logout() async {
    await _repository.logout();
    state = AuthInitial();
  }
}
// 4. AuthProvider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);