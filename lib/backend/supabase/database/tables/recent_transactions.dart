import '../database.dart';

class RecentTransactionsTable extends SupabaseTable<RecentTransactionsRow> {
  @override
  String get tableName => 'recent_transactions';

  @override
  RecentTransactionsRow createRow(Map<String, dynamic> data) =>
      RecentTransactionsRow(data);
}

class RecentTransactionsRow extends SupabaseDataRow {
  RecentTransactionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RecentTransactionsTable();

  String? get transactionType => getField<String>('transaction_type');
  set transactionType(String? value) =>
      setField<String>('transaction_type', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get amount => getField<String>('amount');
  set amount(String? value) => setField<String>('amount', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get type => getField<String>('type');
  set type(String? value) => setField<String>('type', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
