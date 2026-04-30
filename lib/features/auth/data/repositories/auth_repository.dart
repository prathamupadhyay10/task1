import '../../../../models/app_user.dart';
import '../../../../services/auth_service.dart';

abstract class AuthRepository {
  Future<AppUser> signIn(String email, String password);
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    String role,
  });
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
  Stream<AppUser?> get authStateChanges;
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({AuthService? authService})
      : _authService = authService ?? AuthService();

  @override
  Future<AppUser> signIn(String email, String password) {
    return _authService.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'user',
  }) {
    return _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      role: role,
    );
  }

  @override
  Future<void> signOut() => _authService.signOut();

  @override
  Future<AppUser?> getCurrentUser() => _authService.getCurrentUserData();

  @override
  Stream<AppUser?> get authStateChanges {
    return _authService.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      return _authService.getCurrentUserData();
    });
  }
}
