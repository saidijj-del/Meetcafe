import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../shared/widget/background.dart';
import '../shared/widget/well_card.dart';
import '../shared/widget/waiting_screen.dart';
import 'join_view_model.dart';

class JoinView extends StatefulWidget {
  final String meetingId;
  const JoinView({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JoinViewModel(meetingId: meetingId),
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
          const Background(),
          SafeArea(
            child: Column(
              children: [
                _Header(),
                Expanded(
                  child: _PageView(
                    duration: const Duration(milliseconds: 400),
                    child: _getPageChildren(vm, lang, t),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPageChildren(
      JoinViewModel vm, LanguageProvider lang, String Function(String) t) {
    switch (vm.stage) {
      case JoinStage.idle:
        return _JoinKey(text: t("join"), onJoin: vm.onJoin);
      case JoinStage.loading:
        return _LoadingView(text: t("meeting"));
      case JoinStage.finding:
        return WaitingScreen(
          title: t("findingInfo"),
          desc: t("findingDesc"),
        );
      case JoinStage.found:
        return _ResultView(text: t("found"), onJoin: vm.onJoin);
      case JoinStage.noCafe:
        return _NoCafe(text: t("no_cafe"), onRefresh: vm.onRefresh);
      case JoinStage.error:
        return _ErrorView(text: t("error"), onRefresh: vm.onRefresh);
    }
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF867650), Color(0xFFD6C091)],
              ),
            ),
            child: const Icon(Icons.coffee, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          const Text(
            "MeetCafe",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF262626),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinKey extends StatelessWidget {
  final String text;
  final Function(String) onJoin;

  const _JoinKey({super.key, required this.text, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                final scale = 0.5 + (0.5 * value);
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(56),
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF867650), Color(0xFFD6C091)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD6C091).withOpacity(0.3),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.coffee, size: 56, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "MeetCafe",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF262626),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF878787), height: 1.5),
            ),
            const SizedBox(height: 32),
            _JoinButton(
              label: "Join Button",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final String text;
  final Function(String) onJoin;

  const _ResultView({super.key, required this.text, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check, size: 64),
            const SizedBox(height: 24),
            _GradientButton(
              label: "JoinButton",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _NoCafe extends StatelessWidget {
  final String text;
  final Function() onRefresh;

  const _NoCafe({super.key, required this.text, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF9F6F0),
              ),
              child: const Icon(Icons.coffee, size: 40, color: Color(0xFF878787)),
            ),
            const SizedBox(height: 24),
            Text(
              "NoCafe",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF878787),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF878787)),
            ),
            const SizedBox(height: 32),
            _GradientButton(
              label: "Refresh",
              onTap: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String text;
  final Function() onRefresh;

  const _ErrorView({super.key, required this.text, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF9F6F0),
              ),
              child: const Icon(Icons.error, size: 40, color: Color(0xFF878787)),
            ),
            const SizedBox(height: 24),
            Text(
              "Error",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF878787),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF878787)),
            ),
            const SizedBox(height: 32),
            _GradientButton(
              label: "Okay",
              onTap: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF867650), Color(0xFFD6C091)],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _JoinButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF878787),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.login, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
    return AmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    const AppHeader(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: _buildStage(t),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStage(String Function(String) t) {
    switch (_stage) {
      case JoinStage.idle:
        return _InviteView(key: const ValueKey('idle'), t: t, onJoin: _join);
      case JoinStage.locating:
        return _LoadingView(key: const ValueKey('locating'), label: t('gettingLocation'));
      case JoinStage.finding:
        return WaitingScreen(key: const ValueKey('finding'), title: t('findingCafe'), desc: t('findingDesc'));
      case JoinStage.found:
        return _ResultView(
          key: const ValueKey('found'),
          child: ResultCard(
            meeting: _meeting!,
            isInitiator: false, // تم إضافة المعامل الإجباري هنا
          ),
          onStartOver: _reset,
          startOverLabel: t('startOver'),
        );
      case JoinStage.noCafe:
        return _NoCafeView(key: const ValueKey('noCafe'), t: t, onReset: _reset);
      case JoinStage.error:
        return _ErrorView(key: const ValueKey('error'), t: t, onRetry: _join);
    }
  }
}

// --- subviews --------------------------------------------------------------

class _InviteView extends StatelessWidget {
  final String Function(String) t;
  final VoidCallback onJoin;

  const _InviteView({super.key, required this.t, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 1.08),
            duration: const Duration(seconds: 2, milliseconds: 400),
            builder: (_, v, child) => Transform.scale(
              scale: (v < 1.04 ? v : 1.16 - (v - 1.04) * 2),
              child: child,
            ),
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFC2410C)],
                ),
              ),
              child: const Icon(Icons.location_on, color: Colors.white, size: 56),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            t('inviteTitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1917),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t('inviteDesc'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF78716C), height: 1.5),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onJoin,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.coffee),
              label: Text(t('joinButton')),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final String label;

  const _LoadingView({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFFD97706)),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(color: Color(0xFF57534E))),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final Widget child;
  final VoidCallback onStartOver;
  final String startOverLabel;

  const _ResultView({
    super.key,
    required this.child,
    required this.onStartOver,
    required this.startOverLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onStartOver,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.restart_alt),
              label: Text(startOverLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoCafeView extends StatelessWidget {
  final String Function(String) t;
  final VoidCallback onReset;

  const _NoCafeView({super.key, required this.t, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
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
            child: const Icon(Icons.coffee, size: 36, color: Color(0xFFA8A29E)),
          ),
          const SizedBox(height: 20),
          Text(
            t('noCafeTitle'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF292524),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t('noCafeDesc'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF78716C)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.restart_alt),
              label: Text(t('startOver')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String Function(String) t;
  final VoidCallback onRetry;

  const _ErrorView({super.key, required this.t, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
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
            child: const Icon(Icons.location_on, size: 36, color: Color(0xFFEF4444)),
          ),
          const SizedBox(height: 20),
          Text(
            t('locationDenied'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF292524),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t('locationDeniedDesc'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF78716C)),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(t('retry')),
          ),
        ],
      ),
    );
  }
}

