// Arsya Nueva Delavera (5026231099)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ResetStep {
  input,
  verify,
  newPassword,
  success,
}

class ResetPasswordFlow extends StatefulWidget {
  const ResetPasswordFlow({super.key});

  @override
  State<ResetPasswordFlow> createState() => _ResetPasswordFlowState();
}

class _ResetPasswordFlowState extends State<ResetPasswordFlow> {
  ResetStep step = ResetStep.input;

  final TextEditingController contactCtrl = TextEditingController();
  final TextEditingController otpCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();

  bool isEmail = true;
  bool loading = false;
  String? error;

  SupabaseClient get supabase => Supabase.instance.client;

  void next() => setState(() => step = ResetStep.values[step.index + 1]);
  void back() => setState(() => step = ResetStep.values[step.index - 1]);

  Future<void> sendReset() async {
    setState(() => loading = true);
    try {
      if (isEmail) {
        await supabase.auth.resetPasswordForEmail(contactCtrl.text);
      } else {
        await supabase.auth.signInWithOtp(
          phone: contactCtrl.text,
        );
      }
      next();
    } catch (e) {
      error = e.toString();
    }
    setState(() => loading = false);
  }

  Future<void> verifyOtp() async {
    setState(() => loading = true);
    try {
      await supabase.auth.verifyOTP(
        phone: contactCtrl.text,
        token: otpCtrl.text,
        type: OtpType.sms,
      );
      next();
    } catch (e) {
      error = e.toString();
    }
    setState(() => loading = false);
  }

  Future<void> updatePassword() async {
    if (passCtrl.text != confirmCtrl.text) {
      error = 'Password tidak sama';
      setState(() {});
      return;
    }

    setState(() => loading = true);
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: passCtrl.text),
      );
      next();
    } catch (e) {
      error = e.toString();
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: step != ResetStep.input ? BackButton(onPressed: back) : null),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),

                  if (step == ResetStep.input) _input(),
                  if (step == ResetStep.verify) _verify(),
                  if (step == ResetStep.newPassword) _newPassword(),
                  if (step == ResetStep.success) _success(),
                ],
              ),
      ),
    );
  }

  Widget _input() {
    return Column(
      children: [
        Text(
          isEmail
              ? 'Masukkan Email Terdaftar'
              : 'Masukkan Nomor Handphone Terdaftar',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: contactCtrl,
          keyboardType:
              isEmail ? TextInputType.emailAddress : TextInputType.phone,
          decoration: const InputDecoration(filled: true),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => setState(() => isEmail = !isEmail),
          child: Text(isEmail
              ? 'Gunakan nomor HP'
              : 'Gunakan email'),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: sendReset,
          child: const Text('Lanjutkan'),
        ),
      ],
    );
  }

  Widget _verify() {
    return Column(
      children: [
        Text(
          isEmail ? 'Periksa Email Anda' : 'Periksa Kotak Pesan Anda',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        if (!isEmail)
          TextField(
            controller: otpCtrl,
            decoration: const InputDecoration(
              labelText: 'Kode OTP',
              filled: true,
            ),
          ),
        const Spacer(),
        ElevatedButton(
          onPressed: isEmail ? next : verifyOtp,
          child: const Text('Lanjutkan'),
        ),
      ],
    );
  }

  Widget _newPassword() {
    return Column(
      children: [
        const Text(
          'Perbarui Password',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password Baru',
            filled: true,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: confirmCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Konfirmasi Password Baru',
            filled: true,
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: updatePassword,
          child: const Text('Lanjutkan'),
        ),
      ],
    );
  }

  Widget _success() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 80),
          const SizedBox(height: 20),
          const Text(
            'Password Telah Diperbarui',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali ke Halaman Login'),
          ),
        ],
      ),
    );
  }
}
