import 'package:cloud_firestore/cloud_firestore.dart';

enum MeetingStatus { waiting, found, noCafe }

class Meeting {
  final String id;
  final double initiatorLat;
  final double initiatorLng;
  final double? friendLat;
  final double? friendLng;
  final MeetingStatus status;
  final double? midLat;
  final double? midLng;
  final String? cafeName;
  final double? cafeLat;
  final double? cafeLng;
  final double? cafeRating;
  final int? initiatorTravelTime;
  final int? friendTravelTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  Meeting({
    required this.id,
    required this.initiatorLat,
    required this.initiatorLng,
    this.friendLat,
    this.friendLng,
    required this.status,
    this.midLat,
    this.midLng,
    this.cafeName,
    this.cafeLat,
    this.cafeLng,
    this.cafeRating,
    this.initiatorTravelTime,
    this.friendTravelTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Meeting.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    MeetingStatus parseStatus(String? s) {
      switch (s) {
        case 'found':
          return MeetingStatus.found;
        case 'no_cafe':
          return MeetingStatus.noCafe;
        default:
          return MeetingStatus.waiting;
      }
    }

    return Meeting(
      id: doc.id,
      initiatorLat: (d['initiator_lat'] as num?)?.toDouble() ?? 0,
      initiatorLng: (d['initiator_lng'] as num?)?.toDouble() ?? 0,
      friendLat: (d['friend_lat'] as num?)?.toDouble(),
      friendLng: (d['friend_lng'] as num?)?.toDouble(),
      status: parseStatus(d['status'] as String?),
      midLat: (d['mid_lat'] as num?)?.toDouble(),
      midLng: (d['mid_lng'] as num?)?.toDouble(),
      cafeName: d['cafe_name'] as String?,
      cafeLat: (d['cafe_lat'] as num?)?.toDouble(),
      cafeLng: (d['cafe_lng'] as num?)?.toDouble(),
      cafeRating: (d['cafe_rating'] as num?)?.toDouble(),
      initiatorTravelTime: (d['initiator_travel_time'] as num?)?.toInt(),
      friendTravelTime: (d['friend_travel_time'] as num?)?.toInt(),
      createdAt: (d['created_date'] as Timestamp?)?.toDate() ??
          (d['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt: (d['updated_date'] as Timestamp?)?.toDate() ??
          (d['updatedAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'initiator_lat': initiatorLat,
        'initiator_lng': initiatorLng,
        if (friendLat != null) 'friend_lat': friendLat,
        if (friendLng != null) 'friend_lng': friendLng,
        'status': _statusName(status),
        if (midLat != null) 'mid_lat': midLat,
        if (midLng != null) 'mid_lng': midLng,
        if (cafeName != null) 'cafe_name': cafeName,
        if (cafeLat != null) 'cafe_lat': cafeLat,
        if (cafeLng != null) 'cafe_lng': cafeLng,
        if (cafeRating != null) 'cafe_rating': cafeRating,
        if (initiatorTravelTime != null)
          'initiator_travel_time': initiatorTravelTime,
        if (friendTravelTime != null) 'friend_travel_time': friendTravelTime,
      };

  static String _statusName(MeetingStatus s) {
    switch (s) {
      case MeetingStatus.found:
        return 'found';
      case MeetingStatus.noCafe:
        return 'no_cafe';
      case MeetingStatus.waiting:
        return 'waiting';
    }
  }
}

