import 'package:flutter/material.dart';

/// Nature-inspired palette: Green (Primary) + Beige (Background) + Brown (Accent/Text)
class AppColors {
  // ── Primary Green ──────────────────────────────────────────────
  static const Color greenPrimary   = Color(0xFF2E7D32); // deep forest green
  static const Color greenMedium    = Color(0xFF43A047); // standard green
  static const Color greenLight     = Color(0xFF81C784); // soft mint
  static const Color greenSurface   = Color(0xFFE8F5E9); // very light green tint

  // ── Beige / Warm Neutral ────────────────────────────────────────
  static const Color scaffoldBg     = Color(0xFFF9F5F0); // warm off-white
  static const Color cardBg         = Color(0xFFFDFAF6); // creamy card surface
  static const Color divider        = Color(0xFFE8E0D5); // warm divider

  // ── Brown Accent ────────────────────────────────────────────────
  static const Color brownDark      = Color(0xFF4E342E); // dark espresso
  static const Color brownAccent    = Color(0xFF6D4C41); // rich wood
  static const Color brownLight     = Color(0xFFA1887F); // warm taupe
  static const Color brownSurface   = Color(0xFFF3E5DC); // blush beige

  // ── Text ────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF3E2723); // near-black brown
  static const Color textSecondary  = Color(0xFF6D4C41); // medium brown
  static const Color textHint       = Color(0xFFA1887F); // taupe hint

  // ── Status ──────────────────────────────────────────────────────
  static const Color error          = Color(0xFFC62828);
  static const Color warning        = Color(0xFFF57F17);
  static const Color success        = Color(0xFF2E7D32);
  static const Color info           = Color(0xFF01579B);

  // ── Booking Status chips ────────────────────────────────────────
  static const Color statusPending    = Color(0xFFFF8F00); // amber
  static const Color statusConfirmed  = Color(0xFF2E7D32); // green
  static const Color statusCancelled  = Color(0xFFC62828); // red
  static const Color statusCompleted  = Color(0xFF0277BD); // blue
}
