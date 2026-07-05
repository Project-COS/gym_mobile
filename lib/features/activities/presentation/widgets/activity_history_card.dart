import 'package:flutter/material.dart';

import '../../../../core/colors.dart';
import '../../data/activity_data.dart';

class ActivityHistoryCard extends StatelessWidget {
  const ActivityHistoryCard({
    super.key,
    required this.item,
    this.onBookingDetailPressed,
  });

  final ActivityHistoryItem item;
  final ValueChanged<ActivityHistoryItem>? onBookingDetailPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: item.isFeatured
              ? AppColors.gymGold.withValues(alpha: 0.32)
              : AppColors.gunmetal,
        ),
        gradient: item.isFeatured
            ? LinearGradient(
                colors: [
                  AppColors.gymGold.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                stops: const [0, 0.45],
              )
            : null,
      ),
      child: Column(
        children: [
          _HistoryHeader(item: item),
          const SizedBox(height: 14),
          _MetaGrid(metas: item.metas),
          if (item.bookingDetail != null) ...[
            const SizedBox(height: 14),
            _BookingDetailPanel(
              detail: item.bookingDetail!,
              onDetailPressed: onBookingDetailPressed == null
                  ? null
                  : () => onBookingDetailPressed!(item),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.item});

  final ActivityHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.gymGold.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.gymGold.withValues(alpha: 0.18),
            ),
          ),
          child: Icon(item.icon, color: AppColors.gymGold, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 15,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.silverGray,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _StatusChip(label: item.status),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(label);

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String label) {
    return switch (label) {
      'Aktif' || 'Berlangsung' => AppColors.info,
      'Menunggu' => AppColors.warning,
      'Batal' || 'Tidak Hadir' => AppColors.error,
      _ => AppColors.success,
    };
  }
}

class _BookingDetailPanel extends StatelessWidget {
  const _BookingDetailPanel({required this.detail, this.onDetailPressed});

  final ActivityBookingDetail detail;
  final VoidCallback? onDetailPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blackCore.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Booking',
            style: TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _BookingDetailValue(
                  label: 'Kode',
                  value: detail.bookingCode,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BookingDetailValue(
                  label: 'Sumber',
                  value: detail.source,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                detail.canShowQr
                    ? Icons.qr_code_rounded
                    : Icons.check_circle_rounded,
                color: detail.canShowQr ? AppColors.gymGold : AppColors.success,
                size: 17,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  detail.canShowQr
                      ? 'QR booking tersedia untuk sesi aktif.'
                      : 'QR booking sudah tersimpan pada riwayat sesi ini.',
                  style: const TextStyle(
                    color: AppColors.silverGray,
                    fontSize: 11,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (onDetailPressed != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onDetailPressed,
                icon: Icon(
                  detail.canShowQr
                      ? Icons.qr_code_rounded
                      : Icons.open_in_new_rounded,
                  size: 16,
                ),
                label: Text(
                  detail.canShowQr
                      ? 'Lihat QR booking'
                      : 'Lihat detail booking',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gymGold,
                  side: BorderSide(
                    color: AppColors.gymGold.withValues(alpha: 0.56),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingDetailValue extends StatelessWidget {
  const _BookingDetailValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.steelBlack.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ironGray,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.paleGold,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.metas});

  final List<ActivityHistoryMeta> metas;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columnCount = constraints.maxWidth >= 520 ? 4 : 2;
        final double spacing = 10;
        final double itemWidth =
            (constraints.maxWidth - (spacing * (columnCount - 1))) /
            columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: metas.map((meta) {
            return SizedBox(
              width: itemWidth,
              child: _MetaBox(meta: meta),
            );
          }).toList(),
        );
      },
    );
  }
}

class _MetaBox extends StatelessWidget {
  const _MetaBox({required this.meta});

  final ActivityHistoryMeta meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.steelBlack.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(meta.icon, color: AppColors.gymGold, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  meta.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.silverGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            meta.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
