import 'package:flutter/material.dart';

/// Emerald Ledger design system (see DESIGN.md).
class AppTheme {
  // Surfaces
  static const Color canvas = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Ink (text tiers)
  static const Color inkPrimary = Color(0xFF0F172A);
  static const Color inkSecondary = Color(0xFF334155);
  static const Color inkMuted = Color(0xFF64748B);
  static const Color iconNeutral = Color(0xFF94A3B8);

  // Brand
  static const Color accent = Color(0xFF217346);
  static const Color accentHover = Color(0xFF165632);
  static const Color success = Color(0xFF2ECC71);

  // Financial states
  static const Color paidGreen = Color(0xFF217346);
  static const Color unpaidAmber = Color(0xFFD97706);
  static const Color overBudgetCrimson = Color(0xFFDC2626);

  // Badges
  static const Color paidBadgeBg = Color(0xFFDCFCE7);
  static const Color paidBadgeFg = Color(0xFF166534);
  static const Color pendingBadgeBg = Color(0xFFFEF3C7);
  static const Color pendingBadgeFg = Color(0xFF92400E);
  static const Color alertBadgeBg = Color(0xFFFEE2E2);
  static const Color alertBadgeFg = Color(0xFF991B1B);
  static const Color destructiveBorder = Color(0xFFFECACA);

  // Radii
  static const double radiusControl = 8;
  static const double radiusCard = 12;

  static const String fontSans = 'Manrope';
  static const String fontMono = 'JetBrains Mono';

  /// Overlay shadow for menus, dropdowns and dialogs.
  static const List<BoxShadow> overlayShadow = [
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 20,
      spreadRadius: -2,
      offset: Offset(0, 4),
    ),
  ];

  /// Monospaced tabular style for monetary values and numeric columns.
  static const TextStyle tabularNumber = TextStyle(
    fontFamily: fontMono,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static ThemeData buildTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: accent,
      onPrimary: Colors.white,
      primaryContainer: paidBadgeBg,
      onPrimaryContainer: paidBadgeFg,
      secondary: inkPrimary,
      tertiary: success,
      surface: surface,
      onSurface: inkPrimary,
      onSurfaceVariant: inkSecondary,
      outline: border,
      outlineVariant: divider,
      error: overBudgetCrimson,
      errorContainer: alertBadgeBg,
      onErrorContainer: alertBadgeFg,
      surfaceTint: Colors.transparent,
    );

    final base = ThemeData(
      useMaterial3: true,
      fontFamily: fontSans,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      splashFactory: InkRipple.splashFactory,
      hoverColor: canvas,
    );

    final textTheme = base.textTheme
        .apply(
          fontFamily: fontSans,
          bodyColor: inkPrimary,
          displayColor: inkPrimary,
        )
        .copyWith(
          headlineLarge: const TextStyle(
              fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w700),
          headlineMedium: const TextStyle(
              fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w700),
          titleLarge: const TextStyle(
              fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600),
          titleMedium: const TextStyle(
              fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600),
          bodyLarge: const TextStyle(fontSize: 16, height: 24 / 16),
          bodyMedium: const TextStyle(fontSize: 14, height: 20 / 14),
          bodySmall: const TextStyle(fontSize: 12, height: 18 / 12),
          labelSmall: const TextStyle(
              fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w500),
        );

    final controlShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusControl));

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: border),
        ),
      ),
      dividerColor: divider,
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowHeight: 40,
        dataRowMinHeight: 52,
        dataRowMaxHeight: 60,
        dividerThickness: 1,
        headingTextStyle: const TextStyle(
          fontFamily: fontSans,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: inkMuted,
        ),
        dataTextStyle: const TextStyle(
          fontFamily: fontSans,
          fontSize: 14,
          color: inkPrimary,
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return canvas;
          return Colors.transparent;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: inkMuted, fontSize: 14),
        labelStyle: const TextStyle(color: inkMuted, fontSize: 14),
        prefixIconColor: inkMuted,
        border: inputBorder(border),
        enabledBorder: inputBorder(border),
        focusedBorder: inputBorder(accent, 2),
        errorBorder: inputBorder(overBudgetCrimson),
        focusedErrorBorder: inputBorder(overBudgetCrimson, 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16)),
          shape: WidgetStatePropertyAll(controlShape),
          elevation: const WidgetStatePropertyAll(0),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
                fontFamily: fontSans,
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return border;
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered)) {
              return accentHover;
            }
            return accent;
          }),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 14)),
          shape: WidgetStatePropertyAll(controlShape),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
                fontFamily: fontSans,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          foregroundColor: const WidgetStatePropertyAll(inkSecondary),
          side: const WidgetStatePropertyAll(BorderSide(color: border)),
          backgroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.hovered) ? canvas : surface),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
          shape: WidgetStatePropertyAll(controlShape),
          foregroundColor: const WidgetStatePropertyAll(accent),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
                fontFamily: fontSans,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          overlayColor: WidgetStatePropertyAll(accent.withValues(alpha: 0.06)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.hovered) ? accent : iconNeutral),
          overlayColor: const WidgetStatePropertyAll(canvas),
          shape: WidgetStatePropertyAll(controlShape),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: iconNeutral, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? accent
                : Colors.transparent),
        checkColor: const WidgetStatePropertyAll(Colors.white),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: divider,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: border),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: fontSans,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: inkPrimary,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: const Color(0x140F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          side: const BorderSide(color: border),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusControl),
            side: const BorderSide(color: border),
          )),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: inkPrimary,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(
          fontFamily: fontSans,
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        backgroundColor: inkPrimary,
        actionTextColor: const Color(0xFF86EFAC),
        closeIconColor: iconNeutral,
        contentTextStyle: const TextStyle(
          fontFamily: fontSans,
          fontSize: 14,
          color: Colors.white,
        ),
        shape: controlShape,
      ),
    );
  }
}
