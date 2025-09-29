import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FaqsRecord extends FirestoreRecord {
  FaqsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "question" field.
  String? _question;
  String get question => _question ?? '';
  bool hasQuestion() => _question != null;

  // "answer" field.
  String? _answer;
  String get answer => _answer ?? '';
  bool hasAnswer() => _answer != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "is_active" field.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _question = snapshotData['question'] as String?;
    _answer = snapshotData['answer'] as String?;
    _category = snapshotData['category'] as String?;
    _isActive = snapshotData['is_active'] as bool?;
    _createdAt = snapshotData['created_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('faqs');

  static Stream<FaqsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => FaqsRecord.fromSnapshot(s));

  static Future<FaqsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => FaqsRecord.fromSnapshot(s));

  static FaqsRecord fromSnapshot(DocumentSnapshot snapshot) => FaqsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static FaqsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      FaqsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'FaqsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is FaqsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createFaqsRecordData({
  String? question,
  String? answer,
  String? category,
  bool? isActive,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'question': question,
      'answer': answer,
      'category': category,
      'is_active': isActive,
      'created_at': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class FaqsRecordDocumentEquality implements Equality<FaqsRecord> {
  const FaqsRecordDocumentEquality();

  @override
  bool equals(FaqsRecord? e1, FaqsRecord? e2) {
    return e1?.question == e2?.question &&
        e1?.answer == e2?.answer &&
        e1?.category == e2?.category &&
        e1?.isActive == e2?.isActive &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(FaqsRecord? e) => const ListEquality()
      .hash([e?.question, e?.answer, e?.category, e?.isActive, e?.createdAt]);

  @override
  bool isValidKey(Object? o) => o is FaqsRecord;
}
