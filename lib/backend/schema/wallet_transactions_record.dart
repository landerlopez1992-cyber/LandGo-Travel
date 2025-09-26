import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class WalletTransactionsRecord extends FirestoreRecord {
  WalletTransactionsRecord._(
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

  // "balance_before" field.
  double? _balanceBefore;
  double get balanceBefore => _balanceBefore ?? 0.0;
  bool hasBalanceBefore() => _balanceBefore != null;

  // "balance_after" field.
  double? _balanceAfter;
  double get balanceAfter => _balanceAfter ?? 0.0;
  bool hasBalanceAfter() => _balanceAfter != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "related_user_ref" field.
  DocumentReference? _relatedUserRef;
  DocumentReference? get relatedUserRef => _relatedUserRef;
  bool hasRelatedUserRef() => _relatedUserRef != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _type = snapshotData['type'] as String?;
    _amount = castToType<double>(snapshotData['amount']);
    _balanceBefore = castToType<double>(snapshotData['balance_before']);
    _balanceAfter = castToType<double>(snapshotData['balance_after']);
    _description = snapshotData['description'] as String?;
    _status = snapshotData['status'] as String?;
    _relatedUserRef = snapshotData['related_user_ref'] as DocumentReference?;
    _createdAt = snapshotData['created_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('wallet_transactions');

  static Stream<WalletTransactionsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => WalletTransactionsRecord.fromSnapshot(s));

  static Future<WalletTransactionsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => WalletTransactionsRecord.fromSnapshot(s));

  static WalletTransactionsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      WalletTransactionsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static WalletTransactionsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      WalletTransactionsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'WalletTransactionsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is WalletTransactionsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createWalletTransactionsRecordData({
  DocumentReference? userRef,
  String? type,
  double? amount,
  double? balanceBefore,
  double? balanceAfter,
  String? description,
  String? status,
  DocumentReference? relatedUserRef,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_ref': userRef,
      'type': type,
      'amount': amount,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'description': description,
      'status': status,
      'related_user_ref': relatedUserRef,
      'created_at': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class WalletTransactionsRecordDocumentEquality
    implements Equality<WalletTransactionsRecord> {
  const WalletTransactionsRecordDocumentEquality();

  @override
  bool equals(WalletTransactionsRecord? e1, WalletTransactionsRecord? e2) {
    return e1?.userRef == e2?.userRef &&
        e1?.type == e2?.type &&
        e1?.amount == e2?.amount &&
        e1?.balanceBefore == e2?.balanceBefore &&
        e1?.balanceAfter == e2?.balanceAfter &&
        e1?.description == e2?.description &&
        e1?.status == e2?.status &&
        e1?.relatedUserRef == e2?.relatedUserRef &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(WalletTransactionsRecord? e) => const ListEquality().hash([
        e?.userRef,
        e?.type,
        e?.amount,
        e?.balanceBefore,
        e?.balanceAfter,
        e?.description,
        e?.status,
        e?.relatedUserRef,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is WalletTransactionsRecord;
}
