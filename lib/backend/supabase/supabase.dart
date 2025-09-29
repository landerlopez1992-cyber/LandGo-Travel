import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '/flutter_flow/flutter_flow_util.dart';

export 'database/database.dart';

String _kSupabaseUrl = 'https://dumgmnibxhfchjyowvbz.supabase.co';
String _kSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1bWdtbmlieGhmY2hqeW93dmJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3NjYxMDUsImV4cCI6MjA3NDM0MjEwNX0.zbmtNeny-BbYNHRXCNO_S1VU9_ZfixXkkc7dmAupI4Q';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() => Supabase.initialize(
        url: _kSupabaseUrl,
        headers: {
          'X-Client-Info': 'flutterflow',
        },
        anonKey: _kSupabaseAnonKey,
        debug: false,
        authOptions: FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce, // CRÍTICO: Para persistir sesiones
          localStorage: SharedPreferencesLocalStorage(persistSessionKey: 'landgo_session'), // Guardar en storage local
          detectSessionInUri: true, // Detectar sesión en URL
        ),
      );
}
