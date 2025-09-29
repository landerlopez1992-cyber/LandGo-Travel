import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MembershipsRecord extends FirestoreRecord {
  MembershipsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "price" field.
  double? _price;
  double get price => _price ?? 0.0;
  bool hasPrice() => _price != null;

  // "duration_days" field.
  int? _durationDays;
  int get durationDays => _durationDays ?? 0;
  bool hasDurationDays() => _durationDays != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "benefits" field.
  String? _benefits;
  String get benefits => _benefits ?? '';
  bool hasBenefits() => _benefits != null;

  // "can_skip_wait" field.
  bool? _canSkipWait;
  bool get canSkipWait => _canSkipWait ?? false;
  bool hasCanSkipWait() => _canSkipWait != null;

  // "referral_bonus" field.
  double? _referralBonus;
  double get referralBonus => _referralBonus ?? 0.0;
  bool hasReferralBonus() => _referralBonus != null;

  // "image_url" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "is_active" field.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updated_at" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _price = castToType<double>(snapshotData['price']);
    _durationDays = castToType<int>(snapshotData['duration_days']);
    _description = snapshotData['description'] as String?;
    _benefits = snapshotData['benefits'] as String?;
    _canSkipWait = snapshotData['can_skip_wait'] as bool?;
    _referralBonus = castToType<double>(snapshotData['referral_bonus']);
    _imageUrl = snapshotData['image_url'] as String?;
    _isActive = snapshotData['is_active'] as bool?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _updatedAt = snapshotData['updated_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('memberships');

  static Stream<MembershipsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MembershipsRecord.fromSnapshot(s));

  static Future<MembershipsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MembershipsRecord.fromSnapshot(s));

  static MembershipsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MembershipsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MembershipsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MembershipsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MembershipsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MembershipsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMembershipsRecordData({
  String? name,
  double? price,
  int? durationDays,
  String? description,
  String? benefits,
  bool? canSkipWait,
  double? referralBonus,
  String? imageUrl,
  bool? isActive,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'price': price,
      'duration_days': durationDays,
      'description': description,
      'benefits': benefits,
      'can_skip_wait': canSkipWait,
      'referral_bonus': referralBonus,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class MembershipsRecordDocumentEquality implements Equality<MembershipsRecord> {
  const MembershipsRecordDocumentEquality();

  @override
  bool equals(MembershipsRecord? e1, MembershipsRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.price == e2?.price &&
        e1?.durationDays == e2?.durationDays &&
        e1?.description == e2?.description &&
        e1?.benefits == e2?.benefits &&
        e1?.canSkipWait == e2?.canSkipWait &&
        e1?.referralBonus == e2?.referralBonus &&
        e1?.imageUrl == e2?.imageUrl &&
        e1?.isActive == e2?.isActive &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt;
  }

  @override
  int hash(MembershipsRecord? e) => const ListEquality().hash([
        e?.name,
        e?.price,
        e?.durationDays,
        e?.description,
        e?.benefits,
        e?.canSkipWait,
        e?.referralBonus,
        e?.imageUrl,
        e?.isActive,
        e?.createdAt,
        e?.updatedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is MembershipsRecord;
}
