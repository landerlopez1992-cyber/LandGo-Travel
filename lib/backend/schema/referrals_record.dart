import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReferralsRecord extends FirestoreRecord {
  ReferralsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "referrer_ref" field.
  DocumentReference? _referrerRef;
  DocumentReference? get referrerRef => _referrerRef;
  bool hasReferrerRef() => _referrerRef != null;

  // "referred_user_ref" field.
  DocumentReference? _referredUserRef;
  DocumentReference? get referredUserRef => _referredUserRef;
  bool hasReferredUserRef() => _referredUserRef != null;

  // "level" field.
  int? _level;
  int get level => _level ?? 0;
  bool hasLevel() => _level != null;

  // "membership_plan" field.
  String? _membershipPlan;
  String get membershipPlan => _membershipPlan ?? '';
  bool hasMembershipPlan() => _membershipPlan != null;

  // "status" field.
  double? _status;
  double get status => _status ?? 0.0;
  bool hasStatus() => _status != null;

  // "referral_bonus" field.
  double? _referralBonus;
  double get referralBonus => _referralBonus ?? 0.0;
  bool hasReferralBonus() => _referralBonus != null;

  // "earned_at" field.
  DateTime? _earnedAt;
  DateTime? get earnedAt => _earnedAt;
  bool hasEarnedAt() => _earnedAt != null;

  // "paid_out" field.
  bool? _paidOut;
  bool get paidOut => _paidOut ?? false;
  bool hasPaidOut() => _paidOut != null;

  void _initializeFields() {
    _referrerRef = snapshotData['referrer_ref'] as DocumentReference?;
    _referredUserRef = snapshotData['referred_user_ref'] as DocumentReference?;
    _level = castToType<int>(snapshotData['level']);
    _membershipPlan = snapshotData['membership_plan'] as String?;
    _status = castToType<double>(snapshotData['status']);
    _referralBonus = castToType<double>(snapshotData['referral_bonus']);
    _earnedAt = snapshotData['earned_at'] as DateTime?;
    _paidOut = snapshotData['paid_out'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('referrals');

  static Stream<ReferralsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ReferralsRecord.fromSnapshot(s));

  static Future<ReferralsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ReferralsRecord.fromSnapshot(s));

  static ReferralsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ReferralsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ReferralsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ReferralsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ReferralsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ReferralsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createReferralsRecordData({
  DocumentReference? referrerRef,
  DocumentReference? referredUserRef,
  int? level,
  String? membershipPlan,
  double? status,
  double? referralBonus,
  DateTime? earnedAt,
  bool? paidOut,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'referrer_ref': referrerRef,
      'referred_user_ref': referredUserRef,
      'level': level,
      'membership_plan': membershipPlan,
      'status': status,
      'referral_bonus': referralBonus,
      'earned_at': earnedAt,
      'paid_out': paidOut,
    }.withoutNulls,
  );

  return firestoreData;
}

class ReferralsRecordDocumentEquality implements Equality<ReferralsRecord> {
  const ReferralsRecordDocumentEquality();

  @override
  bool equals(ReferralsRecord? e1, ReferralsRecord? e2) {
    return e1?.referrerRef == e2?.referrerRef &&
        e1?.referredUserRef == e2?.referredUserRef &&
        e1?.level == e2?.level &&
        e1?.membershipPlan == e2?.membershipPlan &&
        e1?.status == e2?.status &&
        e1?.referralBonus == e2?.referralBonus &&
        e1?.earnedAt == e2?.earnedAt &&
        e1?.paidOut == e2?.paidOut;
  }

  @override
  int hash(ReferralsRecord? e) => const ListEquality().hash([
        e?.referrerRef,
        e?.referredUserRef,
        e?.level,
        e?.membershipPlan,
        e?.status,
        e?.referralBonus,
        e?.earnedAt,
        e?.paidOut
      ]);

  @override
  bool isValidKey(Object? o) => o is ReferralsRecord;
}
