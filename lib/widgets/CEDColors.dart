import 'package:flutter/material.dart';

//COLOUR PALLETTE:_------------------------------------------------------------

class CEDColors {
  // COLORS FOR CALENDAR EVENTS
  static const eventSymptom = Color(0xFFE57373);
  static const eventStuhlgang = Color(0xFFFFB74D);
  static const eventMahlzeit = Color(0xFF64B5F6);
  static const eventStimmung = Color(0xFF81C784);

  // BRAND COLORS
  static const primary = Color.fromARGB(255, 114, 131, 110); //
  static const accent = Color.fromARGB(255, 119, 136, 115); //

  // BACKGROUND
  static const background = Color.fromARGB(255, 112, 128, 108);
  static const surface = Color.fromARGB(255, 241, 243, 224); // for cards/panels
  static const surfaceDark = Color.fromARGB(255, 210, 220, 182);

  // TEXT
  static const textPrimary = Color.fromARGB(255, 0, 43, 40);
  static const textSecondary = Color.fromARGB(255, 0, 56, 52);

  // BORDERS
  static const border = Color.fromARGB(255, 0, 43, 40);

  // ICONS
  static const iconPrimary = Color.fromARGB(255, 183, 95, 112);
  static const iconSecondary = Color.fromARGB(255, 113, 73, 120);

  // BUTTONS
  static const buttonBackground = Color.fromARGB(255, 0, 43, 40);
  static const buttonPrimary = accent;
  static const buttonSecondary = primary;

  // COMPATIBILTY (Remove later if no longer needed)
  static const appBarBackground = background;
  static const buttonsBackground = buttonBackground;
  static const gradientStart = background;
  static const gradientEnd = background;
  static const gradientend = gradientEnd;
}
