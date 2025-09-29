import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ContactUsRecord extends FirestoreRecord {
  ContactUsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "full_name" field.
  String? _fullName;
  String get fullName => _fullName ?? '';
  bool hasFullName() => _fullName != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "subject" field.
  String? _subject;
  String get subject => _subject ?? '';
  bool hasSubject() => _subject != null;

  // "message" field.
  String? _message;
  String get message => _message ?? '';
  bool hasMessage() => _message != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "submitted_at" field.
  DateTime? _submittedAt;
  DateTime? get submittedAt => _submittedAt;
  bool hasSubmittedAt() => _submittedAt != null;

  void _initializeFields() {
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _fullName = snapshotData['full_name'] as String?;
    _email = snapshotData['email'] as String?;
    _subject = snapshotData['subject'] as String?;
    _message = snapshotData['message'] as String?;
    _status = snapshotData['status'] as String?;
    _submittedAt = snapshotData['submitted_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('contact_us');

  static Stream<ContactUsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ContactUsRecord.fromSnapshot(s));

  static Future<ContactUsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ContactUsRecord.fromSnapshot(s));

  static ContactUsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ContactUsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ContactUsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ContactUsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ContactUsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ContactUsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createContactUsRecordData({
  DocumentReference? userRef,
  String? fullName,
  String? email,
  String? subject,
  String? message,
  String? status,
  DateTime? submittedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_ref': userRef,
      'full_name': fullName,
      'email': email,
      'subject': subject,
      'message': message,
      'status': status,
      'submitted_at': submittedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class ContactUsRecordDocumentEquality implements Equality<ContactUsRecord> {
  const ContactUsRecordDocumentEquality();

  @override
  bool equals(ContactUsRecord? e1, ContactUsRecord? e2) {
    return e1?.userRef == e2?.userRef &&
        e1?.fullName == e2?.fullName &&
        e1?.email == e2?.email &&
        e1?.subject == e2?.subject &&
        e1?.message == e2?.message &&
        e1?.status == e2?.status &&
        e1?.submittedAt == e2?.submittedAt;
  }

  @override
  int hash(ContactUsRecord? e) => const ListEquality().hash([
        e?.userRef,
        e?.fullName,
        e?.email,
        e?.subject,
        e?.message,
        e?.status,
        e?.submittedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is ContactUsRecord;
}
