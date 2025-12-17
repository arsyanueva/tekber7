import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/field_model.dart';
import '../../widgets/field_card.dart';
import '../../utils/app_colors.dart';

class AllFieldsScreen extends StatefulWidget {
  final String initialCity;
  final String initialFilter;

  const AllFieldsScreen({
    super.key, 
    required this.initialCity, 
    required this.initialFilter
  });

  @override
  State<AllFieldsScreen> createState() => _AllFieldsScreenState();
}

class _AllFieldsScreenState extends State<AllFieldsScreen> {
  List<FieldModel> fields = [];
  bool isLoading = true;
  late String selectedCity;
  late String selectedFilter;

  @override
  void initState() {
    super.initState();
    selectedCity = widget.initialCity;
    selectedFilter = widget.initialFilter;
    fetchAllFields();
  }

  Future<void> fetchAllFields() async {
    setState(() => isLoading = true);
    try {
      dynamic query = Supabase.instance.client.from('fields').select();

      if (selectedCity == 'SBY') {
        query = query.ilike('address', '%Surabaya%');
      } else if (selectedCity == 'MLG') {
        query = query.ilike('address', '%Malang%');
      }

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
            const Text("Semua Lapangan", style: TextStyle(color: Colors.white, fontSize: 16)),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: AppColors.primaryYellow),
                const SizedBox(width: 4),
                Text(selectedCity == 'SBY' ? "Surabaya" : "Malang", style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : fields.isEmpty 
            ? const Center(child: Text("Tidak ada lapangan ditemukan."))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: fields.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(width: double.infinity, child: FieldCard(field: fields[index])),
                  );
                },
              ),
    );
  }
}