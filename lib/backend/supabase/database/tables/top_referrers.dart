import '../database.dart';

class TopReferrersTable extends SupabaseTable<TopReferrersRow> {
  @override
  String get tableName => 'top_referrers';

  @override
  TopReferrersRow createRow(Map<String, dynamic> data) => TopReferrersRow(data);
}

class TopReferrersRow extends SupabaseDataRow {
  TopReferrersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TopReferrersTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get membershipType => getField<String>('membership_type');
  set membershipType(String? value) =>
      setField<String>('membership_type', value);

  int? get totalReferrals => getField<int>('total_referrals');
  set totalReferrals(int? value) => setField<int>('total_referrals', value);

  int? get activeReferrals => getField<int>('active_referrals');
  set activeReferrals(int? value) => setField<int>('active_referrals', value);

  int? get totalPointsEarned => getField<int>('total_points_earned');
  set totalPointsEarned(int? value) =>
      setField<int>('total_points_earned', value);

  double? get totalCashbackEarned => getField<double>('total_cashback_earned');
  set totalCashbackEarned(double? value) =>
      setField<double>('total_cashback_earned', value);
}
