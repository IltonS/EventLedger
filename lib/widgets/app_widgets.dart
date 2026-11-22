import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Pill-shaped status badge (Pago / Pendente / alert).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  factory StatusBadge.paid() => const StatusBadge(
        label: 'Pago',
        background: AppTheme.paidBadgeBg,
        foreground: AppTheme.paidBadgeFg,
        icon: Icons.check_rounded,
      );

  factory StatusBadge.pending() => const StatusBadge(
        label: 'Pendente',
        background: AppTheme.pendingBadgeBg,
        foreground: AppTheme.pendingBadgeFg,
        icon: Icons.schedule_rounded,
      );

  factory StatusBadge.forPaid(bool isPaid) =>
      isPaid ? StatusBadge.paid() : StatusBadge.pending();

  final String label;
  final Color background;
  final Color foreground;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Unified pill cluster used for Todas / Pagas / Pendentes style filters.
class SegmentedFilterBar<T> extends StatelessWidget {
  const SegmentedFilterBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.divider,
        borderRadius: BorderRadius.circular(AppTheme.radiusControl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.entries.map((entry) {
          final isActive = entry.key == selected;
          return GestureDetector(
            onTap: () => onChanged(entry.key),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isActive ? AppTheme.border : Colors.transparent,
                  ),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? AppTheme.inkPrimary : AppTheme.inkMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Destructive (Excluir) outlined button style per the design system.
ButtonStyle destructiveButtonStyle() => OutlinedButton.styleFrom(
      foregroundColor: AppTheme.overBudgetCrimson,
      side: const BorderSide(color: AppTheme.destructiveBorder),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.hovered)
              ? AppTheme.alertBadgeBg
              : AppTheme.surface),
    );

/// Slim progress bar with rounded ends.
class LedgerProgressBar extends StatelessWidget {
  const LedgerProgressBar({
    super.key,
    required this.value,
    this.color = AppTheme.accent,
    this.height = 6,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: AppTheme.divider,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
