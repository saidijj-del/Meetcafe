import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "package:meetcafe/core/router.dart";
import "package:meetcafe/core/theme.dart";
import "package:meetcafe/l10n/translations.dart";

class MeetCafeApp extends StatelessWidget {
  const MeetCafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return MaterialApp.router(
      title: "MeetCafe",
      debugShowCheckedModeBanner: false,
      theme: MeetCafeTheme.light,
      routerConfig: MeetCafeRouter.config,
      locale: Locale(lang.lang),
      supportedLocales: const [
        Locale("en"), Locale("ar"), Locale("es"), Locale("fr"),
        Locale("zh"), Locale("hi"), Locale("pt"), Locale("ru"),
        Locale("de"), Locale("ja"),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
