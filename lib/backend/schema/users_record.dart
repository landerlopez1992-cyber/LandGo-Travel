import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "full_name" field.
  String? _fullName;
  String get fullName => _fullName ?? '';
  bool hasFullName() => _fullName != null;

  // "date_of_birth" field.
  DateTime? _dateOfBirth;
  DateTime? get dateOfBirth => _dateOfBirth;
  bool hasDateOfBirth() => _dateOfBirth != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "is_active" field.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  // "cover_photo_url" field.
  String? _coverPhotoUrl;
  String get coverPhotoUrl => _coverPhotoUrl ?? '';
  bool hasCoverPhotoUrl() => _coverPhotoUrl != null;

  // "wallet_balance" field.
  double? _walletBalance;
  double get walletBalance => _walletBalance ?? 0.0;
  bool hasWalletBalance() => _walletBalance != null;

  // "membership_type" field.
  String? _membershipType;
  String get membershipType => _membershipType ?? '';
  bool hasMembershipType() => _membershipType != null;

  // "membership_active" field.
  bool? _membershipActive;
  bool get membershipActive => _membershipActive ?? false;
  bool hasMembershipActive() => _membershipActive != null;

  // "membership_start_date" field.
  DateTime? _membershipStartDate;
  DateTime? get membershipStartDate => _membershipStartDate;
  bool hasMembershipStartDate() => _membershipStartDate != null;

  // "membership_end_date" field.
  DateTime? _membershipEndDate;
  DateTime? get membershipEndDate => _membershipEndDate;
  bool hasMembershipEndDate() => _membershipEndDate != null;

  // "membership_canceled" field.
  bool? _membershipCanceled;
  bool get membershipCanceled => _membershipCanceled ?? false;
  bool hasMembershipCanceled() => _membershipCanceled != null;

  // "next_eligible_membership_date" field.
  DateTime? _nextEligibleMembershipDate;
  DateTime? get nextEligibleMembershipDate => _nextEligibleMembershipDate;
  bool hasNextEligibleMembershipDate() => _nextEligibleMembershipDate != null;

  // "can_access_services" field.
  bool? _canAccessServices;
  bool get canAccessServices => _canAccessServices ?? false;
  bool hasCanAccessServices() => _canAccessServices != null;

  // "referral_code" field.
  String? _referralCode;
  String get referralCode => _referralCode ?? '';
  bool hasReferralCode() => _referralCode != null;

  // "referred_by" field.
  String? _referredBy;
  String get referredBy => _referredBy ?? '';
  bool hasReferredBy() => _referredBy != null;

  // "referral_level_1_count" field.
  int? _referralLevel1Count;
  int get referralLevel1Count => _referralLevel1Count ?? 0;
  bool hasReferralLevel1Count() => _referralLevel1Count != null;

  // "referral_level_2_count" field.
  int? _referralLevel2Count;
  int get referralLevel2Count => _referralLevel2Count ?? 0;
  bool hasReferralLevel2Count() => _referralLevel2Count != null;

  // "referral_earnings_total" field.
  double? _referralEarningsTotal;
  double get referralEarningsTotal => _referralEarningsTotal ?? 0.0;
  bool hasReferralEarningsTotal() => _referralEarningsTotal != null;

  // "preferred_language" field.
  String? _preferredLanguage;
  String get preferredLanguage => _preferredLanguage ?? '';
  bool hasPreferredLanguage() => _preferredLanguage != null;

  // "saved_addresses" field.
  List<String>? _savedAddresses;
  List<String> get savedAddresses => _savedAddresses ?? const [];
  bool hasSavedAddresses() => _savedAddresses != null;

  // "saved_cards" field.
  List<String>? _savedCards;
  List<String> get savedCards => _savedCards ?? const [];
  bool hasSavedCards() => _savedCards != null;

  // "has_accepted_terms" field.
  bool? _hasAcceptedTerms;
  bool get hasAcceptedTerms => _hasAcceptedTerms ?? false;
  bool hasHasAcceptedTerms() => _hasAcceptedTerms != null;

  // "force_update_required" field.
  bool? _forceUpdateRequired;
  bool get forceUpdateRequired => _forceUpdateRequired ?? false;
  bool hasForceUpdateRequired() => _forceUpdateRequired != null;

  // "maintenance_mode_override" field.
  bool? _maintenanceModeOverride;
  bool get maintenanceModeOverride => _maintenanceModeOverride ?? false;
  bool hasMaintenanceModeOverride() => _maintenanceModeOverride != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _fullName = snapshotData['full_name'] as String?;
    _dateOfBirth = snapshotData['date_of_birth'] as DateTime?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _isActive = snapshotData['is_active'] as bool?;
    _coverPhotoUrl = snapshotData['cover_photo_url'] as String?;
    _walletBalance = castToType<double>(snapshotData['wallet_balance']);
    _membershipType = snapshotData['membership_type'] as String?;
    _membershipActive = snapshotData['membership_active'] as bool?;
    _membershipStartDate = snapshotData['membership_start_date'] as DateTime?;
    _membershipEndDate = snapshotData['membership_end_date'] as DateTime?;
    _membershipCanceled = snapshotData['membership_canceled'] as bool?;
    _nextEligibleMembershipDate =
        snapshotData['next_eligible_membership_date'] as DateTime?;
    _canAccessServices = snapshotData['can_access_services'] as bool?;
    _referralCode = snapshotData['referral_code'] as String?;
    _referredBy = snapshotData['referred_by'] as String?;
    _referralLevel1Count =
        castToType<int>(snapshotData['referral_level_1_count']);
    _referralLevel2Count =
        castToType<int>(snapshotData['referral_level_2_count']);
    _referralEarningsTotal =
        castToType<double>(snapshotData['referral_earnings_total']);
    _preferredLanguage = snapshotData['preferred_language'] as String?;
    _savedAddresses = getDataList(snapshotData['saved_addresses']);
    _savedCards = getDataList(snapshotData['saved_cards']);
    _hasAcceptedTerms = snapshotData['has_accepted_terms'] as bool?;
    _forceUpdateRequired = snapshotData['force_update_required'] as bool?;
    _maintenanceModeOverride =
        snapshotData['maintenance_mode_override'] as bool?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  String? phoneNumber,
  String? fullName,
  DateTime? dateOfBirth,
  DateTime? createdAt,
  bool? isActive,
  String? coverPhotoUrl,
  double? walletBalance,
  String? membershipType,
  bool? membershipActive,
  DateTime? membershipStartDate,
  DateTime? membershipEndDate,
  bool? membershipCanceled,
  DateTime? nextEligibleMembershipDate,
  bool? canAccessServices,
  String? referralCode,
  String? referredBy,
  int? referralLevel1Count,
  int? referralLevel2Count,
  double? referralEarningsTotal,
  String? preferredLanguage,
  bool? hasAcceptedTerms,
  bool? forceUpdateRequired,
  bool? maintenanceModeOverride,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'date_of_birth': dateOfBirth,
      'created_at': createdAt,
      'is_active': isActive,
      'cover_photo_url': coverPhotoUrl,
      'wallet_balance': walletBalance,
      'membership_type': membershipType,
      'membership_active': membershipActive,
      'membership_start_date': membershipStartDate,
      'membership_end_date': membershipEndDate,
      'membership_canceled': membershipCanceled,
      'next_eligible_membership_date': nextEligibleMembershipDate,
      'can_access_services': canAccessServices,
      'referral_code': referralCode,
      'referred_by': referredBy,
      'referral_level_1_count': referralLevel1Count,
      'referral_level_2_count': referralLevel2Count,
      'referral_earnings_total': referralEarningsTotal,
      'preferred_language': preferredLanguage,
      'has_accepted_terms': hasAcceptedTerms,
      'force_update_required': forceUpdateRequired,
      'maintenance_mode_override': maintenanceModeOverride,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.fullName == e2?.fullName &&
        e1?.dateOfBirth == e2?.dateOfBirth &&
        e1?.createdAt == e2?.createdAt &&
        e1?.isActive == e2?.isActive &&
        e1?.coverPhotoUrl == e2?.coverPhotoUrl &&
        e1?.walletBalance == e2?.walletBalance &&
        e1?.membershipType == e2?.membershipType &&
        e1?.membershipActive == e2?.membershipActive &&
        e1?.membershipStartDate == e2?.membershipStartDate &&
        e1?.membershipEndDate == e2?.membershipEndDate &&
        e1?.membershipCanceled == e2?.membershipCanceled &&
        e1?.nextEligibleMembershipDate == e2?.nextEligibleMembershipDate &&
        e1?.canAccessServices == e2?.canAccessServices &&
        e1?.referralCode == e2?.referralCode &&
        e1?.referredBy == e2?.referredBy &&
        e1?.referralLevel1Count == e2?.referralLevel1Count &&
        e1?.referralLevel2Count == e2?.referralLevel2Count &&
        e1?.referralEarningsTotal == e2?.referralEarningsTotal &&
        e1?.preferredLanguage == e2?.preferredLanguage &&
        listEquality.equals(e1?.savedAddresses, e2?.savedAddresses) &&
        listEquality.equals(e1?.savedCards, e2?.savedCards) &&
        e1?.hasAcceptedTerms == e2?.hasAcceptedTerms &&
        e1?.forceUpdateRequired == e2?.forceUpdateRequired &&
        e1?.maintenanceModeOverride == e2?.maintenanceModeOverride &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.phoneNumber,
        e?.fullName,
        e?.dateOfBirth,
        e?.createdAt,
        e?.isActive,
        e?.coverPhotoUrl,
        e?.walletBalance,
        e?.membershipType,
        e?.membershipActive,
        e?.membershipStartDate,
        e?.membershipEndDate,
        e?.membershipCanceled,
        e?.nextEligibleMembershipDate,
        e?.canAccessServices,
        e?.referralCode,
        e?.referredBy,
        e?.referralLevel1Count,
        e?.referralLevel2Count,
        e?.referralEarningsTotal,
        e?.preferredLanguage,
        e?.savedAddresses,
        e?.savedCards,
        e?.hasAcceptedTerms,
        e?.forceUpdateRequired,
        e?.maintenanceModeOverride,
        e?.createdTime
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
