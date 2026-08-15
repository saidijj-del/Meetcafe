import "package:flutter/material.dart";

import "package:meetcafe/l10n/translations.dart";
import "package:meetcafe/shared/widgets/ambient_background.dart";

class PageNotFound extends StatelessWidget {
  const PageNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    return Stack(
      children: [
        const AmbientBackground(),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "404",
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF92400E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t("errorTitle"),
                style: const TextStyle(color: Color(0xFF78716C)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
