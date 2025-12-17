// lib/utils/refund_helper.dart

class RefundResult {
  final int refundPercentage;
  final double refundAmount;
  final String message;

  RefundResult({
    required this.refundPercentage, 
    required this.refundAmount, 
    required this.message
  });
}

class RefundHelper {
  static RefundResult calculate(DateTime bookingDate, num totalPaid) {
    final now = DateTime.now();
    // Normalisasi jam ke 00:00:00 agar hitungan hari akurat
    final dateBooking = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
    final dateNow = DateTime(now.year, now.month, now.day);

    final difference = dateBooking.difference(dateNow).inDays;
    
    int percentage = 0;
    String msg = "";

    if (difference >= 7) {
      percentage = 100;
      msg = "Pengembalian biaya 100% (H-7 atau lebih).";
    } else if (difference >= 3) {
      percentage = 50;
      msg = "Pengembalian biaya 50% (H-3 s.d H-6).";
    } else {
      percentage = 0;
      msg = "Tidak ada pengembalian biaya (H-2 atau kurang).";
    }

    double amount = (percentage / 100) * totalPaid;

    return RefundResult(
      refundPercentage: percentage, 
      refundAmount: amount, 
      message: msg
    );
  }
}