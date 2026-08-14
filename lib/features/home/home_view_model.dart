import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

import "package:meetcafe/core/geo.dart";
import "package:meetcafe/data/models/meeting.dart";
import "package:meetcafe/data/repos/meeting_repository.dart";

enum HomeStage { idle, locating, waiting, found, noCafe, error }

/// Replace with your real app domain / Dynamic Link host.
const String kAppShareHost = "https://meetcafe.app";

class HomeViewModel extends ChangeNotifier {
  final MeetingRepository _repo = MeetingRepository();

  HomeStage _stage = HomeStage.idle;
  Meeting? _meeting;
  bool _copied = false;

  HomeStage get stage => _stage;
  Meeting? get meeting => _meeting;
  bool get copied => _copied;
  String get shareLink =>
      _meeting == null ? "" : "$kAppShareHost/join/${_meeting!.id}";

  StreamSubscription<Meeting>? _sub;
  Timer? _poll;

  /// Create a meeting from the initiator's GPS.
  Future<void> create() async {
    _stage = HomeStage.locating;
    notifyListeners();

    try {
      final pos = await getPosition();
      final created = await _repo.create(pos.latitude, pos.longitude);
      _meeting = created;
      _stage = HomeStage.waiting;
      notifyListeners();
      _startWatching(created.id);
    } catch (_) {
      _stage = HomeStage.error;
      notifyListeners();
    }
  }

  void _startWatching(String id) {
    _sub = _repo.watch(id).listen((m) {
      _meeting = m;
      _applyStatus(m);
      notifyListeners();
    });
    _poll = Timer.periodic(const Duration(seconds: 4), (_) async {
      try {
        final m = await _repo.get(id);
        _meeting = m;
        _applyStatus(m);
        notifyListeners();
      } catch (_) {}
    });
  }

  void _applyStatus(Meeting m) {
    if (m.status == MeetingStatus.found) {
      _stage = HomeStage.found;
    } else if (m.status == MeetingStatus.noCafe) {
      _stage = HomeStage.noCafe;
    }
  }

  Future<void> copyLink() async {
    if (_meeting == null) return;
    await Clipboard.setData(ClipboardData(text: shareLink));
    _copied = true;
    notifyListeners();
    Timer(const Duration(seconds: 2), () {
      _copied = false;
      notifyListeners();
    });
  }

  void reset() {
    _sub?.cancel();
    _poll?.cancel();
    _sub = null;
    _poll = null;
    _meeting = null;
    _stage = HomeStage.idle;
    notifyListeners();
  }
}

