import '../database.dart';

class CashbackTransactionsTable extends SupabaseTable<CashbackTransactionsRow> {
  @override
  String get tableName => 'cashback_transactions';

  @override
  CashbackTransactionsRow createRow(Map<String, dynamic> data) =>
      CashbackTransactionsRow(data);
}

class CashbackTransactionsRow extends SupabaseDataRow {
  CashbackTransactionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CashbackTransactionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get relatedType => getField<String>('related_type');
  set relatedType(String? value) => setField<String>('related_type', value);

  String? get relatedId => getField<String>('related_id');
  set relatedId(String? value) => setField<String>('related_id', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
