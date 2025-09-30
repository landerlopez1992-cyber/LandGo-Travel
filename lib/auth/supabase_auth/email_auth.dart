




import '/backend/supabase/supabase.dart';

Future<User?> emailSignInFunc(
  String email,
  String password,
) async {
  final AuthResponse res = await SupaFlow.client.auth
      .signInWithPassword(email: email, password: password);
  
  // Si el login es exitoso Y el email está confirmado, verificar si es la primera vez
  if (res.user != null && res.user!.emailConfirmedAt != null) {
    try {
      // Verificar si ya se envió el email de bienvenida
      final existingProfile = await SupaFlow.client
          .from('user_profiles')
          .select('welcome_email_sent')
          .eq('user_id', res.user!.id)
          .maybeSingle();

      bool welcomeEmailSent = false;
      
      if (existingProfile != null) {
        welcomeEmailSent = existingProfile['welcome_email_sent'] ?? false;
      } else {
        // Crear perfil de usuario si no existe
        await SupaFlow.client.from('user_profiles').insert({
          'user_id': res.user!.id,
          'email': email,
          'full_name': res.user!.userMetadata?['full_name'],
          'welcome_email_sent': false,
        });
      }

      // Solo enviar email de bienvenida si:
      // 1. El email está confirmado (emailConfirmedAt no es null)
      // 2. No se ha enviado el email de bienvenida antes
      // 3. Es el primer login exitoso después de confirmar el email
      if (!welcomeEmailSent) {
        await SupaFlow.client.functions.invoke(
          'send-verification-code',
          body: {
            'email': email,
            'type': 'welcome',
            'fullName': res.user!.userMetadata?['full_name'] ?? 'Traveler',
          },
        );
        
        // Marcar que se envió el email de bienvenida
        await SupaFlow.client
            .from('user_profiles')
            .update({'welcome_email_sent': true})
            .eq('user_id', res.user!.id);
            
        print('Welcome email sent to $email (first login after email confirmation)');
      } else {
        print('Welcome email already sent to $email previously - skipping');
      }
    } catch (e) {
      print('Error handling welcome email: $e');
      // No fallar el login por error en el email de bienvenida
    }
  } else if (res.user != null && res.user!.emailConfirmedAt == null) {
    print('Email not confirmed yet for $email - welcome email will be sent after confirmation and first login');
  }
  
  return res.user;
}

Future<User?> emailCreateAccountFunc(
  String email,
  String password,
) async {
  // Solo crear la cuenta de autenticación en Supabase
  // El perfil se creará después desde el widget SignUp
  final AuthResponse res =
      await SupaFlow.client.auth.signUp(email: email, password: password);

  // Return the user object regardless of email confirmation status
  // We handle email confirmation with our custom Resend system
  return res.user;
}
