import "package:flutter/material.dart";

/// Reusable waiting/finding screen: pulsing coffee halo, gentle float/tilt,
/// title + subtitle, and three staggered pulsing dots.
class WaitingScreen extends StatefulWidget {
  final String title;
  final String desc;
  const WaitingScreen({super.key, required this.title, required this.desc});

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _halo;
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _halo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _halo.dispose();
    _float.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.6).animate(
                    CurvedAnimation(parent: _halo, curve: Curves.easeInOut),
                  ),
                  child: FadeTransition(
                    opacity: Tween(begin: 0.5, end: 0.0).animate(_halo),
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x66FCD34D),
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _float,
                  builder: (context, child) {
                    final t = _float.value;
                    return Transform.translate(
                      offset: Offset(0, -8 * t),
                      child: Transform.rotate(
                        angle: -0.1 * t,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFF59E0B), Color(0xFFFC2410C)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF92400E).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.coffee,
                        size: 44, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF44403C),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF78716C),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _Dot(delay: i * 200),
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
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.repeat(reverse: true);
    });
  }
}

