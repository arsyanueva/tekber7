import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';
import '../models/review_model.dart';

class ReviewListSection extends StatefulWidget {
  final String fieldId;
  final bool isOwner; // Untuk menentukan apakah tombol "Balas" muncul

  const ReviewListSection({
    super.key, 
    required this.fieldId, 
    this.isOwner = false
  });

  @override
  State<ReviewListSection> createState() => _ReviewListSectionState();
}

class _ReviewListSectionState extends State<ReviewListSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<ReviewProvider>(context, listen: false).fetchReviews(widget.fieldId)
    );
  }

  void _showReplyDialog(BuildContext context, ReviewModel review) {
    final TextEditingController replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Balas Ulasan"),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(hintText: "Masukkan balasan anda..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              Provider.of<ReviewProvider>(context, listen: false)
                  .replyReview(review.id ?? "", replyController.text, widget.fieldId);
              Navigator.pop(context);
            },
            child: const Text("Kirim"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Belum ada ulasan.", textAlign: TextAlign.center),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Karena biasanya di dalam ScrollView parent
          itemCount: provider.reviews.length,
          itemBuilder: (context, index) {
            final review = provider.reviews[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: review.renterAvatarUrl != null 
                        ? NetworkImage(review.renterAvatarUrl!) 
                        : const AssetImage('assets/user_placeholder.png') as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  
                  // Konten Review
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              review.renterName ?? "User",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            const Text("👍", style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            
                            // Badge Rating Kuning Kecil
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${review.rating}/5",
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          review.comment,
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                        
                        // Menampilkan Balasan Owner jika ada
                        if (review.ownerReply != null)
                           Container(
                             margin: const EdgeInsets.only(top: 8),
                             padding: const EdgeInsets.all(8),
                             decoration: BoxDecoration(
                               color: Colors.grey[100],
                               borderRadius: BorderRadius.circular(8),
                               border: Border.all(color: Colors.grey.shade300)
                             ),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 const Text("Respon Pengelola:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                 Text(review.ownerReply!, style: const TextStyle(fontSize: 12)),
                               ],
                             ),
                           ),

                        // Tombol Balas (Hanya muncul jika user adalah Owner & belum dibalas)
                        if (widget.isOwner && review.ownerReply == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: GestureDetector(
                              onTap: () => _showReplyDialog(context, review),
                              child: const Text(
                                "Balas",
                                style: TextStyle(
                                  color: Colors.grey, 
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}