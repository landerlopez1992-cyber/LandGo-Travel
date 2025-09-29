import '../database.dart';

class ProfilesTable extends SupabaseTable<ProfilesRow> {
  @override
  String get tableName => 'profiles';

  @override
  ProfilesRow createRow(Map<String, dynamic> data) => ProfilesRow(data);
}

class ProfilesRow extends SupabaseDataRow {
  ProfilesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProfilesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get email => getField<String>('email')!;
  set email(String value) => setField<String>('email', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get phone => getField<String>('phone');
  set phone(String? value) => setField<String>('phone', value);

  String? get avatarUrl => getField<String>('avatar_url');
  set avatarUrl(String? value) => setField<String>('avatar_url', value);

  String? get membershipType => getField<String>('membership_type');
  set membershipType(String? value) =>
      setField<String>('membership_type', value);

  String? get referralCode => getField<String>('referral_code');
  set referralCode(String? value) => setField<String>('referral_code', value);

  String? get referredBy => getField<String>('referred_by');
  set referredBy(String? value) => setField<String>('referred_by', value);

  int? get totalReferrals => getField<int>('total_referrals');
  set totalReferrals(int? value) => setField<int>('total_referrals', value);

  int? get totalEarnedPoints => getField<int>('total_earned_points');
  set totalEarnedPoints(int? value) =>
      setField<int>('total_earned_points', value);

  int? get totalSpentPoints => getField<int>('total_spent_points');
  set totalSpentPoints(int? value) =>
      setField<int>('total_spent_points', value);

  double? get cashbackBalance => getField<double>('cashback_balance');
  set cashbackBalance(double? value) =>
      setField<double>('cashback_balance', value);

  bool? get isVerified => getField<bool>('is_verified');
  set isVerified(bool? value) => setField<bool>('is_verified', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
