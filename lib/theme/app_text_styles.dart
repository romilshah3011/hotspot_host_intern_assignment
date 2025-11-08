import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Text Styles based on design specifications
class AppTextStyles {
  // Heading/H1-bold
  static TextStyle h1Bold(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 28,
      height: 36 / 28, // line-height: 36px
      fontWeight: FontWeight.bold,
      letterSpacing: -0.84, // -3% of 28px
      color: Colors.white,
    );
  }

  // Heading/H1-regular
  static TextStyle h1Regular(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 28,
      height: 36 / 28,
      fontWeight: FontWeight.normal,
      letterSpacing: -0.84,
      color: Colors.white,
    );
  }

  // Heading/H2-bold
  static TextStyle h2Bold(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 24,
      height: 30 / 24, // line-height: 30px
      fontWeight: FontWeight.bold,
      letterSpacing: -0.48, // -2% of 24px
      color: Colors.white,
    );
  }

  // Heading/H2-regular
  static TextStyle h2Regular(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 24,
      height: 30 / 24,
      fontWeight: FontWeight.normal,
      letterSpacing: -0.48,
      color: Colors.white,
    );
  }

  // Heading/H3-bold
  static TextStyle h3Bold(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 20,
      height: 26 / 20, // line-height: 26px
      fontWeight: FontWeight.bold,
      letterSpacing: -0.20, // -1% of 20px
      color: Colors.white,
    );
  }

  // Heading/H3-regular
  static TextStyle h3Regular(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 20,
      height: 26 / 20,
      fontWeight: FontWeight.normal,
      letterSpacing: -0.20,
      color: Colors.white,
    );
  }

  // Body/B1-bold
  static TextStyle b1Bold(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 16,
      height: 24 / 16, // line-height: 24px
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
      color: Colors.white,
    );
  }

  // Body/B1-regular
  static TextStyle b1Regular(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0,
      color: Colors.white,
    );
  }

  // Body/B2-bold
  static TextStyle b2Bold(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 14,
      height: 20 / 14, // line-height: 20px
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
      color: Colors.white,
    );
  }

  // Body/B2-regular
  static TextStyle b2Regular(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0,
      color: Colors.white,
    );
  }

  // Subtext/S1-bold
  static TextStyle s1Bold(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 12,
      height: 16 / 12, // line-height: 16px
      fontWeight: FontWeight.normal,
      letterSpacing: 0,
      color: Colors.white,
    );
  }

  // Subtext/S1-regular
  static TextStyle s1Regular(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 0,
      color: Colors.white,
    );
  }

  // Subtext/S2
  static TextStyle s2(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 10,
      height: 12 / 10, // line-height: 12px
      fontWeight: FontWeight.normal,
      letterSpacing: 0,
      color: Colors.white,
    );
  }
}
