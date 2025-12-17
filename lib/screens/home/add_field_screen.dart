// Rian Chairul Ichsan (5026231121)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class AddFieldScreen extends StatefulWidget {
  const AddFieldScreen({super.key});

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Harga default / Pilihan
  int _selectedPrice = 100000;
  final List<int> _priceOptions = [100000, 150000, 200000, 250000, 300000];

  // Untuk Foto
  final ImagePicker _picker = ImagePicker();
  List<String> _photoUrls = [];
  bool _isUploadingPhoto = false;

  bool _isLoading = false;

  // Fungsi Simpan ke Supabase
  Future<void> _submitField() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sesi habis, silakan login ulang.")));
      return;
    }

    try {
      await Supabase.instance.client.from('fields').insert({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'price_per_hour': _selectedPrice, // Simpan sebagai integer/numeric
        'owner_id': user.id,
        'image_url': _photoUrls, 
        'rating': 0.0,
        'facilities': 'Wifi,Parkir,Toilet', // Default dummy facilities
        'latitude': -7.2575, // Default Surabaya (Nanti bisa pakai Maps Picker)
        'longitude': 112.7521,
      });

      if (_photoUrls.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Minimal upload 3 foto lapangan")),
        );
        return;
      }

      if (mounted) {
        // Tampilkan Dialog Sukses (Mirip image_77e69d.png)
        _showSuccessDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadPhotos() async {
    final images = await _picker.pickMultiImage(imageQuality: 75);
    if (images.isEmpty) return;

    setState(() => _isUploadingPhoto = true);

    try {
      for (final image in images) {
        final fileExt = image.name.split('.').last;
        final fileName = '${const Uuid().v4()}.$fileExt';
        final filePath = 'fields/$fileName';

        if (kIsWeb) {
          // FLUTTER WEB
          Uint8List bytes = await image.readAsBytes();

          await Supabase.instance.client.storage
              .from('field-images')
              .uploadBinary(
                filePath,
                bytes,
                fileOptions:  FileOptions(
                  contentType: 'image/$fileExt',
                ),
              );
        } else {
          // ANDROID / IOS
          await Supabase.instance.client.storage
              .from('field-images')
              .upload(
                filePath,
                File(image.path),
              );
        }

        final publicUrl = Supabase.instance.client.storage
            .from('field-images')
            .getPublicUrl(filePath);

        _photoUrls.add(publicUrl);
      }

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload gagal: $e")),
      );
    } finally {
      setState(() => _isUploadingPhoto = false);
    }
  }


  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.darkBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                "Lapangan berhasil\ndidaftarkan",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup Dialog
                    Navigator.pop(context); // Kembali ke Home Owner
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.darkBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Lihat Lapangan", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Mendaftarkan Lapangan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 1. Input Nama
              _buildTextField(
                controller: _nameController, 
                hint: "Nama Lapangan",
                validator: (val) => val!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              
              // 2. Input Lokasi
              _buildTextField(
                controller: _addressController, 
                hint: "Lokasi / Alamat",
                validator: (val) => val!.isEmpty ? "Alamat wajib diisi" : null,
              ),
              const SizedBox(height: 24),

              // 3. Pilihan Harga
              const Text("Harga lapangan per jam", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _priceOptions.map((price) {
                    final isSelected = _selectedPrice == price;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPrice = price),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.grey[400] : Colors.grey[200], // Highlight jika dipilih
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected ? Border.all(color: Colors.black54) : null,
                        ),
                        child: Text(
                          price.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // 4. Upload Foto
              const Text("Foto Lapangan (minimal 3)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: _isUploadingPhoto ? null : _uploadPhotos,
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text("Upload"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.darkBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Kotak Gambar
              _photoUrls.isEmpty
                ? Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.image, size: 50, color: Colors.white),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _photoUrls.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _photoUrls[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),

              const SizedBox(height: 40),

              // 5. Tombol Daftar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitField,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBackground,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Daftar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFEAEAEA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}