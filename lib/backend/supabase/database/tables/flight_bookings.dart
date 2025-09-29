import '../database.dart';

class FlightBookingsTable extends SupabaseTable<FlightBookingsRow> {
  @override
  String get tableName => 'flight_bookings';

  @override
  FlightBookingsRow createRow(Map<String, dynamic> data) =>
      FlightBookingsRow(data);
}

class FlightBookingsRow extends SupabaseDataRow {
  FlightBookingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FlightBookingsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get duffelOfferId => getField<String>('duffel_offer_id')!;
  set duffelOfferId(String value) => setField<String>('duffel_offer_id', value);

  String get origin => getField<String>('origin')!;
  set origin(String value) => setField<String>('origin', value);

  String get destination => getField<String>('destination')!;
  set destination(String value) => setField<String>('destination', value);

  DateTime get departureDate => getField<DateTime>('departure_date')!;
  set departureDate(DateTime value) =>
      setField<DateTime>('departure_date', value);

  DateTime? get returnDate => getField<DateTime>('return_date');
  set returnDate(DateTime? value) => setField<DateTime>('return_date', value);

  int get passengers => getField<int>('passengers')!;
  set passengers(int value) => setField<int>('passengers', value);

  String? get cabinClass => getField<String>('cabin_class');
  set cabinClass(String? value) => setField<String>('cabin_class', value);

  double get totalPrice => getField<double>('total_price')!;
  set totalPrice(double value) => setField<double>('total_price', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  int? get pointsUsed => getField<int>('points_used');
  set pointsUsed(int? value) => setField<int>('points_used', value);

  double? get pointsDiscount => getField<double>('points_discount');
  set pointsDiscount(double? value) =>
      setField<double>('points_discount', value);

  double? get cashbackEarned => getField<double>('cashback_earned');
  set cashbackEarned(double? value) =>
      setField<double>('cashback_earned', value);

  double get finalPrice => getField<double>('final_price')!;
  set finalPrice(double value) => setField<double>('final_price', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  dynamic? get bookingData => getField<dynamic>('booking_data');
  set bookingData(dynamic? value) => setField<dynamic>('booking_data', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
