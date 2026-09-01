abstract class OtpService {
  /// Request an OTP for the given phone number. Returns the OTP (mocked).
  Future<String> requestOtp(String phone);

  /// Verify the provided OTP for the phone. Returns true if verified.
  Future<bool> verifyOtp(String phone, String otp);
}
