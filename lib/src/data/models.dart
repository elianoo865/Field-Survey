import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, surveyor, reviewer }

UserRole roleFromString(String? v) {
  switch (v) {
    case 'admin':
      return UserRole.admin;
    case 'reviewer':
      return UserRole.reviewer;
    case 'surveyor':
    default:
      return UserRole.surveyor;
  }
}

String roleToString(UserRole r) {
  switch (r) {
    case UserRole.admin:
      return 'admin';
    case UserRole.reviewer:
      return 'reviewer';
    case UserRole.surveyor:
      return 'surveyor';
  }
}

class UserProfile {
  final String uid;
  final String name;
  final UserRole role;
  final bool isActive;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.role,
    required this.isActive,
  });

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      name: (d['name'] ?? '') as String,
      role: roleFromString(d['role'] as String?),
      isActive: (d['isActive'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'role': roleToString(role),
        'isActive': isActive,
      };
}

enum SurveyStatus { draft, published, archived }

SurveyStatus surveyStatusFromString(String? v) {
  switch (v) {
    case 'published':
      return SurveyStatus.published;
    case 'archived':
      return SurveyStatus.archived;
    case 'draft':
    default:
      return SurveyStatus.draft;
  }
}

String surveyStatusToString(SurveyStatus s) {
  switch (s) {
    case SurveyStatus.published:
      return 'published';
    case SurveyStatus.archived:
      return 'archived';
    case SurveyStatus.draft:
      return 'draft';
  }
}

class Survey {
  final String id;
  final String title;
  final String description;
  final SurveyStatus status;
  final int version;
  final bool requireGps; // kept for future configurability; app enforces GPS mandatory anyway.
  final String createdBy;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.version,
    required this.requireGps,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Survey.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Survey(
      id: doc.id,
      title: (d['title'] ?? '') as String,
      description: (d['description'] ?? '') as String,
      status: surveyStatusFromString(d['status'] as String?),
      version: (d['version'] ?? 1) as int,
      requireGps: (d['requireGps'] ?? true) as bool,
      createdBy: (d['createdBy'] ?? '') as String,
      createdAt: d['createdAt'] as Timestamp?,
      updatedAt: d['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'status': surveyStatusToString(status),
        'version': version,
        'requireGps': requireGps,
        'createdBy': createdBy,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

enum QuestionType { text, singleChoice, multiChoice, checkbox }

QuestionType questionTypeFromString(String? v) {
  switch (v) {
    case 'singleChoice':
      return QuestionType.singleChoice;
    case 'multiChoice':
      return QuestionType.multiChoice;
    case 'checkbox':
      return QuestionType.checkbox;
    case 'text':
    default:
      return QuestionType.text;
  }
}

String questionTypeToString(QuestionType t) {
  switch (t) {
    case QuestionType.singleChoice:
      return 'singleChoice';
    case QuestionType.multiChoice:
      return 'multiChoice';
    case QuestionType.checkbox:
      return 'checkbox';
    case QuestionType.text:
      return 'text';
  }
}

class SurveyQuestion {
  final String id;
  final String label;
  final QuestionType type;
  final bool required;
  final int order;
  final List<String> options;
  final bool isDeleted;

  const SurveyQuestion({
    required this.id,
    required this.label,
    required this.type,
    required this.required,
    required this.order,
    required this.options,
    required this.isDeleted,
  });

  factory SurveyQuestion.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return SurveyQuestion(
      id: doc.id,
      label: (d['label'] ?? '') as String,
      type: questionTypeFromString(d['type'] as String?),
      required: (d['required'] ?? false) as bool,
      order: (d['order'] ?? 0) as int,
      options: ((d['options'] ?? []) as List).map((e) => e.toString()).toList(),
      isDeleted: (d['isDeleted'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() => {
        'label': label,
        'type': questionTypeToString(type),
        'required': required,
        'order': order,
        'options': options,
        'isDeleted': isDeleted,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class GeoPointLite {
  final double lat;
  final double lng;
  final double? accuracy;
  final DateTime capturedAt;

  const GeoPointLite({
    required this.lat,
    required this.lng,
    this.accuracy,
    required this.capturedAt,
  });

  Map<String, dynamic> toMap() => {
        'lat': lat,
        'lng': lng,
        if (accuracy != null) 'accuracy': accuracy,
        'capturedAt': Timestamp.fromDate(capturedAt),
      };
}
