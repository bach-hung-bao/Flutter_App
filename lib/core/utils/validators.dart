class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(value) ? null : 'Email không đúng định dạng';
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    return value.length >= 6 ? null : 'Mật khẩu phải từ 6 ký tự';
  }
}