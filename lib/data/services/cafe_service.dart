import "package:cloud_functions/cloud_functions.dart";

/// Result of the discoverCafe Cloud Function.
class DiscoverResult {
  final bool found;
  final String status;
  final double? midLat;
  final double? midLng;
  final String? cafeName;
  final double? cafeLat;
  final double? cafeLng;
  final double? cafeRating;
  final int? initiatorTravelTime;
  final int? friendTravelTime;

  DiscoverResult({
    required this.found,
    required this.status,
    this.midLat,
    this.midLng,
    this.cafeName,
    this.cafeLat,
    this.cafeLng,
    this.cafeRating,
    this.initiatorTravelTime,
    this.friendTravelTime,
  });

  factory DiscoverResult.fromMap(Map<String, dynamic> m) {
    double? numOrNull(Object? v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse("$v"));
    int? intOrNull(Object? v) =>
        v == null ? null : (v is int ? v : (v is num ? v.round() : int.tryParse("$v")));

    return DiscoverResult(
      found: m["found"] == true,
      status: m["status"]?.toString() ?? "no_cafe",
      midLat: numOrNull(m["mid_lat"]),
      midLng: numOrNull(m["mid_lng"]),
      cafeName: m["cafe_name"]?.toString(),
      cafeLat: numOrNull(m["cafe_lat"]),
      cafeLng: numOrNull(m["cafe_lng"]),
      cafeRating: numOrNull(m["cafe_rating"]),
      initiatorTravelTime: intOrNull(m["initiator_travel_time"]),
      friendTravelTime: intOrNull(m["friend_travel_time"]),
    );
  }
}

class CafeService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Calls the `discoverCafe` Cloud Function.
  Future<DiscoverResult> discover({
    required double initiatorLat,
    required double initiatorLng,
    required double friendLat,
    required double friendLng,
  }) async {
    final callable = _functions.httpsCallable("discoverCafe");
    final res = await callable.call({
      "initiator_lat": initiatorLat,
      "initiator_lng": initiatorLng,
      "friend_lat": friendLat,
      "friend_lng": friendLng,
    });
    return DiscoverResult.fromMap(Map<String, dynamic>.from(res.data));
  }
}

