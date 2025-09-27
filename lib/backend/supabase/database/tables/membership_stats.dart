import '../database.dart';

class MembershipStatsTable extends SupabaseTable<MembershipStatsRow> {
  @override
  String get tableName => 'membership_stats';

  @override
  MembershipStatsRow createRow(Map<String, dynamic> data) =>
      MembershipStatsRow(data);
}

class MembershipStatsRow extends SupabaseDataRow {
  MembershipStatsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MembershipStatsTable();

  String? get membershipType => getField<String>('membership_type');
  set membershipType(String? value) =>
      setField<String>('membership_type', value);

  int? get userCount => getField<int>('user_count');
  set userCount(int? value) => setField<int>('user_count', value);

  double? get avgReferrals => getField<double>('avg_referrals');
  set avgReferrals(double? value) => setField<double>('avg_referrals', value);

  double? get avgCashback => getField<double>('avg_cashback');
  set avgCashback(double? value) => setField<double>('avg_cashback', value);

  int? get totalReferralsGenerated =>
      getField<int>('total_referrals_generated');
  set totalReferralsGenerated(int? value) =>
      setField<int>('total_referrals_generated', value);
}
