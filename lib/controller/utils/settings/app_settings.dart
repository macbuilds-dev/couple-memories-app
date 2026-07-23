import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  /// Eight families — each has light + dark tones.
  static const List<ColorPalette> colorPalettes = [
    ColorPalette(
      name: 'Universal Love',
      id: 'universal_love',
      defaultDark: false,
      light: PaletteTone(
        primaryColor: Color(0xFFFFB6C1),
        secondaryColor: Color(0xFFE91E63),
        surfaceColor: Color(0xFFFFFBFB),
        accentColor: Color(0xFFFFE0E6),
        textPrimary: Color(0xFF2C2C2C),
        textSecondary: Color(0xFFB76E79),
      ),
      dark: PaletteTone(
        primaryColor: Color(0xFF5C2A3A),
        secondaryColor: Color(0xFFFF6B9D),
        surfaceColor: Color(0xFF1A1216),
        accentColor: Color(0xFF3A1F2A),
        textPrimary: Color(0xFFF8EDEF),
        textSecondary: Color(0xFFFFB6C1),
      ),
    ),
    ColorPalette(
      name: 'Romantic Rose',
      id: 'romantic_rose',
      defaultDark: false,
      light: PaletteTone(
        primaryColor: Color(0xFFFFB6C1),
        secondaryColor: Color(0xFFB76E79),
        surfaceColor: Color(0xFFFFF5EE),
        accentColor: Color(0xFFE6E6FA),
        textPrimary: Color(0xFF2C3E50),
        textSecondary: Color(0xFFB76E79),
      ),
      dark: PaletteTone(
        primaryColor: Color(0xFF4A2C33),
        secondaryColor: Color(0xFFE8A0AB),
        surfaceColor: Color(0xFF171014),
        accentColor: Color(0xFF2E1C24),
        textPrimary: Color(0xFFF6ECEE),
        textSecondary: Color(0xFFE8A0AB),
      ),
    ),
    ColorPalette(
      name: 'Ocean Breeze',
      id: 'ocean_breeze',
      defaultDark: false,
      light: PaletteTone(
        primaryColor: Color(0xFF87CEEB),
        secondaryColor: Color(0xFF4682B4),
        surfaceColor: Color(0xFFF0F8FF),
        accentColor: Color(0xFFE0F7FA),
        textPrimary: Color(0xFF1A237E),
        textSecondary: Color(0xFF4682B4),
      ),
      dark: PaletteTone(
        primaryColor: Color(0xFF1E3A5F),
        secondaryColor: Color(0xFF7EC8E3),
        surfaceColor: Color(0xFF0D1520),
        accentColor: Color(0xFF162636),
        textPrimary: Color(0xFFE8F1FA),
        textSecondary: Color(0xFF7EC8E3),
      ),
    ),
    ColorPalette(
      name: 'Sunset Dream',
      id: 'sunset_dream',
      defaultDark: false,
      light: PaletteTone(
        primaryColor: Color(0xFFFFA07A),
        secondaryColor: Color(0xFFFF6347),
        surfaceColor: Color(0xFFFFF8F0),
        accentColor: Color(0xFFFFE4E1),
        textPrimary: Color(0xFF5D4037),
        textSecondary: Color(0xFFFF6347),
      ),
      dark: PaletteTone(
        primaryColor: Color(0xFF5A2E22),
        secondaryColor: Color(0xFFFF8A65),
        surfaceColor: Color(0xFF1A100E),
        accentColor: Color(0xFF2E1A14),
        textPrimary: Color(0xFFFFF0E8),
        textSecondary: Color(0xFFFFAB91),
      ),
    ),
    ColorPalette(
      name: 'Lavender Fields',
      id: 'lavender_fields',
      defaultDark: false,
      light: PaletteTone(
        primaryColor: Color(0xFFE6E6FA),
        secondaryColor: Color(0xFF9370DB),
        surfaceColor: Color(0xFFFAF0FF),
        accentColor: Color(0xFFF0E6FF),
        textPrimary: Color(0xFF4A148C),
        textSecondary: Color(0xFF9370DB),
      ),
      dark: PaletteTone(
        primaryColor: Color(0xFF3A2A5C),
        secondaryColor: Color(0xFFB39DDB),
        surfaceColor: Color(0xFF14101C),
        accentColor: Color(0xFF241C36),
        textPrimary: Color(0xFFF3EDFF),
        textSecondary: Color(0xFFB39DDB),
      ),
    ),
    ColorPalette(
      name: 'Forest Serenity',
      id: 'forest_serenity',
      defaultDark: false,
      light: PaletteTone(
        primaryColor: Color(0xFF98D8C8),
        secondaryColor: Color(0xFF6B8E23),
        surfaceColor: Color(0xFFF5FFFA),
        accentColor: Color(0xFFE8F5E9),
        textPrimary: Color(0xFF1B5E20),
        textSecondary: Color(0xFF6B8E23),
      ),
      dark: PaletteTone(
        primaryColor: Color(0xFF1F3D32),
        secondaryColor: Color(0xFFA5D6A7),
        surfaceColor: Color(0xFF0E1612),
        accentColor: Color(0xFF1A2A22),
        textPrimary: Color(0xFFE8F5E9),
        textSecondary: Color(0xFFA5D6A7),
      ),
    ),
    ColorPalette(
      name: 'Golden Hour',
      id: 'golden_hour',
      defaultDark: false,
      light: PaletteTone(
        primaryColor: Color(0xFFFFD700),
        secondaryColor: Color(0xFFFF8C00),
        surfaceColor: Color(0xFFFFFEF0),
        accentColor: Color(0xFFFFF8DC),
        textPrimary: Color(0xFF8B4513),
        textSecondary: Color(0xFFFF8C00),
      ),
      dark: PaletteTone(
        primaryColor: Color(0xFF4A3A12),
        secondaryColor: Color(0xFFFFB74D),
        surfaceColor: Color(0xFF16120A),
        accentColor: Color(0xFF2A220E),
        textPrimary: Color(0xFFFFF8E1),
        textSecondary: Color(0xFFFFCC80),
      ),
    ),
    ColorPalette(
      name: 'Midnight Blue',
      id: 'midnight_blue',
      defaultDark: true,
      light: PaletteTone(
        primaryColor: Color(0xFF9FA8DA),
        secondaryColor: Color(0xFF4169E1),
        surfaceColor: Color(0xFFF0F4FF),
        accentColor: Color(0xFFE3F2FD),
        textPrimary: Color(0xFF0D47A1),
        textSecondary: Color(0xFF4169E1),
      ),
      dark: PaletteTone(
        primaryColor: Color(0xFF191970),
        secondaryColor: Color(0xFF82B1FF),
        surfaceColor: Color(0xFF0A0E1A),
        accentColor: Color(0xFF151B2E),
        textPrimary: Color(0xFFE8EEFF),
        textSecondary: Color(0xFF82B1FF),
      ),
    ),
  ];

  // Font Options (for individual fonts)
  static const List<FontOption> fontOptions = [
    FontOption(name: 'Playfair Display', id: 'playfair', package: 'google_fonts'),
    FontOption(name: 'Dancing Script', id: 'dancing', package: 'google_fonts'),
    FontOption(name: 'Cormorant Garamond', id: 'cormorant', package: 'google_fonts'),
    FontOption(name: 'Lora', id: 'lora', package: 'google_fonts'),
    FontOption(name: 'Merriweather', id: 'merriweather', package: 'google_fonts'),
    FontOption(name: 'Poppins', id: 'poppins', package: 'google_fonts'),
    FontOption(name: 'Roboto', id: 'roboto', package: 'google_fonts'),
    FontOption(name: 'Montserrat', id: 'montserrat', package: 'google_fonts'),
    FontOption(name: 'Raleway', id: 'raleway', package: 'google_fonts'),
    FontOption(name: 'Open Sans', id: 'opensans', package: 'google_fonts'),
    FontOption(name: 'Nunito', id: 'nunito', package: 'google_fonts'),
    FontOption(name: 'Inter', id: 'inter', package: 'google_fonts'),
    FontOption(name: 'Source Sans Pro', id: 'sourcesans', package: 'google_fonts'),
    FontOption(name: 'Quicksand', id: 'quicksand', package: 'google_fonts'),
    FontOption(name: 'Comfortaa', id: 'comfortaa', package: 'google_fonts'),
    FontOption(name: 'Pacifico', id: 'pacifico', package: 'google_fonts'),
    FontOption(name: 'Great Vibes', id: 'greatvibes', package: 'google_fonts'),
    FontOption(name: 'Satisfy', id: 'satisfy', package: 'google_fonts'),
  ];

  // Font Combinations (Heading + Body)
  static const List<FontCombination> fontCombinations = [
    FontCombination(
      name: 'Classic Elegance',
      id: 'classic_elegance',
      headingFont: FontOption(name: 'Playfair Display', id: 'playfair', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Poppins', id: 'poppins', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Romantic Script',
      id: 'romantic_script',
      headingFont: FontOption(name: 'Dancing Script', id: 'dancing', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Lora', id: 'lora', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Modern Minimal',
      id: 'modern_minimal',
      headingFont: FontOption(name: 'Montserrat', id: 'montserrat', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Roboto', id: 'roboto', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Serif Sophistication',
      id: 'serif_sophistication',
      headingFont: FontOption(name: 'Cormorant Garamond', id: 'cormorant', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Merriweather', id: 'merriweather', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Clean & Clear',
      id: 'clean_clear',
      headingFont: FontOption(name: 'Raleway', id: 'raleway', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Open Sans', id: 'opensans', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Timeless Classic',
      id: 'timeless_classic',
      headingFont: FontOption(name: 'Playfair Display', id: 'playfair', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Lora', id: 'lora', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Bold & Beautiful',
      id: 'bold_beautiful',
      headingFont: FontOption(name: 'Montserrat', id: 'montserrat', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Poppins', id: 'poppins', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Elegant Script',
      id: 'elegant_script',
      headingFont: FontOption(name: 'Dancing Script', id: 'dancing', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Cormorant Garamond', id: 'cormorant', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Friendly Modern',
      id: 'friendly_modern',
      headingFont: FontOption(name: 'Nunito', id: 'nunito', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Open Sans', id: 'opensans', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Professional Clean',
      id: 'professional_clean',
      headingFont: FontOption(name: 'Inter', id: 'inter', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Source Sans Pro', id: 'sourcesans', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Playful & Fun',
      id: 'playful_fun',
      headingFont: FontOption(name: 'Quicksand', id: 'quicksand', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Comfortaa', id: 'comfortaa', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Casual Script',
      id: 'casual_script',
      headingFont: FontOption(name: 'Pacifico', id: 'pacifico', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Roboto', id: 'roboto', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Elegant Calligraphy',
      id: 'elegant_calligraphy',
      headingFont: FontOption(name: 'Great Vibes', id: 'greatvibes', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Lora', id: 'lora', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Satisfying Script',
      id: 'satisfying_script',
      headingFont: FontOption(name: 'Satisfy', id: 'satisfy', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Poppins', id: 'poppins', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Bold Serif',
      id: 'bold_serif',
      headingFont: FontOption(name: 'Cormorant Garamond', id: 'cormorant', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Merriweather', id: 'merriweather', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Modern Sans',
      id: 'modern_sans',
      headingFont: FontOption(name: 'Montserrat', id: 'montserrat', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Nunito', id: 'nunito', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Classic Serif',
      id: 'classic_serif',
      headingFont: FontOption(name: 'Playfair Display', id: 'playfair', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Merriweather', id: 'merriweather', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Light & Airy',
      id: 'light_airy',
      headingFont: FontOption(name: 'Raleway', id: 'raleway', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Open Sans', id: 'opensans', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Romantic Elegance',
      id: 'romantic_elegance',
      headingFont: FontOption(name: 'Dancing Script', id: 'dancing', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Lora', id: 'lora', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Contemporary',
      id: 'contemporary',
      headingFont: FontOption(name: 'Inter', id: 'inter', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Roboto', id: 'roboto', package: 'google_fonts'),
    ),
    FontCombination(
      name: 'Warm & Welcoming',
      id: 'warm_welcoming',
      headingFont: FontOption(name: 'Quicksand', id: 'quicksand', package: 'google_fonts'),
      bodyFont: FontOption(name: 'Poppins', id: 'poppins', package: 'google_fonts'),
    ),
  ];

  // Text Customization
  String appTitle = 'Our Love Story';
  String appSubtitle = 'Forever and Always';
  String newMemoryButton = 'New Memory';
  String timelineTab = 'Timeline';
  String galleryTab = 'Gallery';
  String favoritesTab = 'Favorites';

  /// When true, use each palette's dark tone.
  bool isDarkMode = false;

  // Selected Settings
  ColorPalette selectedPalette;
  FontCombination selectedFontCombination;

  AppSettings({
    ColorPalette? selectedPalette,
    FontCombination? selectedFontCombination,
    bool? isDarkMode,
  })  : selectedPalette = selectedPalette ?? colorPalettes.first,
        selectedFontCombination =
            selectedFontCombination ?? fontCombinations.first,
        isDarkMode = isDarkMode ?? (selectedPalette ?? colorPalettes.first).defaultDark;

  PaletteTone get activeTone =>
      isDarkMode ? selectedPalette.dark : selectedPalette.light;

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = AppSettings();

    final paletteId = prefs.getString('color_palette_id') ?? 'universal_love';
    settings.selectedPalette = colorPalettes.firstWhere(
      (p) => p.id == paletteId,
      orElse: () => colorPalettes.first,
    );

    final fontCombinationId =
        prefs.getString('font_combination_id') ?? 'classic_elegance';
    settings.selectedFontCombination = fontCombinations.firstWhere(
      (fc) => fc.id == fontCombinationId,
      orElse: () => fontCombinations.first,
    );

    if (prefs.containsKey('is_dark_mode')) {
      settings.isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    } else {
      settings.isDarkMode = settings.selectedPalette.defaultDark;
    }

    settings.appTitle = prefs.getString('app_title') ?? 'Our Love Story';
    settings.appSubtitle = prefs.getString('app_subtitle') ?? 'Forever and Always';
    settings.newMemoryButton =
        prefs.getString('new_memory_button') ?? 'New Memory';
    settings.timelineTab = prefs.getString('timeline_tab') ?? 'Timeline';
    settings.galleryTab = prefs.getString('gallery_tab') ?? 'Gallery';
    settings.favoritesTab = prefs.getString('favorites_tab') ?? 'Favorites';

    return settings;
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('color_palette_id', selectedPalette.id);
    await prefs.setBool('is_dark_mode', isDarkMode);
    await prefs.setString('font_combination_id', selectedFontCombination.id);
    await prefs.setString('app_title', appTitle);
    await prefs.setString('app_subtitle', appSubtitle);
    await prefs.setString('new_memory_button', newMemoryButton);
    await prefs.setString('timeline_tab', timelineTab);
    await prefs.setString('gallery_tab', galleryTab);
    await prefs.setString('favorites_tab', favoritesTab);
  }

  Map<String, dynamic> toSyncMap() => {
        'colorPaletteId': selectedPalette.id,
        'isDarkMode': isDarkMode,
        'fontCombinationId': selectedFontCombination.id,
        'appTitle': appTitle,
        'appSubtitle': appSubtitle,
        'newMemoryButton': newMemoryButton,
        'timelineTab': timelineTab,
        'galleryTab': galleryTab,
        'favoritesTab': favoritesTab,
      };

  static AppSettings fromSyncMap(Map<String, dynamic> data) {
    final settings = AppSettings();
    final paletteId = data['colorPaletteId'] as String? ?? 'universal_love';
    settings.selectedPalette = colorPalettes.firstWhere(
      (p) => p.id == paletteId,
      orElse: () => colorPalettes.first,
    );
    if (data.containsKey('isDarkMode')) {
      settings.isDarkMode = data['isDarkMode'] == true;
    } else {
      settings.isDarkMode = settings.selectedPalette.defaultDark;
    }
    final fontId = data['fontCombinationId'] as String? ?? 'classic_elegance';
    settings.selectedFontCombination = fontCombinations.firstWhere(
      (fc) => fc.id == fontId,
      orElse: () => fontCombinations.first,
    );
    settings.appTitle = data['appTitle'] as String? ?? settings.appTitle;
    settings.appSubtitle =
        data['appSubtitle'] as String? ?? settings.appSubtitle;
    settings.newMemoryButton =
        data['newMemoryButton'] as String? ?? settings.newMemoryButton;
    settings.timelineTab =
        data['timelineTab'] as String? ?? settings.timelineTab;
    settings.galleryTab = data['galleryTab'] as String? ?? settings.galleryTab;
    settings.favoritesTab =
        data['favoritesTab'] as String? ?? settings.favoritesTab;
    return settings;
  }

  bool hasSameSyncValues(AppSettings other) =>
      selectedPalette.id == other.selectedPalette.id &&
      isDarkMode == other.isDarkMode &&
      selectedFontCombination.id == other.selectedFontCombination.id &&
      appTitle == other.appTitle &&
      appSubtitle == other.appSubtitle &&
      newMemoryButton == other.newMemoryButton &&
      timelineTab == other.timelineTab &&
      galleryTab == other.galleryTab &&
      favoritesTab == other.favoritesTab;
}

class PaletteTone {
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;

  const PaletteTone({
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
  });
}

class ColorPalette {
  final String name;
  final String id;
  final bool defaultDark;
  final PaletteTone light;
  final PaletteTone dark;

  const ColorPalette({
    required this.name,
    required this.id,
    required this.defaultDark,
    required this.light,
    required this.dark,
  });

  /// Preview swatches use the light tone in the picker grid.
  Color get primaryColor => light.primaryColor;
  Color get secondaryColor => light.secondaryColor;
  Color get surfaceColor => light.surfaceColor;
  Color get accentColor => light.accentColor;
  Color get textPrimary => light.textPrimary;
  Color get textSecondary => light.textSecondary;
}

class FontOption {
  final String name;
  final String id;
  final String package;

  const FontOption({
    required this.name,
    required this.id,
    required this.package,
  });
}

class FontCombination {
  final String name;
  final String id;
  final FontOption headingFont;
  final FontOption bodyFont;

  const FontCombination({
    required this.name,
    required this.id,
    required this.headingFont,
    required this.bodyFont,
  });
}
