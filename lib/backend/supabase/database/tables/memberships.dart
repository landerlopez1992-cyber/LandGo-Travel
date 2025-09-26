import '../database.dart';

class MembershipsTable extends SupabaseTable<MembershipsRow> {
  @override
  String get tableName => 'memberships';

  @override
  MembershipsRow createRow(Map<String, dynamic> data) => MembershipsRow(data);
}

class MembershipsRow extends SupabaseDataRow {
  MembershipsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MembershipsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  double get price => getField<double>('price')!;
  set price(double value) => setField<double>('price', value);

  int get monthlyPoints => getField<int>('monthly_points')!;
  set monthlyPoints(int value) => setField<int>('monthly_points', value);

  double get discountPercentage => getField<double>('discount_percentage')!;
  set discountPercentage(double value) =>
      setField<double>('discount_percentage', value);

  double get cashbackPercentage => getField<double>('cashback_percentage')!;
  set cashbackPercentage(double value) =>
      setField<double>('cashback_percentage', value);

  int get referralBonusPoints => getField<int>('referral_bonus_points')!;
  set referralBonusPoints(int value) =>
      setField<int>('referral_bonus_points', value);

  double get referralBonusCashback =>
      getField<double>('referral_bonus_cashback')!;
  set referralBonusCashback(double value) =>
      setField<double>('referral_bonus_cashback', value);

  DateTime? get startDate => getField<DateTime>('start_date');
  set startDate(DateTime? value) => setField<DateTime>('start_date', value);

  DateTime? get endDate => getField<DateTime>('end_date');
  set endDate(DateTime? value) => setField<DateTime>('end_date', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
