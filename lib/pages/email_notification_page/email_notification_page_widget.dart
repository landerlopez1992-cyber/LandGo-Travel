import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'email_notification_page_model.dart';
export 'email_notification_page_model.dart';

class EmailNotificationPageWidget extends StatefulWidget {
  const EmailNotificationPageWidget({
    super.key,
    this.email,
    this.fullName,
  });

  final String? email;
  final String? fullName;

  static String routeName = 'EmailNotificationPage';
  static String routePath = '/emailNotification';

  @override
  State<EmailNotificationPageWidget> createState() =>
      _EmailNotificationPageWidgetState();
}

class _EmailNotificationPageWidgetState extends State<EmailNotificationPageWidget> {
  late EmailNotificationPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmailNotificationPageModel());

    // Iniciar verificación automática cada 5 segundos
    _startAutoCheck();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  void _startAutoCheck() {
    // Verificar cada 5 segundos si el email está confirmado
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _checkEmailConfirmation();
        _startAutoCheck(); // Continuar verificando
      }
    });
  }

  Future<void> _checkEmailConfirmation() async {
    try {
      // Refrescar sesión para obtener datos actualizados
      await SupaFlow.client.auth.refreshSession();
      
      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser != null) {
        // Verificar si el email está confirmado
        if (currentUser.emailConfirmedAt != null) {
          print('✅ Email confirmado! Navegando a Login...');
          
          if (mounted) {
            // Navegar a Login
            context.goNamedAuth('LoginPage', context.mounted);
          }
        }
      }
    } catch (e) {
      print('❌ Error verificando confirmación: $e');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF1A1A1A), // FONDO NEGRO LANDGO
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.0, -1.0),
                end: AlignmentDirectional(0, 1.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo de LandGo Travel
                  Container(
                    width: 120,
                    height: 90,
                    margin: const EdgeInsets.only(bottom: 40),
                    child: Image.network(
                      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/land-go-travel-khmzio/assets/72g91s54bkzj/1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  // Icono de email
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DD0E1).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      size: 50,
                      color: Color(0xFF4DD0E1),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Título
                  Text(
                    'Check Your Email',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Mensaje principal
                  Text(
                    'We sent a confirmation link to',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Email del usuario
                  Text(
                    widget.email ?? '',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF4DD0E1),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Instrucciones
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4DD0E1).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInstructionStep(
                          '1',
                          'Check your email inbox',
                          'Look for an email from LandGo Travel',
                        ),
                        const SizedBox(height: 16),
                        _buildInstructionStep(
                          '2',
                          'Click the confirmation link',
                          'This will activate your account',
                        ),
                        const SizedBox(height: 16),
                        _buildInstructionStep(
                          '3',
                          'Return to the app',
                          'This window will close automatically',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Indicador de carga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Waiting for confirmation...',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Nota de seguridad
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF37474F).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.security,
                          color: Color(0xFF4DD0E1),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'If you don\'t confirm your email, you won\'t be able to log in to your account.',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String title, String description) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF4DD0E1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
