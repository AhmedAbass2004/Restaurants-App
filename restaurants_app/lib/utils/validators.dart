class Validators {
  Validators._();

  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(email.trim());
  }

  static bool isValidPassword(String password) {
    return password.trim().length >= 8;
  }

  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}
