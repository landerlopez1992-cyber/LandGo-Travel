import '../database.dart';

class ReferralTreeTable extends SupabaseTable<ReferralTreeRow> {
  @override
  String get tableName => 'referral_tree';

  @override
  ReferralTreeRow createRow(Map<String, dynamic> data) => ReferralTreeRow(data);
}

class ReferralTreeRow extends SupabaseDataRow {
  ReferralTreeRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ReferralTreeTable();

  String? get referrerId => getField<String>('referrer_id');
  set referrerId(String? value) => setField<String>('referrer_id', value);

  int? get level => getField<int>('level');
  set level(int? value) => setField<int>('level', value);

  int? get referralCount => getField<int>('referral_count');
  set referralCount(int? value) => setField<int>('referral_count', value);

  int? get totalBonusPoints => getField<int>('total_bonus_points');
  set totalBonusPoints(int? value) =>
      setField<int>('total_bonus_points', value);

  double? get totalBonusCashback => getField<double>('total_bonus_cashback');
  set totalBonusCashback(double? value) =>
      setField<double>('total_bonus_cashback', value);

  List<String> get referredNames => getListField<String>('referred_names');
  set referredNames(List<String>? value) =>
      setListField<String>('referred_names', value);
}
