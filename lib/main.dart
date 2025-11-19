import 'package:cedmate/models/app_user.dart';
import 'package:cedmate/repositories/anamnese_repository.dart';
import 'package:cedmate/repositories/mahlzeit_repository.dart';
import 'package:cedmate/repositories/stimmung_repository.dart';
import 'package:cedmate/repositories/stuhlgang_repository.dart';
import 'package:cedmate/repositories/symptom_repository.dart';
import 'package:cedmate/services/anamnese_service.dart';
import 'package:cedmate/services/mahlzeit_service.dart';
import 'package:cedmate/services/stimmung_service.dart';
import 'package:cedmate/services/stuhlgang_service.dart';
import 'package:cedmate/services/symptom_service.dart';
import 'package:cedmate/widgets/CEDColors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'repositories/auth_repository.dart';
import 'services/auth_service.dart';
import 'widgets/auth_gate.dart';
import 'widgets/home_screen.dart';

/// Einstiegspunkt der App.
/// - Initialisiert Firebase
/// - Registriert Repository + Service in Provider (Dependency Injection)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisiert das native Firebase SDK mit deinen Projekt-Keys
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const CEDmateApp());
}

class CEDmateApp extends StatelessWidget {
  const CEDmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repository spricht direkt mit Firebase (Auth + Firestore)
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        // Service kapselt Business-Logik + Validierung
        ProxyProvider<AuthRepository, AuthService>(
          update: (_, repo, __) => AuthService(repo),
        ),
        Provider<AnamneseRepository>(create: (_) => AnamneseRepository()),
        ProxyProvider<AnamneseRepository, AnamneseService>(
          update: (_, repo, __) => AnamneseService(repo),
        ),
        Provider<SymptomRepository>(create: (_) => SymptomRepository()),
        ProxyProvider2<SymptomRepository, AuthService, SymptomService>(
          update: (_, repo, auth, __) => SymptomService(repo, auth),
        ),
        StreamProvider<AppUser?>(
          create: (context) => context.read<AuthService>().userStream(),
          initialData: null,
        ),
        Provider<StuhlgangRepository>(create: (_) => StuhlgangRepository()),
        ProxyProvider2<StuhlgangRepository, AuthService, StuhlgangService>(
          update: (_, repo, auth, __) => StuhlgangService(repo, auth),
        ),
        Provider<StimmungRepository>(create: (_) => StimmungRepository()),
        ProxyProvider2<StimmungRepository, AuthService, StimmungService>(
          update: (_, repo, auth, __) => StimmungService(repo, auth),
        ),
        Provider<MahlzeitRepository>(create: (_) => MahlzeitRepository()),
        ProxyProvider2<MahlzeitRepository, AuthService, MahlzeitService>(
          update: (_, repo, auth, __) => MahlzeitService(repo, auth),
        ),
      ],
      child: MaterialApp(
        locale: Locale('de', 'DE'),
        supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
        localizationsDelegates: [
          // Diese Delegates sind wichtig für showDatePicker!
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        title: 'CEDmate',
        routes: {
          '/': (_) => const AuthGate(), // entscheidet: Login oder Home?
          '/home': (_) => const HomeScreen(), // private Startseite
        },
        builder: (context, child) {
          if (child == null) {
            // Wenn kein Child vorhanden ist, gib einfach ein leeres Widget zurück
            return const SizedBox.shrink();
          }

          // sonst normale Darstellung
          return Container(
            color: Colors.white,
            child: SafeArea(child: child),
          );
        },
        theme: ThemeData(
          useMaterial3: false,
          brightness: Brightness.light,
          scaffoldBackgroundColor: CEDColors.background,
          textTheme: GoogleFonts.interTextTheme().copyWith(
            bodyLarge: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: CEDColors.primaryText,
            ),
            bodyMedium: const TextStyle(
              fontSize: 14,
              color: CEDColors.primaryText,
            ),
            titleLarge: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CEDColors.primaryText,
            ),
            titleMedium: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CEDColors.primaryText,
            ),
          ),
          // AppBar minimalistisch
          appBarTheme: const AppBarTheme(
            backgroundColor: CEDColors.appBarBackground,
            foregroundColor: CEDColors.primaryText,
            elevation: 10,
            shadowColor: CEDColors.appBarBackground,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CEDColors.primaryText,
            ),
          ),

          // Allgemeine Icons
          iconTheme: const IconThemeData(
            color: CEDColors.primaryText,
            size: 26,
          ),

          // Buttons
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: CEDColors.buttonsBackground,
              foregroundColor: CEDColors.primaryText,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Alle Container-Borders
          dividerColor: CEDColors.border,
        ),
      ),
    );
  }
}
