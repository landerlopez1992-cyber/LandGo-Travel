import '../database.dart';

class PaymentsTable extends SupabaseTable<PaymentsRow> {
  @override
  String get tableName => 'payments';

  @override
  PaymentsRow createRow(Map<String, dynamic> data) => PaymentsRow(data);
}

class PaymentsRow extends SupabaseDataRow {
  PaymentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PaymentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get paymentMethod => getField<String>('payment_method');
  set paymentMethod(String? value) => setField<String>('payment_method', value);

  String? get transactionId => getField<String>('transaction_id');
  set transactionId(String? value) => setField<String>('transaction_id', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get relatedType => getField<String>('related_type');
  set relatedType(String? value) => setField<String>('related_type', value);

  String? get relatedId => getField<String>('related_id');
  set relatedId(String? value) => setField<String>('related_id', value);

  double? get cashbackEarned => getField<double>('cashback_earned');
  set cashbackEarned(double? value) =>
      setField<double>('cashback_earned', value);

  int? get pointsEarned => getField<int>('points_earned');
  set pointsEarned(int? value) => setField<int>('points_earned', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
