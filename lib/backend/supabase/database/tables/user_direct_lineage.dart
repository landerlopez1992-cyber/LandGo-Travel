import '../database.dart';

class UserDirectLineageTable extends SupabaseTable<UserDirectLineageRow> {
  @override
  String get tableName => 'user_direct_lineage';

  @override
  UserDirectLineageRow createRow(Map<String, dynamic> data) =>
      UserDirectLineageRow(data);
}

class UserDirectLineageRow extends SupabaseDataRow {
  UserDirectLineageRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserDirectLineageTable();

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get userName => getField<String>('user_name');
  set userName(String? value) => setField<String>('user_name', value);

  String? get userEmail => getField<String>('user_email');
  set userEmail(String? value) => setField<String>('user_email', value);

  String? get userMembership => getField<String>('user_membership');
  set userMembership(String? value) =>
      setField<String>('user_membership', value);

  int? get totalReferrals => getField<int>('total_referrals');
  set totalReferrals(int? value) => setField<int>('total_referrals', value);

  int? get activeReferrals => getField<int>('active_referrals');
  set activeReferrals(int? value) => setField<int>('active_referrals', value);

  int? get subscribedReferrals => getField<int>('subscribed_referrals');
  set subscribedReferrals(int? value) =>
      setField<int>('subscribed_referrals', value);

  int? get totalPointsEarned => getField<int>('total_points_earned');
  set totalPointsEarned(int? value) =>
      setField<int>('total_points_earned', value);

  double? get totalCashbackEarned => getField<double>('total_cashback_earned');
  set totalCashbackEarned(double? value) =>
      setField<double>('total_cashback_earned', value);

  double? get avgSubscriptionValue =>
      getField<double>('avg_subscription_value');
  set avgSubscriptionValue(double? value) =>
      setField<double>('avg_subscription_value', value);
}
