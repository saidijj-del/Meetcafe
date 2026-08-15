import "package:flutter/material.dart";
import "package:meetcafe/l10n/translations.dart";

/// A reusable loading state with the MeetCafe coffee theme.
/// Shows a pulsing halo, a floating/rotating coffee cup, an optional title and
/// description (defaulting to localized strings), and a row of staggered dots.
class WaitingScreen extends StatefulWidget {
  final LanguageProvider? lang;
  final String? title;
  final String? desc;

  const WaitingScreen({
    super.key,
    this.lang,
    this.title,
    this.desc,
  });

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _halo;
  late final AnimationController _cup;
  late final AnimationController _dots;

  @override
  void initState() {
    super.initState();
    _halo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _cup = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _dots = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _halo.dispose();
    _cup.dispose();
    _dots.dispose();
    super.dispose();
  }

  String get _title {
    if (widget.title != null) return widget.title!;
    if (widget.lang != null) return widget.lang!.t("waitingTitle");
    return "Waiting for your friend..";
  }

  String get _desc {
    if (widget.desc != null) return widget.desc!;
    if (widget.lang != null) return widget.lang!.t("waitingDesc");
    return "Share The link and we'll find your café once they join.";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsing halo + floating cup
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _halo,
                    builder: (_, __) {
                      final v = _halo.value;
                      final scale = 1.0 + 0.6 * v;
                      final opacity = (0.5 - 0.5 * v).abs() * 0.5 + 0.2;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFCD34).withOpacity(opacity),
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _cup,
                    builder: (_, __) {
                      final v = _cup.value;
                      final dy = -8.0 * (0.5 - (v - 0.5).abs()) * 2;
                      final angle = -0.1 * (0.5 - (v - 0.5).abs()) * 2;
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: Transform.rotate(
                          angle: angle,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFF59E0B),
                                  Color(0xFFFC2410C),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF92400E)
                                      .withOpacity(0.3),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.coffee,
                                color: Colors.white, size: 44),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444403C),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 260,
              child: Text(
                _desc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF78716C),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Staggered dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _Dot(controller: _dots, delay: i * 0.2),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final AnimationController controller;
  final double delay;

  const _Dot({required this.controller, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final v = (controller.value - delay).clamp(0.0, 1.0);
        final val = (v * 3.14159 * 2).sin().abs();
        return Container(
          width: 8 + 4 * val,
          height: 8 + 4 * val,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFF92400E).withOpacity(0.4 + 0.6 * val),
          ),
        );
      },
    );
  }
}
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1917),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF78716C),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _Dot(delay: i * 300),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_c),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFD97706),
        ),
      ),
    );
  }
}
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1917),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF78716C),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _Dot(delay: i * 300),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_c),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFD97706),
        ),
      ),
    );
  }
}

