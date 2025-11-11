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
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
          scaffoldBackgroundColor: Colors.white,

          // Standard-Schriftfarbe
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black),
            bodySmall: TextStyle(color: Colors.black),
            titleLarge: TextStyle(color: Colors.black),
            titleMedium: TextStyle(color: Colors.black),
            titleSmall: TextStyle(color: Colors.black),
          ),

          // AppBar-Stil
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            // Titel, Icons
            elevation: 0,
            centerTitle: false,
            // Titel linksbündig
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(color: Colors.black),
          ),

          // Icons allgemein
          iconTheme: const IconThemeData(color: Colors.black),

          // Buttons (z. B. ElevatedButton)
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
