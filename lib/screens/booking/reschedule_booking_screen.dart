import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekber7/models/booking_model.dart';
import 'package:tekber7/screens/booking/confirm_reschedule_screen.dart';

class RescheduleBookingScreen extends StatefulWidget {
  const RescheduleBookingScreen({super.key});

  @override
  State<RescheduleBookingScreen> createState() => _RescheduleBookingScreenState();
}

class _RescheduleBookingScreenState extends State<RescheduleBookingScreen> {
  BookingModel? booking; 
  int requiredDuration = 1;
  List<Map<String, dynamic>> selectedSlots = [];
  DateTime selectedDate = DateTime.now();
  bool _isInit = true;

  final Color _primaryDark = const Color(0xFF1E1E1E);   
  final Color _primaryYellow = const Color(0xFFFFC700); 
  final Color _bgColors = const Color(0xFFF5F5F5);

  final List<Map<String, dynamic>> availableSlots = [
    {'id': 1, 'time': '08.00 - 09.00'}, {'id': 2, 'time': '09.00 - 10.00'},
    {'id': 3, 'time': '10.00 - 11.00'}, {'id': 4, 'time': '11.00 - 12.00'},
    {'id': 5, 'time': '13.00 - 14.00'}, {'id': 6, 'time': '14.00 - 15.00'},
    {'id': 7, 'time': '15.00 - 16.00'}, {'id': 8, 'time': '16.00 - 17.00'},
    {'id': 9, 'time': '17.00 - 18.00'}, {'id': 10, 'time': '18.00 - 19.00'},
    {'id': 11, 'time': '19.00 - 20.00'}, {'id': 12, 'time': '20.00 - 21.00'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is BookingModel) {
        booking = args;
        selectedDate = booking!.bookingDate; 
        try {
          double start = double.parse(booking!.startTime.substring(0, 2));
          double end = double.parse(booking!.endTime.substring(0, 2));
          requiredDuration = (end - start).toInt();
        } catch (e) { requiredDuration = 1; }
        if (requiredDuration <= 0) requiredDuration = 1;
      }
      _isInit = false;
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(primary: _primaryYellow, onPrimary: Colors.black, surface: _primaryDark),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() { selectedDate = picked; selectedSlots.clear(); });
  }

  void _onSlotTap(Map<String, dynamic> slot) {
    setState(() {
      if (selectedSlots.contains(slot)) selectedSlots.remove(slot);
      else if (selectedSlots.length < requiredDuration) selectedSlots.add(slot);
      else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pilih $requiredDuration slot saja.")));
    });
  }

  void _navigateToConfirm() {
    if (booking == null) return;
    selectedSlots.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
    String start = selectedSlots.first['time'].toString().split(' - ')[0];
    String end = selectedSlots.last['time'].toString().split(' - ')[1];

    Navigator.push(
      context,
      MaterialPageRoute(
        // PASTIKAN CLASS INI ADA (Cek Code 3)
        builder: (context) => ConfirmRescheduleScreen(
          oldBooking: booking!,
          newDate: selectedDate,
          newStartTime: start, 
          newEndTime: end,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (booking == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    int remaining = requiredDuration - selectedSlots.length;
    bool isReady = remaining == 0;

    return Scaffold(
      backgroundColor: _bgColors,
      appBar: AppBar(
        backgroundColor: _primaryDark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: _primaryYellow), onPressed: () => Navigator.pop(context)),
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.edit_calendar_rounded, color: _primaryYellow, size: 24),
          const SizedBox(width: 10),
          Text("Ubah Jadwal", style: TextStyle(color: _primaryYellow, fontWeight: FontWeight.bold, fontSize: 20)),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tanggal Bermain", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.black),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text("Pilih Jam", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.5, crossAxisSpacing: 10, mainAxisSpacing: 10),
                    itemCount: availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = availableSlots[index];
                      final isSelected = selectedSlots.contains(slot);
                      return GestureDetector(
                        onTap: () => _onSlotTap(slot),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryDark : Colors.white,
                            border: Border.all(color: isSelected ? _primaryDark : Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(slot['time'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("${selectedSlots.length} Jam dipilih", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(), // HARGA DIHILANGKAN
                ]),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: isReady ? _navigateToConfirm : null,
                    style: ElevatedButton.styleFrom(backgroundColor: _primaryYellow, foregroundColor: Colors.black, disabledBackgroundColor: Colors.grey[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Lanjut ke Konfirmasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}