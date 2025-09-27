import '../database.dart';

class UserDashboardTable extends SupabaseTable<UserDashboardRow> {
  @override
  String get tableName => 'user_dashboard';

  @override
  UserDashboardRow createRow(Map<String, dynamic> data) =>
      UserDashboardRow(data);
}

class UserDashboardRow extends SupabaseDataRow {
  UserDashboardRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserDashboardTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get membershipType => getField<String>('membership_type');
  set membershipType(String? value) =>
      setField<String>('membership_type', value);

  int? get totalReferrals => getField<int>('total_referrals');
  set totalReferrals(int? value) => setField<int>('total_referrals', value);

  double? get cashbackBalance => getField<double>('cashback_balance');
  set cashbackBalance(double? value) =>
      setField<double>('cashback_balance', value);

  String? get referralCode => getField<String>('referral_code');
  set referralCode(String? value) => setField<String>('referral_code', value);

  int? get pointsBalance => getField<int>('points_balance');
  set pointsBalance(int? value) => setField<int>('points_balance', value);

  int? get totalPointsEarned => getField<int>('total_points_earned');
  set totalPointsEarned(int? value) =>
      setField<int>('total_points_earned', value);

  int? get totalPointsSpent => getField<int>('total_points_spent');
  set totalPointsSpent(int? value) =>
      setField<int>('total_points_spent', value);

  int? get monthlyAllocation => getField<int>('monthly_allocation');
  set monthlyAllocation(int? value) =>
      setField<int>('monthly_allocation', value);

  int? get totalFlights => getField<int>('total_flights');
  set totalFlights(int? value) => setField<int>('total_flights', value);

  int? get totalHotels => getField<int>('total_hotels');
  set totalHotels(int? value) => setField<int>('total_hotels', value);

  double? get totalSpent => getField<double>('total_spent');
  set totalSpent(double? value) => setField<double>('total_spent', value);

  int? get directReferrals => getField<int>('direct_referrals');
  set directReferrals(int? value) => setField<int>('direct_referrals', value);

  int? get unreadNotifications => getField<int>('unread_notifications');
  set unreadNotifications(int? value) =>
      setField<int>('unread_notifications', value);
}
