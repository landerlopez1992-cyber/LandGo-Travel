




import '/backend/supabase/supabase.dart';

Future<User?> emailSignInFunc(
  String email,
  String password,
) async {
  final AuthResponse res = await SupaFlow.client.auth
      .signInWithPassword(email: email, password: password);
  
  // Si el login es exitoso, verificar si es el primer login después de confirmar email
  if (res.user != null) {
    try {
      // Verificar si el usuario tiene email confirmado y es su primer login
      final userProfile = await SupaFlow.client.from('user_profiles')
          .select('welcome_email_sent')
          .eq('user_id', res.user!.id)
          .single();
      
      // Si no se ha enviado email de bienvenida, enviarlo
      if (userProfile == null || userProfile['welcome_email_sent'] != true) {
        await SupaFlow.client.functions.invoke(
          'send-verification-code',
          body: {
            'email': email,
            'type': 'welcome',
            'fullName': res.user!.userMetadata?['full_name'] ?? 'Traveler',
          },
        );
        
        // Marcar que se envió el email de bienvenida
        await SupaFlow.client.from('user_profiles').upsert({
          'user_id': res.user!.id,
          'email': email,
          'welcome_email_sent': true,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error sending welcome email: $e');
      // No fallar el login por error en el email de bienvenida
    }
  }
  
  return res.user;
}

Future<User?> emailCreateAccountFunc(
  String email,
  String password,
) async {
  final AuthResponse res =
      await SupaFlow.client.auth.signUp(email: email, password: password);

  // Return the user object regardless of email confirmation status
  // We handle email confirmation with our custom Resend system
  return res.user;
}
