import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class ResponseRepository {
  final FirebaseFirestore _db;
  ResponseRepository(this._db);

  int _tsMillis(Map<String, dynamic> d) {
    final v = d['enteredAt'];
    if (v is Timestamp) return v.millisecondsSinceEpoch;
    return 0;
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchMyResponses(String uid) {
    // NOTE:
    // Combining `where + orderBy` requires a composite index.
    // To keep setup simple for this MVP, we query with `where` only
    // and sort client-side.
    return _db.collection('responses').where('enteredByUid', isEqualTo: uid).snapshots().map((qs) {
      final docs = qs.docs.toList();
      docs.sort((a, b) => _tsMillis(b.data()).compareTo(_tsMillis(a.data())));
      return docs.take(50).toList();
    });
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchSurveyResponses(String surveyId) {
    // Same rationale as above: avoid composite indexes by sorting locally.
    return _db.collection('responses').where('surveyId', isEqualTo: surveyId).snapshots().map((qs) {
      final docs = qs.docs.toList();
      docs.sort((a, b) => _tsMillis(b.data()).compareTo(_tsMillis(a.data())));
      return docs;
    });
  }

  Future<void> submitResponse({
    required String responseId,
    required String surveyId,
    required int surveyVersion,
    required String enteredByUid,
    required String enteredByName,
    required Map<String, dynamic> answers,
    required GeoPointLite location,
  }) async {
    await _db.collection('responses').doc(responseId).set({
      'surveyId': surveyId,
      'surveyVersion': surveyVersion,
      'enteredByUid': enteredByUid,
      'enteredByName': enteredByName,
      'enteredAt': FieldValue.serverTimestamp(),
      'answers': answers,
      'location': location.toMap(),
      'status': 'submitted',
    });
  }
}
