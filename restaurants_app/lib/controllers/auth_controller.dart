import 'package:rxdart/rxdart.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_local_storage_service.dart';
import '../utils/validators.dart';

class AuthController {
  AuthController({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  final BehaviorSubject<bool> _loadingSubject = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String?> _errorSubject = BehaviorSubject<String?>.seeded(null);
  final BehaviorSubject<User?> _currentUserSubject = BehaviorSubject<User?>.seeded(null);
  final BehaviorSubject<bool> _loginSuccessSubject =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> _signupSuccessSubject =
      BehaviorSubject<bool>.seeded(false);

  ValueStream<bool> get loadingStream => _loadingSubject.stream;
  ValueStream<String?> get errorStream => _errorSubject.stream;
  ValueStream<User?> get currentUserStream => _currentUserSubject.stream;
  ValueStream<bool> get loginSuccessStream => _loginSuccessSubject.stream;
  ValueStream<bool> get signupSuccessStream => _signupSuccessSubject.stream;

  Future<bool> login({required String email, required String password}) async {
    if (!Validators.isValidEmail(email)) {
      _errorSubject.add('Please enter a valid email address.');
      return false;
    }
    if (!Validators.isValidPassword(password)) {
      _errorSubject.add('Password must be at least 8 characters.');
      return false;
    }

    _loadingSubject.add(true);
    _errorSubject.add(null);
    _loginSuccessSubject.add(false);

    final response = await _apiService.login(email: email, password: password);
    _loadingSubject.add(false);

    if (response.isSuccess && response.data != null) {
      final user = response.data!;
      _currentUserSubject.add(user);
      await AuthLocalStorageService.saveLoggedInUser(user);
      _loginSuccessSubject.add(true);
      return true;
    }

    _errorSubject.add(response.error ?? 'Login failed');
    _loginSuccessSubject.add(false);
    return false;
  }

  Future<bool> signup({
    required String name,
    String? gender,
    required String email,
    int? level,
    required String password,
  }) async {
    if (name.trim().isEmpty) {
      _errorSubject.add('Name is required.');
      return false;
    }
    if (!Validators.isValidEmail(email)) {
      _errorSubject.add('Please enter a valid email address.');
      return false;
    }
    if (!Validators.isValidPassword(password)) {
      _errorSubject.add('Password must be at least 8 characters.');
      return false;
    }

    _loadingSubject.add(true);
    _errorSubject.add(null);
    _signupSuccessSubject.add(false);

    final response = await _apiService.signup(
      name: name,
      gender: gender,
      email: email,
      level: level,
      password: password,
    );
    _loadingSubject.add(false);

    if (response.isSuccess && response.data != null) {
      _currentUserSubject.add(response.data);
      _signupSuccessSubject.add(true);
      return true;
    }

    _errorSubject.add(response.error ?? 'Signup failed');
    _signupSuccessSubject.add(false);
    return false;
  }

  Future<void> logout() async {
    await AuthLocalStorageService.clearSession();
    _currentUserSubject.add(null);
    _loginSuccessSubject.add(false);
    _signupSuccessSubject.add(false);
  }

  Future<bool> restoreSession() async {
    final user = await AuthLocalStorageService.getStoredUser();
    if (user == null) return false;
    _currentUserSubject.add(user);
    _loginSuccessSubject.add(true);
    return true;
  }

  void dispose() {
    _loadingSubject.close();
    _errorSubject.close();
    _currentUserSubject.close();
    _loginSuccessSubject.close();
    _signupSuccessSubject.close();
    _apiService.dispose();
  }
}
