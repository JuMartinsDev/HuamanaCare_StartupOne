import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

import 'theme/app_theme.dart';
import 'models/app_state.dart';
import 'router/app_router.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting(
    'pt_BR',
    null,
  );

  final appState = AppState();
  await appState.inicializar();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const HumanaCareApp(),
    ),
  );
}

class HumanaCareApp extends StatelessWidget {
  const HumanaCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HumanaCare',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,

      // =========================
      // LOCALIZAÇÃO
      // =========================
      locale: const Locale('pt', 'BR'),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],

      routerConfig: AppRouter.router(),
    );
  }
}