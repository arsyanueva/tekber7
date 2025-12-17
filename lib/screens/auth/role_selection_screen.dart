import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String flowType;
  final String method;

  const RoleSelectionScreen({
    super.key,
    required this.flowType,
    required this.method,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? role; // 'pemilik' | 'peminjam'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Daftar Sebagai',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _roleCard(
                    title: 'Pengelola',
                    asset: 'assets/pemilik.png',
                    value: 'owner',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _roleCard(
                    title: 'Penyewa',
                    asset: 'assets/peminjam.png',
                    value: 'renter',
                  ),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: role == null
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.identityInput,
                          arguments: {
                            'flowType': widget.flowType,
                            'method': widget.method,
                            'role': role,
                          },
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1B2E),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Daftar',
                  style: TextStyle(
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

  Widget _roleCard({
    required String title,
    required String asset,
    required String value,
  }) {
    final bool isSelected = role == value;

    return GestureDetector(
      onTap: () => setState(() => role = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 180,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E1B2E)
              : const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              asset,
              height: 90,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
