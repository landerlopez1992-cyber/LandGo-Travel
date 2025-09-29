import '../database.dart';

class ReferralsTable extends SupabaseTable<ReferralsRow> {
  @override
  String get tableName => 'referrals';

  @override
  ReferralsRow createRow(Map<String, dynamic> data) => ReferralsRow(data);
}

class ReferralsRow extends SupabaseDataRow {
  ReferralsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ReferralsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get referrerId => getField<String>('referrer_id');
  set referrerId(String? value) => setField<String>('referrer_id', value);

  String? get referredId => getField<String>('referred_id');
  set referredId(String? value) => setField<String>('referred_id', value);

  int get level => getField<int>('level')!;
  set level(int value) => setField<int>('level', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  int? get bonusPoints => getField<int>('bonus_points');
  set bonusPoints(int? value) => setField<int>('bonus_points', value);

  double? get bonusCashback => getField<double>('bonus_cashback');
  set bonusCashback(double? value) => setField<double>('bonus_cashback', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get activatedAt => getField<DateTime>('activated_at');
  set activatedAt(DateTime? value) => setField<DateTime>('activated_at', value);
}
