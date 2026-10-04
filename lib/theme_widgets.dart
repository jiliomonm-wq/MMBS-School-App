import 'package:flutter/material.dart';
import 'dart:ui';

// ============================================================================
// 3. THEME & SHARED STYLES (DRY Principle)
// ============================================================================
class AppColors {
  static const bg1 = Color(0xFFEFF6FF); // Light blue
  static const bg2 = Color(0xFFF5F3FF); // Light purple
  static const bg3 = Color(0xFFFDF2F8); // Light pink
  static const primary = Color(0xFF2563EB);
  static const purple = Color(0xFF8B5CF6);
  static const accent3 = Color(0xFF06B6D4);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const success = Color(0xFF10B981);
  static const warn = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
}

class LightBackground extends StatelessWidget {
  final Widget child;
  const LightBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bg1, AppColors.bg2, AppColors.bg3],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -60, right: -60, child: _bubble(200, AppColors.primary.withOpacity(0.1))),
          Positioned(bottom: -80, left: -80, child: _bubble(220, AppColors.accent3.withOpacity(0.1))),
          Positioned(top: 200, left: -40, child: _bubble(120, AppColors.purple.withOpacity(0.12))),
          child,
        ],
      ),
    );
  }
  Widget _bubble(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  const GlassCard({super.key, required this.child, this.padding, this.radius = 20});
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary( // Performance optimization for BackdropFilter
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 4. REUSABLE WIDGETS (Modularity)
// ============================================================================
AppBar buildAppBar(String title, VoidCallback onToggleLang, String langLabel, VoidCallback onLogout, String logoutText) => AppBar(
  backgroundColor: Colors.transparent, elevation: 0,
  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        onTap: onToggleLang,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.language, size: 12, color: AppColors.primary),
            const SizedBox(width: 3),
            Text(langLabel, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
          ]),
        ),
      ),
    ),
    IconButton(icon: const Icon(Icons.logout, color: AppColors.textSecondary, size: 20), onPressed: onLogout, tooltip: logoutText),
  ],
);

Widget buildGlassHeader(String greeting, String name, String sub, String avatarUrl) {
  return GlassCard(
    padding: const EdgeInsets.all(18),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.primary, AppColors.purple])),
        child: CircleAvatar(radius: 26, backgroundColor: Colors.white,
          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl.isEmpty ? Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)) : null),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(greeting, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ])),
    ]),
  );
}

Widget buildGlassStat(String label, String value, IconData icon, Color color) {
  return GlassCard(
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
      const SizedBox(height: 10),
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
    ]),
  );
}

Widget buildSectionTitle(String title) => Padding(
  padding: const EdgeInsets.only(bottom: 10, top: 6),
  child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
);

Widget buildMiniRow(IconData icon, String text) => Padding(
  padding: const EdgeInsets.only(bottom: 4),
  child: Row(children: [
    Icon(icon, size: 12, color: AppColors.textSecondary),
    const SizedBox(width: 6),
    Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
  ]),
);

Widget buildEmptyState(String text) => GlassCard(
  padding: const EdgeInsets.all(24),
  child: Column(children: [
    Icon(Icons.inbox_outlined, size: 40, color: AppColors.textSecondary.withOpacity(0.5)),
    const SizedBox(height: 10),
    Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
  ]),
);

Widget buildNewsCard(String title, String content) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: GlassCard(
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 6),
      Text(content, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
    ]),
  ),
);

Widget buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) => GestureDetector(
  onTap: onTap,
  child: GlassCard(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary))),
      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    ]),
  ),
);

Widget buildGlassOpt(IconData icon, String label, String value) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: GlassCard(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 16)),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary))),
      Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis),
    ]),
  ),
);

// Safe Image Loader (Prevents crashes on bad URLs)
Widget safeNetworkImage(String url, {double? height, double? width, BoxFit fit = BoxFit.cover, double radius = 8}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.network(
      url, height: height, width: width, fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(height: height, width: width, color: Colors.white.withOpacity(0.5), child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))));
      },
      errorBuilder: (context, error, stackTrace) => Container(
        height: height, width: width, color: Colors.white.withOpacity(0.5),
        child: const Center(child: Icon(Icons.broken_image, color: AppColors.textSecondary)),
      ),
    ),
  );
}
