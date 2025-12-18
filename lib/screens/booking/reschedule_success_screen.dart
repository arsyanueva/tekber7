import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RescheduleSuccessScreen extends StatelessWidget {
  final DateTime newDate;
  final String newStartTime;
  final String newEndTime;
  final String fieldName;

  const RescheduleSuccessScreen({
    super.key,
    required this.newDate,
    required this.newStartTime,
    required this.newEndTime,
    this.fieldName = "Lapangan 2",
  });

  final Color _primaryDark = const Color(0xFF1E1E1E);
  final Color _primaryYellow = const Color(0xFFFFC700);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _primaryDark,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, 
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: _primaryYellow, size: 24),
            const SizedBox(width: 8),
            Text('Perubahan Jadwal Berhasil', style: TextStyle(color: _primaryYellow, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView( 
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _primaryYellow),
                    child: const Icon(Icons.check, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Perubahan Jadwal\nPenyewaan Lapangan Berhasil",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Data Sewa Lapangan :", style: TextStyle(fontSize: 12, color: Colors.grey))]),
                        const SizedBox(height: 10),
                        
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text("Tanggal", style: TextStyle(color: Colors.grey)), 
                          Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(newDate), style: const TextStyle(fontWeight: FontWeight.bold))
                        ]),
                        const SizedBox(height: 8),
                        
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text("Waktu", style: TextStyle(color: Colors.grey)), 
                          Text("$newStartTime - $newEndTime", style: const TextStyle(fontWeight: FontWeight.bold))
                        ]),
                        const SizedBox(height: 8),
                        
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text("Nomor Lapangan", style: TextStyle(color: Colors.grey)), 
                          Text("2", style: const TextStyle(fontWeight: FontWeight.bold))
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _primaryYellow,
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Biaya", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("0", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 50,
          child: OutlinedButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Kembali", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}