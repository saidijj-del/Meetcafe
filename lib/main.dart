import "package:flutter/material.dart";
import "package:firebase_core/firebase_core.dart";
import "package:provider/provider.dart";

import "firebase_options.dart";
import "app.dart";
import "l10n/translations.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final langProvider = LanguageProvider();
  await langProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: langProvider),
      ],
      child: const MeetCafeApp(),
    ),
  );
}
