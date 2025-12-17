import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../models/user_model.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String flowType;
  final String method;
  final String? role;
  final String value;
  final String? name;

  const OtpVerificationScreen({
    super.key,
    required this.flowType,
    required this.method,
    this.role,
    required this.value,
    this.name,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final int _otpLength = 4;
  final List<String> _otp = ["", "", "", ""];
  bool _loading = false;

  bool get _isComplete => _otp.every((e) => e.isNotEmpty);

  void _onNumberTap(String value) {
    if (_isComplete) return; //stop kalo  penuh

    for (int i = 0; i < _otpLength; i++) {
      if (_otp[i].isEmpty) {
        setState(() => _otp[i] = value);
        break;
      }
    }
  }

  void _onDelete() {
    for (int i = _otpLength - 1; i >= 0; i--) {
      if (_otp[i].isNotEmpty) {
        setState(() => _otp[i] = "");
        break;
      }
    }
  }

  String get _otpValue => _otp.join();

  Future<void> _verifyOtp() async {
    if (_otpValue != '1234') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP salah')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authService = AuthService();
      late UserModel user;

      if (widget.flowType == 'register') {
        user = await authService.registerWithOtp(
          identifier: widget.value,
          method: widget.method,
          name: widget.name!,
          role: widget.role!,
        );
      } else {
        user = await authService.loginWithOtp(
          identifier: widget.value,
          method: widget.method,
        );
      }

      await authProvider.setUser(user);

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildNumberButton(String number) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _onNumberTap(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F1B2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: _onDelete,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Icon(
          Icons.backspace,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Masukkan Kode Verifikasi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kode OTP : "1234"',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // OTP BOX
            Row(
              children: List.generate(_otpLength, (index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _otp[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Number Pad
            Column(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int j = 0; j < 3; j++) _buildNumberButton((i * 3 + j + 1).toString()),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton('0'),
                    _buildDeleteButton(),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isComplete && !_loading ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _isComplete
                      ? const Color(0xFF1F1B2E)
                      : const Color(0xFFE0E0E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.flowType == 'register' ? 'Daftar' : 'Masuk',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
