class AuthMockService {
  // Hàm dùng chung để tạo độ trễ (mô phỏng việc load mạng)
  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 1500));

  // 1. Đăng nhập
  Future<bool> login(String email, String password) async {
    await _delay();
    return email == 'nhanvien@whitehotel.vn' && password == '12345678';
  }

  // 2. Đăng ký
  Future<bool> register(String email) async {
    await _delay();
    return true; 
  }

  // 3. Gửi mã OTP (khi bấm quên mật khẩu)
  Future<bool> sendOtp(String email) async {
    await _delay();
    return true;
  }

  // 4. Xác thực mã OTP
  Future<bool> verifyOtp(String code) async {
    await _delay();
    return code == '112233'; // Nhập đúng 112233 thì mới qua bài
  }

  // 5. Đặt lại mật khẩu (HÀM ĐANG BỊ THIẾU CỦA BẠN ĐÂY)
  Future<bool> resetPassword(String newPassword) async {
    await _delay(); 
    return true; // Mặc định cho đổi thành công để test giao diện
  }
}