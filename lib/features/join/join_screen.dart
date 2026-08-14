import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meetcafe/data/models/meeting.dart';
import 'package:meetcafe/data/repos/meeting_repository.dart';
import 'package:meetcafe/data/services/cafe_discovery_service.dart';
import 'package:meetcafe/data/services/geolocation_service.dart';
import 'package:meetcafe/i18n/language_controller.dart';
import 'package:meetcafe/shared/widgets/ambient_background.dart';
import 'package:meetcafe/shared/widgets/app_header.dart';
import 'package:meetcafe/shared/widgets/result_card.dart';
import 'package:meetcafe/shared/widgets/waiting_screen.dart';


enum JoinStage { idle, locating, finding, found, noCafe, error }

class JoinScreen extends StatefulWidget {
  final String meetingId;
  const JoinScreen({super.key, required this.meetingId});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final _repo = MeetingRepository();
  final _geo = GeolocationService();
  final _cafe = CafeDiscoveryService();

  JoinStage _stage = JoinStage.idle;
  Meeting? _meeting;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await _repo.get(widget.meetingId);
    if (m == null) return;
    setState(() {
      _meeting = m;
      if (m.status == MeetingStatus.found) {
        _stage = JoinStage.found;
      } else if (m.status == MeetingStatus.noCafe) {
        _stage = JoinStage.noCafe;
      }
    });
  }

  Future<void> _join() async {
    setState(() => _stage = JoinStage.locating);
    try {
      final pos = await _geo.getCurrent();
      setState(() => _stage = JoinStage.finding);
      await _repo.update(widget.meetingId, {
        'friend_lat': pos.lat,
        'friend_lng': pos.lng,
      });

      final res = await _cafe.discover(
        initiatorLat: _meeting!.initiatorLat,
        initiatorLng: _meeting!.initiatorLng,
        friendLat: pos.lat,
        friendLng: pos.lng,
      );

      if (!res.found) {
        await _repo.update(widget.meetingId, {
          'status': 'no_cafe',
          'mid_lat': res.midLat,
          'mid_lng': res.midLng,
        });
        setState(() => _stage = JoinStage.noCafe);
        return;
      }

      final finalMeeting = await _repo.update(widget.meetingId, {
        'status': 'found',
        'mid_lat': res.midLat,
        'mid_lng': res.midLng,
        'cafe_name': res.cafeName,
        'cafe_lat': res.cafeLat,
        'cafe_lng': res.cafeLng,
        'cafe_rating': res.cafeRating,
        'initiator_travel_time': res.initiatorTravelTime,
        'friend_travel_time': res.friendTravelTime,
      });

      setState(() {
        _meeting = finalMeeting;
        _stage = JoinStage.found;
      });
    } catch (_) {
      setState(() => _stage = JoinStage.error);
    }
  }

  void _reset() => setState(() => _stage = JoinStage.idle);

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

