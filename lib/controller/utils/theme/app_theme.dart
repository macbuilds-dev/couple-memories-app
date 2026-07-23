import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../settings/settings_controller.dart';
import '../settings/app_settings.dart';

class AppTheme {
  // Get settings controller
  static SettingsController? get _settingsController {
    try {
      return Get.find<SettingsController>();
    } catch (e) {
      return null;
    }
  }

  // Get current settings
  static AppSettings get _settings {
    final controller = _settingsController;
    if (controller != null && controller.settings.value != null) {
      return controller.settings.value;
    }
    return _defaultSettings;
  }
  
  static final AppSettings _defaultSettings = AppSettings();

  static PaletteTone get _tone => _settings.activeTone;

  // Colors - reactive to settings + light/dark mode
  static Color get primaryColor => _tone.primaryColor;
  static Color get secondaryColor => _tone.secondaryColor;
  static Color get surfaceColor => _tone.surfaceColor;
  static Color get accentColor => _tone.accentColor;
  static Color get textPrimary => _tone.textPrimary;
  static Color get textSecondary => _tone.textSecondary;

  static bool get isDarkMode => _settings.isDarkMode;

  // Font Sizes (Base sizes - will be scaled with responsive_sizer)
  static const double fontSizeSmall = 12.0;
  static const double fontSizeBody = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeHeading = 28.0;
  static const double fontSizeTitle = 32.0;
  static const double fontSizeDisplay = 36.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;

  // Border Radius
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusXXXL = 30.0;

  // Helper method to get GoogleFonts by font ID
  static TextStyle _getFontStyle(String fontId, {
    required double fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  })
  {
    switch (fontId) {
      case 'playfair':
        return GoogleFonts.playfairDisplay(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.bold,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'dancing':
        return GoogleFonts.dancingScript(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.w500,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'cormorant':
        return GoogleFonts.cormorantGaramond(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.bold,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'lora':
        return GoogleFonts.lora(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'merriweather':
        return GoogleFonts.merriweather(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'poppins':
        return GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'roboto':
        return GoogleFonts.roboto(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'montserrat':
        return GoogleFonts.montserrat(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.bold,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'raleway':
        return GoogleFonts.raleway(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.bold,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'opensans':
        return GoogleFonts.openSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'nunito':
        return GoogleFonts.nunito(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'inter':
        return GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'sourcesans':
        return GoogleFonts.sourceSans3(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'quicksand':
        return GoogleFonts.quicksand(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'comfortaa':
        return GoogleFonts.comfortaa(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'pacifico':
        return GoogleFonts.pacifico(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'greatvibes':
        return GoogleFonts.greatVibes(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case 'satisfy':
        return GoogleFonts.satisfy(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      default:
        return GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
    }
  }

  // Text Styles - reactive to settings
  static TextStyle getHeadingStyle({Color? color, double? fontSize}) {
    final settings = _settings;
    return _getFontStyle(
      settings.selectedFontCombination.headingFont.id,
      fontSize: fontSize ?? fontSizeHeading,
      color: color ?? textSecondary,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );
  }

  static TextStyle getTitleStyle({Color? color, double? fontSize}) {
    final settings = _settings;
    return _getFontStyle(
      settings.selectedFontCombination.headingFont.id,
      fontSize: fontSize ?? fontSizeTitle,
      color: color ?? textSecondary,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
    );
  }

  static TextStyle getBodyStyle({Color? color, double? fontSize}) {
    final settings = _settings;
    return _getFontStyle(
      settings.selectedFontCombination.bodyFont.id,
      fontSize: fontSize ?? fontSizeBody,
      color: color ?? textPrimary,
      height: 1.6,
    );
  }

  static TextStyle getCaptionStyle({Color? color, double? fontSize}) {
    final settings = _settings;
    return _getFontStyle(
      settings.selectedFontCombination.bodyFont.id,
      fontSize: fontSize ?? fontSizeSmall,
      color: color ?? textSecondary.withOpacity(0.6),
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle getScriptStyle({Color? color, double? fontSize}) {
    final settings = _settings;
    return _getFontStyle(
      settings.selectedFontCombination.headingFont.id,
      fontSize: fontSize ?? fontSizeLarge,
      color: color ?? textSecondary,
      fontWeight: FontWeight.w500,
    );
  }

  // Gradients - reactive to settings
  static LinearGradient get primaryGradient => LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          surfaceColor,
          primaryColor.withOpacity(0.1),
        ],
      );

  static LinearGradient get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor.withOpacity(0.3),
          accentColor.withOpacity(0.3),
        ],
      );

  /// Dark surfaces for timeline, moments, preview sheet, and bottom nav.
  static Color get darkSurfaceColor {
    return Color.alphaBlend(
      secondaryColor.withValues(alpha: 0.12),
      textPrimary,
    );
  }

  static Color get navBarColor => darkSurfaceColor;

  static Color get navInactiveColor => Color.alphaBlend(
        Colors.white.withValues(alpha: 0.45),
        darkSurfaceColor,
      );

  /// Text on dark gradients / darkSurfaceColor (auth, onboarding, discover).
  static const Color onDarkHeadline = Colors.white;

  static Color get onDarkBody => Colors.white.withValues(alpha: 0.88);

  static Color get onDarkCaption => Colors.white.withValues(alpha: 0.72);

  static Color get onDarkMuted => Colors.white.withValues(alpha: 0.55);

  static Color get onDarkBorder => Colors.white.withValues(alpha: 0.35);

  static Color get onDarkDivider => Colors.white.withValues(alpha: 0.2);

  // Theme Data
  static ThemeData get themeData {
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;
    return ThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: surfaceColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimary,
        error: const Color(0xFFCF6679),
        onError: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: getBodyStyle(color: textPrimary),
      ),
      textTheme: TextTheme(
        displayLarge: getTitleStyle(),
        displayMedium: getHeadingStyle(),
        bodyLarge: getBodyStyle(),
        bodyMedium: getBodyStyle(fontSize: fontSizeMedium),
        bodySmall: getCaptionStyle(),
      ),
    );
  }
}