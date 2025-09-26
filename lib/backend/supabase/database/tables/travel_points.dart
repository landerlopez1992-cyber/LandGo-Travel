import '../database.dart';

class TravelPointsTable extends SupabaseTable<TravelPointsRow> {
  @override
  String get tableName => 'travel_points';

  @override
  TravelPointsRow createRow(Map<String, dynamic> data) => TravelPointsRow(data);
}

class TravelPointsRow extends SupabaseDataRow {
  TravelPointsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TravelPointsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int get currentBalance => getField<int>('current_balance')!;
  set currentBalance(int value) => setField<int>('current_balance', value);

  int get monthlyAllocation => getField<int>('monthly_allocation')!;
  set monthlyAllocation(int value) =>
      setField<int>('monthly_allocation', value);

  int get totalEarned => getField<int>('total_earned')!;
  set totalEarned(int value) => setField<int>('total_earned', value);

  int get totalSpent => getField<int>('total_spent')!;
  set totalSpent(int value) => setField<int>('total_spent', value);

  DateTime? get lastAllocatedAt => getField<DateTime>('last_allocated_at');
  set lastAllocatedAt(DateTime? value) =>
      setField<DateTime>('last_allocated_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
