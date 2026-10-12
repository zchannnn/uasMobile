import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Kartu putih dengan garis tipis (tanpa bayangan), bisa diketuk.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: borderColor ?? AppColors.line, width: borderWidth),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Lingkaran/kotak ikon bertint teal.
class IconTile extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  const IconTile(this.icon, {super.key, this.size = 46, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: c, size: size * 0.5),
    );
  }
}

/// Lencana kecil berwarna.
class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const Pill({super.key, required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
    );
  }
}

/// Satu baris informasi: ikon + label kecil + nilai.
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: emphasize
                      ? const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.teal)
                      : const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tampilan kosong yang mengajak bertindak.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const EmptyState({super.key, required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(color: AppColors.mist, shape: BoxShape.circle),
              child: Icon(icon, size: 38, color: AppColors.teal),
            ),
            const SizedBox(height: 18),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kotak pesan error/peringatan di dalam form.
class MessageBox extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;
  const MessageBox(
    this.message, {
    super.key,
    this.color = AppColors.danger,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w600, height: 1.35))),
        ],
      ),
    );
  }
}

/// Tombol utama dengan indikator loading.
class LoadingButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: color == null
          ? null
          : ElevatedButton.styleFrom(
              backgroundColor: color,
              disabledBackgroundColor: color!.withValues(alpha: 0.55),
            ),
      child: loading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                Flexible(child: Text(label, textAlign: TextAlign.center)),
              ],
            ),
    );
  }
}

/// Logo CleanGo (lingkaran transparan + ikon mesin cuci).
class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), shape: BoxShape.circle),
      child: Icon(Icons.local_laundry_service, size: size * 0.55, color: Colors.white),
    );
  }
}

/// Header teal di bagian atas layar utama tiap peran.
class HeaderBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? bottom;

  const HeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 0, 10, 22),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                ...actions,
              ],
            ),
            if (bottom != null) ...[const SizedBox(height: 18), Padding(padding: const EdgeInsets.only(right: 12), child: bottom!)],
          ],
        ),
      ),
    );
  }
}

/// Tombol ikon putih untuk di dalam HeaderBar.
class HeaderAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  const HeaderAction({super.key, required this.icon, required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}

/// Kotak angka ringkas di dalam header (mis. "3 / Perlu kurir").
class HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  const HeaderStat({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
        ],
      ),
    );
  }
}
