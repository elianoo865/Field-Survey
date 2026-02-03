import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';

class SurveyRepository {
  final FirebaseFirestore _db;
  final _uuid = const Uuid();

  SurveyRepository(this._db);

  Stream<List<Survey>> watchAllSurveys() {
    return _db.collection('surveys').orderBy('updatedAt', descending: true).snapshots().map((qs) {
      return qs.docs.map(Survey.fromDoc).toList();
    });
  }

  Stream<List<Survey>> watchPublishedSurveys() {
    return _db
        .collection('surveys')
        .where('status', isEqualTo: 'published')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((qs) => qs.docs.map(Survey.fromDoc).toList());
  }

  Future<String> createSurvey({required String title, required String description, required String createdBy}) async {
    final id = _uuid.v4();
    await _db.collection('surveys').doc(id).set({
      'title': title,
      'description': description,
      'status': 'draft',
      'version': 1,
      'requireGps': true,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return id;
  }

  Future<void> updateSurveyMeta({
    required String surveyId,
    required String title,
    required String description,
  }) async {
    await _db.collection('surveys').doc(surveyId).set({
      'title': title,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setStatus({required String surveyId, required SurveyStatus status}) async {
    await _db.collection('surveys').doc(surveyId).set({
      'status': surveyStatusToString(status),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<SurveyQuestion>> watchQuestions(String surveyId) {
    return _db
        .collection('surveys')
        .doc(surveyId)
        .collection('questions')
        .orderBy('order')
        .snapshots()
        .map((qs) => qs.docs.map(SurveyQuestion.fromDoc).toList());
  }

  Future<void> upsertQuestion({
    required String surveyId,
    String? questionId,
    required String label,
    required QuestionType type,
    required bool required,
    required int order,
    required List<String> options,
    required bool isDeleted,
  }) async {
    final id = questionId ?? _uuid.v4();
    await _db.collection('surveys').doc(surveyId).collection('questions').doc(id).set({
      'label': label,
      'type': questionTypeToString(type),
      'required': required,
      'order': order,
      'options': options,
      'isDeleted': isDeleted,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> softDeleteQuestion({required String surveyId, required String questionId}) async {
    await _db.collection('surveys').doc(surveyId).collection('questions').doc(questionId).set({
      'isDeleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> reorderQuestion({
    required String surveyId,
    required String questionId,
    required int newOrder,
  }) async {
    await _db.collection('surveys').doc(surveyId).collection('questions').doc(questionId).set({
      'order': newOrder,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
