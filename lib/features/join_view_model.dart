import "dart:async";

import "package:flutter/foundation.dart";

import "../../core/geo.dart";
import "../../data/models/meeting.dart";
import "../../data/repos/meeting_repository.dart";
import "../../data/services/cafe_service.dart";

enum JoinStage { idle, locating, finding, found, noCafe, error }

class JoinViewModel extends ChangeNotifier {
  final MeetingRepository _repo = MeetingRepository();
  final CafeService _cafe = CafeService();

  final String meetingId;

  JoinViewModel({required this.meetingId});

  JoinStage _stage = JoinStage.idle;
  Meeting? _meeting;
  bool _locError = false;

  JoinStage get stage => _stage;
  Meeting? get meeting => _meeting;
  bool get locError => _locError;

  /// On mount: load the meeting; if already resolved, jump to that stage.
  Future<void> load() async {
    try {
      final m = await _repo.get(meetingId);
      _meeting = m;
      if (m.status == MeetingStatus.found) {
        _stage = JoinStage.found;
      } else if (m.status == MeetingStatus.noCafe) {
        _stage = JoinStage.noCafe;
      }
      notifyListeners();
    } catch (_) {}
  }

  /// Friend joins: get GPS, write location, call discoverCafe, write result.
  Future<void> join() async {
    _locError = false;
    _stage = JoinStage.locating;
    notifyListeners();

    try {
      final pos = await getPosition();
      _stage = JoinStage.finding;
      notifyListeners();

      final updated = await _repo.update(meetingId, {
        "friend_lat": pos.latitude,
        "friend_lng": pos.longitude,
      });
      _meeting = updated;

      final result = await _cafe.discover(
        initiatorLat: updated.initiatorLat,
        initiatorLng: updated.initiatorLng,
        friendLat: pos.latitude,
        friendLng: pos.longitude,
      );

      if (!result.found) {
        await _repo.update(meetingId, {
          "status": "no_cafe",
          if (result.midLat != null) "mid_lat": result.midLat,
          if (result.midLng != null) "mid_lng": result.midLng,
        });
        _stage = JoinStage.noCafe;
        notifyListeners();
        return;
      }

      final finalMeeting = await _repo.update(meetingId, {
        "status": "found",
        if (result.midLat != null) "mid_lat": result.midLat,
        if (result.midLng != null) "mid_lng": result.midLng,
        "cafe_name": result.cafeName,
        "cafe_lat": result.cafeLat,
        "cafe_lng": result.cafeLng,
        "cafe_rating": result.cafeRating,
        "initiator_travel_time": result.initiatorTravelTime,
        "friend_travel_time": result.friendTravelTime,
      });
      _meeting = finalMeeting;
      _stage = JoinStage.found;
      notifyListeners();
    } catch (_) {
      _locError = true;
      _stage = JoinStage.error;
      notifyListeners();
    }
  }
}
