import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../l10n/translations.dart";
import "../../shared/widgets/ambient_background.dart";
import "../../shared/widgets/language_switcher.dart";
import "../../shared/widgets/result_card.dart";
import "../../shared/widgets/waiting_screen.dart";
import "join_view_model.dart";

class JoinScreen extends StatelessWidget {
  final String meetingId;
  const JoinScreen({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JoinViewModel(meetingId: meetingId)..load(),
      child: const _JoinView(),
    );
  }
}

class _JoinView extends StatelessWidget {
  const _JoinView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JoinViewModel>();
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

  Widget _stageChild(
    BuildContext context,
    JoinViewModel vm,
    LanguageProvider lang,
    String Function(String) t,
  ) {
    switch (vm.stage) {
      case JoinStage.idle:
        return _Idle(key: const ValueKey("idle"), onJoin: vm.join, t: t);
      case JoinStage.locating:
        return _Locating(key: const ValueKey("locating"), t: t);
      case JoinStage.finding:
        return WaitingScreen(
          key: const ValueKey("finding"),
          title: t("findingCafe"),
          desc: t("findingDesc"),
        );
      case JoinStage.found:
        return _Result(key: const ValueKey("found"), vm: vm, lang: lang, t: t);
      case JoinStage.noCafe:
        return _NoCafe(key: const ValueKey("no_cafe"), vm: vm, t: t);
      case JoinStage.error:
        return _Error(key: const ValueKey("error"), onJoin: vm.join, t: t);
    }
  }
}
class _Idle extends StatelessWidget {
  final Future<void> Function() onJoin;
  final String Function(String) t;
  const _Idle({super.key, required this.onJoin, required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.coffee, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              t("joinTitle"),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1917),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t("joinDesc"),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF78716C)),
            ),
            const SizedBox(height: 32),
            _GradientButton(
              label: t("joinButton"),
              icon: Icons.arrow_forward,
              onTap: onJoin,
            ),
          ],
        ),
      ),
    );
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
                  color: Color(0xFF44403C),
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
  final Future<void> Function() onJoin;
  final String Function(String) t;
  const _Idle({super.key, required this.onJoin, required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.coffee, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              t("joinTitle"),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1917),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t("joinDesc"),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF78716C)),
            ),
            const SizedBox(height: 32),
            _GradientButton(
              label: t("joinButton"),
              icon: Icons.arrow_forward,
              onTap: onJoin,
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

class _Result extends StatelessWidget {
  final JoinViewModel vm;
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
              isInitiator: false,
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
  final JoinViewModel vm;
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
  final Future<void> Function() onJoin;
  final String Function(String) t;
  const _Error({super.key, required this.onJoin, required this.t});

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
              onTap: onJoin,
            ),
          ],
        ),
      ),
    );
  }
}
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
            colors: [Color(0xFFFD97706), Color(0xFFFC2410C)],
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
