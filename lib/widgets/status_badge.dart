import 'package:flutter/material.dart';
import '../models/pesanan.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';

Color warnaStatus(StatusPesanan s) {
  switch (s) {
    case StatusPesanan.menunggu:
      return AppColors.amber;
    case StatusPesanan.dijemput:
      return AppColors.blue;
    case StatusPesanan.diproses:
      return AppColors.violet;
    case StatusPesanan.diantar:
      return AppColors.teal;
    case StatusPesanan.selesai:
      return AppColors.success;
  }
}

Color warnaVerifikasi(StatusVerifikasi s) {
  switch (s) {
    case StatusVerifikasi.menunggu:
      return AppColors.amber;
    case StatusVerifikasi.valid:
      return AppColors.success;
    case StatusVerifikasi.tidakValid:
      return AppColors.danger;
  }
}

/// Penjelasan singkat tiap tahap, dipakai di lini status.
String keteranganStatus(StatusPesanan s) {
  switch (s) {
    case StatusPesanan.menunggu:
      return 'Pesanan diterima, menunggu kurir';
    case StatusPesanan.dijemput:
      return 'Kurir menjemput & menimbang cucian';
    case StatusPesanan.diproses:
      return 'Cucian sedang dicuci';
    case StatusPesanan.diantar:
      return 'Cucian bersih dalam perjalanan';
    case StatusPesanan.selesai:
      return 'Cucian sudah sampai';
  }
}

class StatusBadge extends StatelessWidget {
  final StatusPesanan status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Pill(text: status.label, color: warnaStatus(status));
  }
}

class VerifikasiBadge extends StatelessWidget {
  final StatusVerifikasi status;
  const VerifikasiBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Pill(text: status.label, color: warnaVerifikasi(status));
  }
}

/// Lini status ringkas: 5 segmen, terisi sampai tahap sekarang.
class StatusBar extends StatelessWidget {
  final StatusPesanan status;
  const StatusBar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final idx = StatusPesanan.values.indexOf(status);
    final warna = warnaStatus(status);
    final total = StatusPesanan.values.length;
    return Row(
      children: List.generate(total, (i) {
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: i <= idx ? warna : AppColors.line,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

/// Lini status lengkap (vertikal) dengan keterangan tiap tahap.
class StatusTimeline extends StatelessWidget {
  final StatusPesanan status;
  const StatusTimeline({super.key, required this.status});

  static const double _rowHeight = 66;

  @override
  Widget build(BuildContext context) {
    final steps = StatusPesanan.values;
    final idx = steps.indexOf(status);
    final selesai = status == StatusPesanan.selesai;

    return Column(
      children: List.generate(steps.length, (i) {
        final last = i == steps.length - 1;
        final done = i < idx || selesai;
        final current = i == idx && !selesai;
        final reached = done || current;

        return SizedBox(
          height: last ? 44 : _rowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    _Node(done: done, current: current),
                    if (!last)
                      Expanded(
                        child: Container(
                          width: 3,
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            color: i < idx || selesai ? AppColors.teal : AppColors.line,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i].label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                          color: reached ? AppColors.ink : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        keteranganStatus(steps[i]),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: current ? AppColors.teal : AppColors.muted,
                          fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _Node extends StatelessWidget {
  final bool done;
  final bool current;
  const _Node({required this.done, required this.current});

  @override
  Widget build(BuildContext context) {
    if (done) {
      return Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 18, color: Colors.white),
      );
    }
    if (current) {
      // seperti pintu mesin cuci: cincin teal dengan inti terisi
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.teal, width: 3),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
        ),
      );
    }
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.line, width: 2.5),
      ),
    );
  }
}
