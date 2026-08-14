import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:share_plus/share_plus.dart";
import "package:url_launcher/url_launcher.dart";

import "package:meetcafe/l10n/translations.dart";
import "package:meetcafe/shared/widgets/ambient_background.dart";
import "package:meetcafe/shared/widgets/language_switcher.dart";
import "package:meetcafe/shared/widgets/result_card.dart";
import "package:meetcafe/shared/widgets/waiting_screen.dart";
import "home_view_model.dart";


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final lang = context.watch<LanguageProvider>();
    final t = lang.t;

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                _Header(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) {
                      final offset = Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(anim);
                      return FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: offset,
                          child: child,
                        ),
                      );
                    },
                    child: _stageChild(context, vm, lang, t),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

  Widget _stageChild(
    BuildContext context,
    HomeViewModel vm,
    LanguageProvider lang,
    String Function(String) t,
  ) {
    switch (vm.stage) {
      case HomeStage.idle:
        return _Idle(key: const ValueKey("idle"), onCreate: vm.create, t: t);
      case HomeStage.locating:
        return _Locating(key: const ValueKey("locating"), t: t);
      case HomeStage.waiting:
        return _Waiting(
          key: const ValueKey("waiting"),
          vm: vm,
          lang: lang,
          t: t,
        );
      case HomeStage.found:
        return _Result(
          key: const ValueKey("found"),
          vm: vm,
          lang: lang,
          t: t,
        );
      case HomeStage.noCafe:
        return _NoCafe(key: const ValueKey("no_cafe"), vm: vm, t: t);
      case HomeStage.error:
        return _Error(key: const ValueKey("error"), onCreate: vm.create, t: t);
    }
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD97706), Color(0xFFF9A3412)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF92400E).withOpacity(0.2),
                      blurRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.coffee, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                "MeetCafe",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF444403C),
                ),
              ),
            ],
          ),
          const LanguageSwitcher(),
        ],
      ),
    );
  }
}
class _Idle extends StatelessWidget {
  final Future<void> Function() onCreate;
  final String Function(String) t;
  const _Idle({super.key, required this.onCreate, required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 3),
              builder: (context, v, child) {
                return Transform.translate(
                  offset: Offset(0, -10 * (0.5 - (v - 0.5).abs())),
                  child: child,
                );
              },
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF59E0B), Color(0xFFFC2410C)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF92400E).withOpacity(0.3),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.coffee, size: 56, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              t("tagline"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF1C1917),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t("createLinkDesc"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF78716C),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: _GradientButton(
                label: t("createLink"),
                icon: Icons.location_on,
                onTap: onCreate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _Locating extends StatelessWidget {
  final String Function(String) t;
  const _Locating({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: Color(0xFFD97706),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t("gettingLocation"),
            style: const TextStyle(
              color: Color(0xFF57534E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
class _Waiting extends StatelessWidget {
  final HomeViewModel vm;
  final LanguageProvider lang;
  final String Function(String) t;
  const _Waiting({super.key, required this.vm, required this.lang, required this.t});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        WaitingScreen(title: t("waitingTitle"), desc: t("waitingDesc")),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF3F5F4)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1C1917).withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.link, size: 16, color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  Text(
                    t("shareLink"),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF44403C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        vm.shareLink,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: "monospace",
                          color: Color(0xFF78716C),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: vm.copyLink,
                      child: vm.copied
                          ? const Icon(Icons.check_circle, size: 18, color: Color(0xFF22C55E))
                          : const Icon(Icons.copy, size: 18, color: Color(0xFFD97706)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SolidButton(
                      label: t("shareLink"),
                      icon: Icons.share,
                      color: const Color(0xFF1C1917),
                      onTap: () => Share.share(
                        "${t("inviteTitle")}\n${vm.shareLink}",
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SolidButton(
                      label: "WhatsApp",
                      icon: Icons.share,
                      color: const Color(0xFF25D366),
                      onTap: () => launchUrl(
                        Uri.parse(
                          "https://wa.me/?text=${Uri.encodeComponent("${t("inviteTitle")} ${vm.shareLink}")}",
                        ),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  ),
                ],
              ),
              if (vm.copied)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: Text(
                      t("copied"),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
class _Result extends StatelessWidget {
  final HomeViewModel vm;
  final LanguageProvider lang;
  final String Function(String) t;
  const _Result({super.key, required this.vm, required this.lang, required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ResultCard(
              meeting: vm.meeting!,
              isInitiator: true,
              lang: lang,
            ),
            const SizedBox(height: 24),
            _OutlineButton(
              label: t("startOver"),
              icon: Icons.restart_alt,
              onTap: vm.reset,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoCafe extends StatelessWidget {
  final HomeViewModel vm;
  final String Function(String) t;
  const _NoCafe({super.key, required this.vm, required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF5F5F4),
              ),
              child: const Icon(
                Icons.coffee,
                size: 36,
                color: Color(0xFFA8A29E),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t("noCafeTitle"),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF44403C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t("noCafeDesc"),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF78716C)),
            ),
            const SizedBox(height: 24),
            _OutlineButton(
              label: t("startOver"),
              icon: Icons.restart_alt,
              onTap: vm.reset,
            ),
          ],
        ),
      ),
    );
  }
}
class _Error extends StatelessWidget {
  final Future<void> Function() onCreate;
  final String Function(String) t;
  const _Error({super.key, required this.onCreate, required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFEF2F2),
              ),
              child: const Icon(
                Icons.location_on,
                size: 36,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t("locationDenied"),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF44403C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t("locationDeniedDesc"),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF78716C)),
            ),
            const SizedBox(height: 24),
            _GradientButton(
              label: t("retry"),
              icon: Icons.refresh,
              onTap: onCreate,
            ),
          ],
        ),
      ),
    );
  }
}
// --- shared buttons -------------------------------------------------------------

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Future<void> Function() onTap;
  const _GradientButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD97706), Color(0xFFC2410C)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF92400E).withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _SolidButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SolidButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF44403C)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF44403C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

