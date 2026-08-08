import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";

import "../models/meeting.dart";

class MeetingRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection("meetings");

  /// Create a waiting meeting from the initiator's location.
  Future<Meeting> create(double lat, double lng) async {
    final ref = await _col.add({
      "initiator_lat": lat,
      "initiator_lng": lng,
      "status": "waiting",
      "createdAt": FieldValue.serverTimestamp(),
    });
    final snap = await ref.get();
    return Meeting.fromMap(ref.id, snap.data()!);
  }

  Future<Meeting> get(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists) throw Exception("meeting_not_found");
    return Meeting.fromMap(id, snap.data()!);
  }

  /// Merge-patch a meeting (used by the friend to add location + result).
  Future<Meeting> update(String id, Map<String, dynamic> patch) async {
    await _col.doc(id).set(
      {
        ...patch,
        "updatedAt": FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    return get(id);
  }

  /// Realtime stream of a meeting document (for the initiator's wait loop).
  Stream<Meeting> watch(String id) =>
      _col.doc(id).snapshots().map((s) => Meeting.fromMap(id, s.data()!));
}
