import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class ResponseRepository {
  final FirebaseFirestore _db;
  ResponseRepository(this._db);

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchMyResponses(String uid) {
    return _db
        .collection('responses')
        .where('enteredByUid', isEqualTo: uid)
        .orderBy('enteredAt', descending: true)
        .limit(50)
        .snapshots()
        .map((qs) => qs.docs);
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchSurveyResponses(String surveyId) {
    return _db
        .collection('responses')
        .where('surveyId', isEqualTo: surveyId)
        .orderBy('enteredAt', descending: true)
        .limit(200)
        .snapshots()
        .map((qs) => qs.docs);
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
