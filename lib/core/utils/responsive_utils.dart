import 'package:flutter/material.dart';

// Classe utilitaire pour gérer le design responsive
// Adapte les tailles selon l'écran (téléphone, tablette, orientation)
class ResponsiveUtils {
  // Breakpoints pour différents types d'écrans
  static const double mobileBreakpoint = 600; // < 600: Mobile
  static const double tabletBreakpoint = 900; // 600-900: Tablette
  static const double desktopBreakpoint = 1200; // > 900: Desktop

  // Vérifie si l'écran est en mode mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  // Vérifie si l'écran est une tablette
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  // Vérifie si l'écran est en mode desktop/large
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  // Vérifie si l'orientation est portrait
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // Vérifie si l'orientation est paysage
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Retourne une valeur adaptée selon la taille d'écran
  static T valueByScreen<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  // Calcule une taille responsive basée sur la largeur d'écran
  static double responsiveSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return baseSize;
    } else if (width < desktopBreakpoint) {
      return baseSize * 1.2; // 20% plus grand pour tablette
    } else {
      return baseSize * 1.5; // 50% plus grand pour desktop
    }
  }

  // Taille de carte adaptée
  static double getCardWidth(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: 85,
      tablet: 110,
      desktop: 130,
    );
  }

  static double getCardHeight(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: 187, // ratio 1:2.2
      tablet: 242,
      desktop: 286,
    );
  }

  // Taille de police adaptée
  static double getFontSize(BuildContext context, double baseFontSize) {
    return valueByScreen(
      context: context,
      mobile: baseFontSize,
      tablet: baseFontSize * 1.15,
      desktop: baseFontSize * 1.3,
    );
  }

  // Padding adapté
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: const EdgeInsets.all(12),
      tablet: const EdgeInsets.all(16),
      desktop: const EdgeInsets.all(24),
    );
  }

  // Espacement vertical adapté
  static double getVerticalSpacing(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );
  }

  // Espacement horizontal adapté
  static double getHorizontalSpacing(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );
  }

  // Taille de l'icône adaptée
  static double getIconSize(BuildContext context, double baseSize) {
    return valueByScreen(
      context: context,
      mobile: baseSize,
      tablet: baseSize * 1.2,
      desktop: baseSize * 1.4,
    );
  }

  // Largeur maximale du contenu pour grands écrans
  static double getMaxContentWidth(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1200,
    );
  }

  // Nombre de colonnes pour une grille responsive
  static int getGridColumns(BuildContext context) {
    return valueByScreen(context: context, mobile: 2, tablet: 3, desktop: 4);
  }

  // Vérifie si l'écran est petit (pour simplifier l'UI)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  // Retourne la hauteur disponible (moins les barres système)
  static double getAvailableHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
  }

  // Retourne la largeur disponible
  static double getAvailableWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Adapte une valeur selon l'orientation
  static T valueByOrientation<T>({
    required BuildContext context,
    required T portrait,
    required T landscape,
  }) {
    return isPortrait(context) ? portrait : landscape;
  }

  // Calcule le facteur de scale pour les animations
  static double getScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 0.85;
    if (width < mobileBreakpoint) return 1.0;
    if (width < desktopBreakpoint) return 1.15;
    return 1.3;
  }
}
