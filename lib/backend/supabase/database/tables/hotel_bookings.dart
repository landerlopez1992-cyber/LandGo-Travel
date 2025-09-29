import '../database.dart';

class HotelBookingsTable extends SupabaseTable<HotelBookingsRow> {
  @override
  String get tableName => 'hotel_bookings';

  @override
  HotelBookingsRow createRow(Map<String, dynamic> data) =>
      HotelBookingsRow(data);
}

class HotelBookingsRow extends SupabaseDataRow {
  HotelBookingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => HotelBookingsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get hotelId => getField<String>('hotel_id')!;
  set hotelId(String value) => setField<String>('hotel_id', value);

  String get hotelName => getField<String>('hotel_name')!;
  set hotelName(String value) => setField<String>('hotel_name', value);

  String get location => getField<String>('location')!;
  set location(String value) => setField<String>('location', value);

  DateTime get checkInDate => getField<DateTime>('check_in_date')!;
  set checkInDate(DateTime value) => setField<DateTime>('check_in_date', value);

  DateTime get checkOutDate => getField<DateTime>('check_out_date')!;
  set checkOutDate(DateTime value) =>
      setField<DateTime>('check_out_date', value);

  int get guests => getField<int>('guests')!;
  set guests(int value) => setField<int>('guests', value);

  int get rooms => getField<int>('rooms')!;
  set rooms(int value) => setField<int>('rooms', value);

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
