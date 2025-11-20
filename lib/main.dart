// -----------------------------------------------------------------------------
//  MAIN FILE — CLEAN, SAFE, MODERN
// -----------------------------------------------------------------------------

import 'package:cedmate/widgets/ess_tagebuch_fuer_monat.dart';
import 'package:cedmate/widgets/hilfe_fuer_unterwegs.dart';
import 'package:cedmate/widgets/impressum_credits_screen.dart';
import 'package:cedmate/widgets/mahlzeit_eintragen.dart';
import 'package:cedmate/widgets/profil_screen.dart';
import 'package:cedmate/widgets/seelen_log_fuer_monat.dart';
import 'package:cedmate/widgets/stuhlgang_eintraege_fuer_monat.dart';
import 'package:cedmate/widgets/stuhlgang_notieren.dart';
import 'package:cedmate/widgets/symptome_fuer_datum.dart';
import 'package:cedmate/widgets/symptome_fuer_monat.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';

// MODELS
import 'package:cedmate/models/app_user.dart';

// REPOSITORIES
import 'package:cedmate/repositories/auth_repository.dart';
import 'package:cedmate/repositories/anamnese_repository.dart';
import 'package:cedmate/repositories/symptom_repository.dart';
import 'package:cedmate/repositories/stuhlgang_repository.dart';
import 'package:cedmate/repositories/stimmung_repository.dart';
import 'package:cedmate/repositories/mahlzeit_repository.dart';

// SERVICES
import 'package:cedmate/services/auth_service.dart';
import 'package:cedmate/services/anamnese_service.dart';
import 'package:cedmate/services/symptom_service.dart';
import 'package:cedmate/services/stuhlgang_service.dart';
import 'package:cedmate/services/stimmung_service.dart';
import 'package:cedmate/services/mahlzeit_service.dart';

// UI
import 'widgets/auth_gate.dart';
import 'widgets/home_screen.dart';
import 'widgets/CEDColors.dart';

// -----------------------------------------------------------------------------
//  APP ENTRY POINT
// -----------------------------------------------------------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CEDmateApp());
}

// -----------------------------------------------------------------------------
//  ROOT APP WIDGET
// -----------------------------------------------------------------------------
class CEDmateApp extends StatelessWidget {
  const CEDmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AUTH
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        ProxyProvider<AuthRepository, AuthService>(
          update: (_, repo, __) => AuthService(repo),
        ),

        // ANAMNESE
        Provider<AnamneseRepository>(create: (_) => AnamneseRepository()),
        ProxyProvider<AnamneseRepository, AnamneseService>(
          update: (_, repo, __) => AnamneseService(repo),
        ),

        // SYMPTOMS
        Provider<SymptomRepository>(create: (_) => SymptomRepository()),
        ProxyProvider2<SymptomRepository, AuthService, SymptomService>(
          update: (_, repo, auth, __) => SymptomService(repo, auth),
        ),

        // STOOL
        Provider<StuhlgangRepository>(create: (_) => StuhlgangRepository()),
        ProxyProvider2<StuhlgangRepository, AuthService, StuhlgangService>(
          update: (_, repo, auth, __) => StuhlgangService(repo, auth),
        ),

        // MOOD
        Provider<StimmungRepository>(create: (_) => StimmungRepository()),
        ProxyProvider2<StimmungRepository, AuthService, StimmungService>(
          update: (_, repo, auth, __) => StimmungService(repo, auth),
        ),

        // MEALS
        Provider<MahlzeitRepository>(create: (_) => MahlzeitRepository()),
        ProxyProvider2<MahlzeitRepository, AuthService, MahlzeitService>(
          update: (_, repo, auth, __) => MahlzeitService(repo, auth),
        ),

        // USER STREAM
        StreamProvider<AppUser?>(
          create: (context) => context.read<AuthService>().userStream(),
          initialData: null,
        ),
      ],

      // -------------------------------------------------------------------------
      //  ROOT MATERIAL APP
      // -------------------------------------------------------------------------
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CEDmate',

        locale: const Locale('de', 'DE'),
        supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        routes: {
          '/': (_) => const AuthGate(), // Login oder Home
          '/home': (_) => const HomeScreen(), // Startseite nach Login
          '/profil': (_) => const ProfilScreen(),
          '/symptomeMonat': (_) => SymptomeFuerMonat(),
          '/stuhlMonat': (_) => const StuhlgangEintraegeFuerMonat(),
          '/essenMonat': (_) => EssTagebuchFuerMonat(),
          '/stimmungMonat': (_) => StimmungFuerMonat(),
          '/hilfeUnterwegs': (_) => HilfeFuerUnterwegs(),
          '/credits': (_) => ImpressumCreditsScreen(),
        },

        builder: (context, child) =>
            child == null ? const SizedBox.shrink() : SafeArea(child: child),

        // =====================================================================
        //  THEME — CLEAN, COMPLETE, NO NULL VALUES
        // =====================================================================
        theme: ThemeData(
          useMaterial3: false,
          brightness: Brightness.light,

          // ------------------------------
          // BACKGROUND COLORS
          // ------------------------------
          scaffoldBackgroundColor: CEDColors.background,
          canvasColor: CEDColors.background,
          cardColor: CEDColors.surface,

          // ------------------------------
          // TEXT THEMING
          // ------------------------------
          textTheme: GoogleFonts.interTextTheme().copyWith(
            bodyLarge: TextStyle(color: CEDColors.textPrimary, fontSize: 16),
            bodyMedium: TextStyle(color: CEDColors.textPrimary, fontSize: 14),
            bodySmall: TextStyle(color: CEDColors.textSecondary, fontSize: 12),
            titleMedium: TextStyle(
              color: CEDColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
            titleLarge: TextStyle(
              color: CEDColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),

          // ------------------------------
          // APP BAR
          // ------------------------------
          appBarTheme: AppBarTheme(
            backgroundColor: CEDColors.surface,
            foregroundColor: CEDColors.textPrimary,
            elevation: 0,
            titleTextStyle: GoogleFonts.inter(
              color: CEDColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),

          // ------------------------------
          // ICONS
          // ------------------------------
          iconTheme: IconThemeData(color: CEDColors.textPrimary, size: 26),

          // ------------------------------
          // BUTTONS
          // ------------------------------
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: CEDColors.buttonPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ------------------------------
          // INPUT FIELDS  (FIXED + SAFE)
          // ------------------------------
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: CEDColors.surface,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: CEDColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: CEDColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: CEDColors.accent, width: 2),
            ),

            labelStyle: TextStyle(color: CEDColors.textSecondary),
            hintStyle: TextStyle(color: CEDColors.textSecondary),

            iconColor: CEDColors.textPrimary,
            prefixIconColor: CEDColors.textPrimary,
            suffixIconColor: CEDColors.textPrimary,
          ),

          // ------------------------------
          // DROPDOWN MENUS
          // ------------------------------
          dropdownMenuTheme: DropdownMenuThemeData(
            textStyle: TextStyle(color: CEDColors.textPrimary),
            menuStyle: MenuStyle(
              backgroundColor: MaterialStateProperty.all(CEDColors.surface),
              side: MaterialStateProperty.all(
                BorderSide(color: CEDColors.border),
              ),
            ),
          ),

          // ------------------------------
          // DIVIDERS
          // ------------------------------
          dividerColor: CEDColors.border,
        ),
      ),
    );
  }
}
