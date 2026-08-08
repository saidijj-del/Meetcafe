import "package:flutter/material.dart";

import "../../l10n/translations.dart";

/// Dropdown language switcher (works on mobile; RTL is handled by MaterialApp).
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFDE68A)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: lang.lang,
          isDense: true,
          icon: const Icon(Icons.public, size: 16, color: Color(0xFFFB45309)),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF44403C),
          ),
          items: languageNames.entries
              .map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  ))
              .toList(),
          onChanged: (code) {
            if (code != null) lang.setLang(code);
          },
        ),
      ),
    );
  }
}

