import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TransactionsRecord extends FirestoreRecord {
  TransactionsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "amount" field.
  double? _amount;
  double get amount => _amount ?? 0.0;
  bool hasAmount() => _amount != null;

  // "payment_method" field.
  String? _paymentMethod;
  String get paymentMethod => _paymentMethod ?? '';
  bool hasPaymentMethod() => _paymentMethod != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "details" field.
  String? _details;
  String get details => _details ?? '';
  bool hasDetails() => _details != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "confirmed_at" field.
  DateTime? _confirmedAt;
  DateTime? get confirmedAt => _confirmedAt;
  bool hasConfirmedAt() => _confirmedAt != null;

  void _initializeFields() {
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _type = snapshotData['type'] as String?;
    _amount = castToType<double>(snapshotData['amount']);
    _paymentMethod = snapshotData['payment_method'] as String?;
    _status = snapshotData['status'] as String?;
    _details = snapshotData['details'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _confirmedAt = snapshotData['confirmed_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('transactions');

  static Stream<TransactionsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TransactionsRecord.fromSnapshot(s));

  static Future<TransactionsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TransactionsRecord.fromSnapshot(s));

  static TransactionsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TransactionsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TransactionsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TransactionsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TransactionsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TransactionsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTransactionsRecordData({
  DocumentReference? userRef,
  String? type,
  double? amount,
  String? paymentMethod,
  String? status,
  String? details,
  DateTime? createdAt,
  DateTime? confirmedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_ref': userRef,
      'type': type,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
      'details': details,
      'created_at': createdAt,
      'confirmed_at': confirmedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class TransactionsRecordDocumentEquality
    implements Equality<TransactionsRecord> {
  const TransactionsRecordDocumentEquality();

  @override
  bool equals(TransactionsRecord? e1, TransactionsRecord? e2) {
    return e1?.userRef == e2?.userRef &&
        e1?.type == e2?.type &&
        e1?.amount == e2?.amount &&
        e1?.paymentMethod == e2?.paymentMethod &&
        e1?.status == e2?.status &&
        e1?.details == e2?.details &&
        e1?.createdAt == e2?.createdAt &&
        e1?.confirmedAt == e2?.confirmedAt;
  }

  @override
  int hash(TransactionsRecord? e) => const ListEquality().hash([
        e?.userRef,
        e?.type,
        e?.amount,
        e?.paymentMethod,
        e?.status,
        e?.details,
        e?.createdAt,
        e?.confirmedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is TransactionsRecord;
}
