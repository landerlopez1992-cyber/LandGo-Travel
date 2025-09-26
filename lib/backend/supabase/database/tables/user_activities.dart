import '../database.dart';

class UserActivitiesTable extends SupabaseTable<UserActivitiesRow> {
  @override
  String get tableName => 'user_activities';

  @override
  UserActivitiesRow createRow(Map<String, dynamic> data) =>
      UserActivitiesRow(data);
}

class UserActivitiesRow extends SupabaseDataRow {
  UserActivitiesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserActivitiesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get activityType => getField<String>('activity_type')!;
  set activityType(String value) => setField<String>('activity_type', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  int? get pointsEarned => getField<int>('points_earned');
  set pointsEarned(int? value) => setField<int>('points_earned', value);

  double? get cashbackEarned => getField<double>('cashback_earned');
  set cashbackEarned(double? value) =>
      setField<double>('cashback_earned', value);

  dynamic? get metadata => getField<dynamic>('metadata');
  set metadata(dynamic? value) => setField<dynamic>('metadata', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
