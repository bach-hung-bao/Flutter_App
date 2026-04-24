import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../review/domain/usecases/create_review_usecase.dart';

class WriteReviewScreen extends StatefulWidget {
  final int bookingId;
  final int roomId;
  final CreateReviewUseCase createReviewUseCase;

  const WriteReviewScreen({
    super.key,
    required this.bookingId,
    required this.roomId,
    required this.createReviewUseCase,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.createReviewUseCase.execute(
        bookingId: widget.bookingId,
        roomId: widget.roomId,
        rating: _rating,
        comment: _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),
      );
     if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đánh giá đã được gửi!', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.greenPrimary,
          ),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.greenPrimary,
        foregroundColor: Colors.white,
        title: Text('Viết đánh giá',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 16),
          // Star rating
          Text('Chất lượng phòng', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 44,
                    color: star <= _rating ? Colors.amber : AppColors.textHint,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _ratingLabel(_rating),
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.brownAccent),
          ),
          const SizedBox(height: 32),
          // Comment
          TextField(
            controller: _commentCtrl,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Chia sẻ trải nghiệm của bạn...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.greenPrimary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Gửi đánh giá', style: AppTextStyles.button),
            ),
          ),
        ]),
      ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1: return 'Rất tệ';
      case 2: return 'Tệ';
      case 3: return 'Bình thường';
      case 4: return 'Tốt';
      case 5: return 'Tuyệt vời!';
      default: return '';
    }
  }
}
