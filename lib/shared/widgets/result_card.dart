import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "../../data/models/meeting.dart";
import "../../l10n/translations.dart";

class ResultCard extends StatelessWidget {
  final Meeting meeting;
  final bool isInitiator;
  final LanguageProvider lang;

  const ResultCard({
    super.key,
    required this.meeting,
    required this.isInitiator,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final t = lang.t;
    final myTime = isInitiator
        ? meeting.initiatorTravelTime
        : meeting.friendTravelTime;
    final friendTime = isInitiator
        ? meeting.friendTravelTime
        : meeting.initiatorTravelTime;
    final myLat = isInitiator ? meeting.initiatorLat : (meeting.friendLat ?? 0);
    final myLng = isInitiator ? meeting.initiatorLng : (meeting.friendLng ?? 0);
    
    final mapUrl = "https://www.google.com/maps/dir/?api=1&origin=$myLat,$myLng&destination=${meeting.cafeLat},${meeting.cafeLng}&travelmode=driving";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF059669), size: 20),
            const SizedBox(width: 8),
            Text(
              t("resultTitle"),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF047857),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1C1917).withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: const Color(0xFFF5F5F4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Container(
                  height: 144,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF59E0B),
                        Color(0xFFFEA580C),
                        Color(0xFF92400E),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                t("openNow"),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -32),
                      child: Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFF59E0B), Color(0xFFFC2410C)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF92400E).withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.coffee, color: Colors.white, size: 32),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meeting.cafeName ?? "",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1917),
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (meeting.cafeRating != null)
                            Row(
                              children: [
                                ...List.generate(5, (i) {
                                  return Icon(
                                    i < (meeting.cafeRating!.round())
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: i < (meeting.cafeRating!.round())
                                        ? const Color(0xFFFBBF24)
                                        : const Color(0xFFD6D3D1),
                                  );
                                }),
                                const SizedBox(width: 8),
                                Text(
                                  meeting.cafeRating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF78716C),
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              t("notRated"),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFA8A29E),
                              ),
                            ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.access_time,
                                  label: t("yourTravel"),
                                  value: "$myTime ${t("min")}",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.group,
                                  label: t("friendTravel"),
                                  value: "$friendTime ${t("min")}",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _GradientButton(
                            label: t("navigate"),
                            icon: Icons.navigation,
                            onTap: () => _openNav(mapUrl),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            t("poweredBy"),
            style: const TextStyle(fontSize: 11, color: Color(0xFFA8A29E)),
          ),
        ),
      ],
    );
  }

  Future<void> _openNav(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFFA8A29E)),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFA8A29E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1917),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD97706), Color(0xFFFC2410C)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF92400E).withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
