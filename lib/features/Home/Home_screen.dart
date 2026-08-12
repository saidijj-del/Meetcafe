import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/meeting.dart';
import '../../data/repos/meeting_repository.dart';
import '../../data/services/geolocation_service.dart';
import '../../i18n/language_controller.dart';
import '../../shared/widgets/ambient_background.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/waiting_screen.dart';

enum HomeStage { idle, locating, waiting, found, noCafe, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = MeetingRepository();
  final _geo = GeolocationService();

  HomeStage _stage = HomeStage.idle;
  Meeting? _meeting;
  bool _copied = false;
  StreamSubscription<Meeting>? _sub;
  Timer? _poll;

  String get _shareLink =>
      _meeting != null ? 'https://meetcafe.app/join/${_meeting!.id}' : '';

  @override
  void dispose() {
    _sub?.cancel();
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() => _stage = HomeStage.locating);
    try {
      final pos = await _geo.getCurrent();
      final created = await _repo.create(pos.lat, pos.lng);
      setState(() {
        _meeting = created;
        _stage = HomeStage.waiting;
      });
      _listen(created.id);
    } catch (_) {
      setState(() => _stage = HomeStage.error);
    }
  }

  void _listen(String id) {
    _sub?.cancel();
    _poll?.cancel();
    _sub = _repo.watch(id).listen((m) {
      setState(() {
        _meeting = m;
        if (m.status == MeetingStatus.found) {
          _stage = HomeStage.found;
        } else if (m.status == MeetingStatus.noCafe) {
          _stage = HomeStage.noCafe;
        }
      });
    });
    // polling fallback every 4s (in case realtime stalls)
    _poll = Timer.periodic(const Duration(seconds: 4), (_) async {
      final m = await _repo.get(id);
      if (m == null) return;
      setState(() {
        _meeting = m;
        if (m.status == MeetingStatus.found) {
          _stage = HomeStage.found;
        } else if (m.status == MeetingStatus.noCafe) {
          _stage = HomeStage.noCafe;
        }
      });
    });
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _shareLink));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () => setState(() => _copied = false));
  }

  Future<void> _share() => Share.share(_shareLink, subject: 'MeetCafe');

  Future<void> _whatsapp() async {
    final text = Uri.encodeComponent(
        '${context.read<LanguageController>().t('inviteTitle')} $_shareLink');
    await launchUrl(
      Uri.parse('https://wa.me/?text=$text'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _reset() {
    _sub?.cancel();
    _poll?.cancel();
    setState(() {
      _meeting = null;
      _stage = HomeStage.idle;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageController>().t;
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
      case HomeStage.idle:
        return _IdleView(key: const ValueKey('idle'), t: t, onCreate: _create);
      case HomeStage.locating:
        return _LoadingView(key: const ValueKey('locating'), label: t('gettingLocation'));
      case HomeStage.waiting:
        return _WaitingView(
          key: const ValueKey('waiting'),
          t: t,
          link: _shareLink,
          copied: _copied,
          onCopy: _copy,
          onShare: _share,
          onWhatsapp: _whatsapp,
        );
      case HomeStage.found:
        return _ResultView(
          key: const ValueKey('found'),
          child: ResultCard(meeting: _meeting!, isInitiator: true),
          onStartOver: _reset,
          startOverLabel: t('startOver'),
        );
      case HomeStage.noCafe:
        return _NoCafeView(key: const ValueKey('noCafe'), t: t, onReset: _reset);
      case HomeStage.error:
        return _ErrorView(key: const ValueKey('error'), t: t, onRetry: _create);
    }
  }
}

// --- subviews --------------------------------------------------------------

class _IdleView extends StatelessWidget {
  final String Function(String) t;
  final VoidCallback onCreate;

  const _IdleView({super.key, required this.t, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 3),
            builder: (_, v, child) {
              return Transform.translate(
                offset: Offset(0, -10 * (0.5 - 0.5 * (v - 0.5).abs() * 2)),
                child: child,
              );
            },
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFC2410C)],
                ),
              ),
              child: const Icon(Icons.coffee, color: Colors.white, size: 56),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            t('tagline'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1917),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t('createLinkDesc'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF78716C), height: 1.5),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.location_on),
              label: Text(t('createLink')),
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

class _WaitingView extends StatelessWidget {
  final String Function(String) t;
  final String link;
  final bool copied;
  final VoidCallback onCopy, onShare, onWhatsapp;

  const _WaitingView({
    super.key,
    required this.t,
    required this.link,
    required this.copied,
    required this.onCopy,
    required this.onShare,
    required this.onWhatsapp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(child: WaitingScreen()),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 16)],
            border: Border.all(color: const Color(0xFFF5F5F4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.link, size: 16, color: Color(0xFFB45309)),
                  const SizedBox(width: 6),
                  Text(
                    t('shareLink'),
                    style: const TextStyle(
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
                  color: const Color(0xFFFAFAF9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        link,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Color(0xFF78716C),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onCopy,
                      icon: Icon(
                        copied ? Icons.check_circle : Icons.copy,
                        size: 18,
                        color: copied ? const Color(0xFF16A34A) : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onShare,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1C1917),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.share, size: 16),
                      label: Text(t('shareLink')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onWhatsapp,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('WhatsApp'),
                    ),
                  ),
                ],
              ),
              if (copied)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    t('copied'),
                    style: const TextStyle(color: Color(0xFF16A34A), fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ],
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

