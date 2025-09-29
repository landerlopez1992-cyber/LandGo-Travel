import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SupportChatsRecord extends FirestoreRecord {
  SupportChatsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "message" field.
  String? _message;
  String get message => _message ?? '';
  bool hasMessage() => _message != null;

  // "sender_type" field.
  String? _senderType;
  String get senderType => _senderType ?? '';
  bool hasSenderType() => _senderType != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "is_read" field.
  bool? _isRead;
  bool get isRead => _isRead ?? false;
  bool hasIsRead() => _isRead != null;

  // "thread_id" field.
  String? _threadId;
  String get threadId => _threadId ?? '';
  bool hasThreadId() => _threadId != null;

  // "attachment_url" field.
  String? _attachmentUrl;
  String get attachmentUrl => _attachmentUrl ?? '';
  bool hasAttachmentUrl() => _attachmentUrl != null;

  void _initializeFields() {
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _message = snapshotData['message'] as String?;
    _senderType = snapshotData['sender_type'] as String?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _isRead = snapshotData['is_read'] as bool?;
    _threadId = snapshotData['thread_id'] as String?;
    _attachmentUrl = snapshotData['attachment_url'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('support_chats');

  static Stream<SupportChatsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SupportChatsRecord.fromSnapshot(s));

  static Future<SupportChatsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SupportChatsRecord.fromSnapshot(s));

  static SupportChatsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SupportChatsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SupportChatsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SupportChatsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SupportChatsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SupportChatsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSupportChatsRecordData({
  DocumentReference? userRef,
  String? message,
  String? senderType,
  DateTime? timestamp,
  bool? isRead,
  String? threadId,
  String? attachmentUrl,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_ref': userRef,
      'message': message,
      'sender_type': senderType,
      'timestamp': timestamp,
      'is_read': isRead,
      'thread_id': threadId,
      'attachment_url': attachmentUrl,
    }.withoutNulls,
  );

  return firestoreData;
}

class SupportChatsRecordDocumentEquality
    implements Equality<SupportChatsRecord> {
  const SupportChatsRecordDocumentEquality();

  @override
  bool equals(SupportChatsRecord? e1, SupportChatsRecord? e2) {
    return e1?.userRef == e2?.userRef &&
        e1?.message == e2?.message &&
        e1?.senderType == e2?.senderType &&
        e1?.timestamp == e2?.timestamp &&
        e1?.isRead == e2?.isRead &&
        e1?.threadId == e2?.threadId &&
        e1?.attachmentUrl == e2?.attachmentUrl;
  }

  @override
  int hash(SupportChatsRecord? e) => const ListEquality().hash([
        e?.userRef,
        e?.message,
        e?.senderType,
        e?.timestamp,
        e?.isRead,
        e?.threadId,
        e?.attachmentUrl
      ]);

  @override
  bool isValidKey(Object? o) => o is SupportChatsRecord;
}
