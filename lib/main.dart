import 'package:cedmate/models/app_user.dart';
import 'package:cedmate/repositories/anamnese_repository.dart';
import 'package:cedmate/services/anamnese_service.dart';
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
        StreamProvider<AppUser?>(
          create: (context) => context.read<AuthService>().userStream(),
          initialData: null,
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
        theme: ThemeData(appBarTheme: const AppBarTheme(centerTitle: true)),
      ),
    );
  }
}
