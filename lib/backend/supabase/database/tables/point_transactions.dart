import '../database.dart';

class PointTransactionsTable extends SupabaseTable<PointTransactionsRow> {
  @override
  String get tableName => 'point_transactions';

  @override
  PointTransactionsRow createRow(Map<String, dynamic> data) =>
      PointTransactionsRow(data);
}

class PointTransactionsRow extends SupabaseDataRow {
  PointTransactionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PointTransactionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  int get amount => getField<int>('amount')!;
  set amount(int value) => setField<int>('amount', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get relatedType => getField<String>('related_type');
  set relatedType(String? value) => setField<String>('related_type', value);

  String? get relatedId => getField<String>('related_id');
  set relatedId(String? value) => setField<String>('related_id', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
