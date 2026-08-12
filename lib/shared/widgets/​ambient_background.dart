import "package:flutter/material.dart";

/// Vertical gradient background + two soft blurred ambient circles,
/// matching the web app's amber/stone/orange ambient look.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFBEB), Color(0xFFFFF5F4), Colors.white],
            ),
          ),
        ),
        Positioned(
          top: -90,
          right: -90,
          child: _Blob(color: const Color(0x66FCD34D)),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 3,
          left: -90,
          child: _Blob(color: const Color(0x4DFED7AA)),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  const _Blob({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      height: 288,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 120, spreadRadius: 20)],
      ),
    );
  }
}

