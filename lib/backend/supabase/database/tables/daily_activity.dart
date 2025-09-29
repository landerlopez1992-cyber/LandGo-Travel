import '../database.dart';

class DailyActivityTable extends SupabaseTable<DailyActivityRow> {
  @override
  String get tableName => 'daily_activity';

  @override
  DailyActivityRow createRow(Map<String, dynamic> data) =>
      DailyActivityRow(data);
}

class DailyActivityRow extends SupabaseDataRow {
  DailyActivityRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DailyActivityTable();

  DateTime? get activityDate => getField<DateTime>('activity_date');
  set activityDate(DateTime? value) =>
      setField<DateTime>('activity_date', value);

  int? get activeUsers => getField<int>('active_users');
  set activeUsers(int? value) => setField<int>('active_users', value);

  int? get bookingsCount => getField<int>('bookings_count');
  set bookingsCount(int? value) => setField<int>('bookings_count', value);

  int? get referralsCount => getField<int>('referrals_count');
  set referralsCount(int? value) => setField<int>('referrals_count', value);

  int? get pointsActivities => getField<int>('points_activities');
  set pointsActivities(int? value) => setField<int>('points_activities', value);

  int? get totalPointsDistributed => getField<int>('total_points_distributed');
  set totalPointsDistributed(int? value) =>
      setField<int>('total_points_distributed', value);

  double? get totalCashbackDistributed =>
      getField<double>('total_cashback_distributed');
  set totalCashbackDistributed(double? value) =>
      setField<double>('total_cashback_distributed', value);
}
