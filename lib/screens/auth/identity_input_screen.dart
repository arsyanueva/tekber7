import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class IdentityInputScreen extends StatefulWidget {
  final String flowType;
  final String method; // 'email' | 'phone'
  final String? role;

  const IdentityInputScreen({
    super.key,
    required this.flowType,
    required this.method,
    this.role,
  });

  @override
  State<IdentityInputScreen> createState() => _IdentityInputScreenState();
}

class _IdentityInputScreenState extends State<IdentityInputScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;

  bool get isValid {
    if (widget.flowType == 'register') {
      return _controller.text.isNotEmpty && _nameController.text.isNotEmpty;
    }
    return _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final inputValue = widget.method == 'phone'
        ? '+62${_controller.text}'
        : _controller.text.trim();

    setState(() => _loading = true);

    try {
      final exists = await _authService.userExists(inputValue, widget.method);

      if (widget.flowType == 'register') {
        if (exists) {
          _showDialog('Gagal', 'Akun sudah terdaftar');
        } else {
          _navigateToOtp(context, inputValue);
        }
      } else {
        if (!exists) {
          _showDialog('Gagal', 'Akun belum terdaftar');
        } else {
          _navigateToOtp(context, inputValue);
        }
      }
    } catch (e) {
      _showDialog('Error', e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToOtp(BuildContext context, String value) {
    Navigator.pushNamed(
      context,
      AppRoutes.otpVerification,
      arguments: {
        'flowType': widget.flowType,
        'method': widget.method,
        'role': widget.role,
        'value': value,
        'name': _nameController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = widget.method == 'phone';
    final isRegister = widget.flowType == 'register';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Text(
              isPhone
                  ? 'Masukkan Nomor Handphone\nyang Aktif'
                  : 'Masukkan Email anda',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 32),

            if (isRegister) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Nama lengkap',
                  border: UnderlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
            ],

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isPhone)
                  _prefixBox(
                    child: const Row(
                      children: [
                        Text('🇮🇩'),
                        SizedBox(width: 6),
                        Text('+62'),
                      ],
                    ),
                  )
                else
                  _prefixBox(
                    child: Image.asset(
                      'assets/google.png',
                      height: 20,
                    ),
                  ),

                const SizedBox(width: 12),

                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: isPhone
                        ? TextInputType.number
                        : TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: isPhone
                          ? '812345678'
                          : 'cth : tamasehat@gmail.com',
                      border: const UnderlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isValid && !_loading ? () => _submit(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1B2E),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isRegister ? 'Daftar' : 'Masuk',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _prefixBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
