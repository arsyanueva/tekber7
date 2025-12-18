//Lailatul Fitaliqoh (5026231229)
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/field_model.dart';
import '../../widgets/field_card.dart';
import '../../utils/app_colors.dart';
import 'field_detail_screen.dart'; 

class AllFieldsScreen extends StatefulWidget {
  final String initialCity;
  final String initialFilter;
  final String? initialSearch; 

  const AllFieldsScreen({
    super.key, 
    required this.initialCity, 
    required this.initialFilter,
    this.initialSearch, 
  });

  @override
  State<AllFieldsScreen> createState() => _AllFieldsScreenState();
}

class _AllFieldsScreenState extends State<AllFieldsScreen> {
  List<FieldModel> fields = [];
  bool isLoading = true;
  
  late String selectedCity;
  late String selectedFilter;
  String? searchQuery; // Variabel untuk menyimpan kata kunci

  @override
  void initState() {
    super.initState();
    selectedCity = widget.initialCity;
    selectedFilter = widget.initialFilter;
    searchQuery = widget.initialSearch; // Ambil data dari halaman sebelumnya
    fetchAllFields();
  }

  Future<void> fetchAllFields() async {
    setState(() => isLoading = true);
    try {
      dynamic query = Supabase.instance.client.from('fields').select();

      // 1. Filter Kota
      if (selectedCity == 'SBY') {
        query = query.or('address.ilike.%Surabaya%,address.ilike.%SURABAYA%');
      } else if (selectedCity == 'MLG') {
        query = query.or('address.ilike.%Malang%,address.ilike.%MALANG%');
      } else { // Jika selectedCity == 'ALL'
        // Tidak ada filter kota diterapkan
      }

      // 2. Filter Search
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        // Cari nama lapangan yang mirip (case-insensitive)
        query = query.ilike('name', '%$searchQuery%');
      }

      // 3. Sorting
      if (selectedFilter == 'Termurah') {
        query = query.order('price_per_hour', ascending: true);
      } else {
        query = query.order('created_at', ascending: false);
      }

      final response = await query;
      final data = response as List<dynamic>;
      
      if (mounted) {
        setState(() {
          fields = data.map((json) => FieldModel.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        leading: const BackButton(color: AppColors.primaryYellow),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul berubah sesuai kondisi pencarian
            Text(
              searchQuery != null && searchQuery!.isNotEmpty 
                  ? "\"$searchQuery\"" 
                  : "Semua Lapangan", 
              style: const TextStyle(color: Colors.white, fontSize: 16)
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: AppColors.primaryYellow),
                const SizedBox(width: 4),
                Text(
                  selectedCity == 'ALL'
                    ? 'Cari Lapangan di Semua Kota'
                    : 'Cari Lapangan di ${selectedCity == "SBY" ? "Surabaya" : "Malang"}', 
                  style: const TextStyle(color: Colors.white70, fontSize: 12)
                ),
              ],
            )
          ],
        ),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : fields.isEmpty 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 60, color: Colors.grey),
                    const SizedBox(height: 10),
                    Text(
                      "Tidak ada lapangan ditemukan${searchQuery != null ? " untuk '$searchQuery'" : ""}.", 
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: fields.length,
                itemBuilder: (context, index) {
                  final field = fields[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FieldDetailScreen(fieldId: field.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: FieldCard(field: field),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}