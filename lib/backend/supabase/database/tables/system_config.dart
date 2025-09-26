import '../database.dart';

class SystemConfigTable extends SupabaseTable<SystemConfigRow> {
  @override
  String get tableName => 'system_config';

  @override
  SystemConfigRow createRow(Map<String, dynamic> data) => SystemConfigRow(data);
}

class SystemConfigRow extends SupabaseDataRow {
  SystemConfigRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SystemConfigTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get key => getField<String>('key')!;
  set key(String value) => setField<String>('key', value);

  dynamic get value => getField<dynamic>('value')!;
  set value(dynamic value) => setField<dynamic>('value', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
