import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'email_confirmation_page_model.dart';
export 'email_confirmation_page_model.dart';

class EmailConfirmationPageWidget extends StatefulWidget {
  const EmailConfirmationPageWidget({
    super.key,
    this.email,
    this.fullName,
  });

  final String? email;
  final String? fullName;

  static String routeName = 'EmailConfirmationPage';
  static String routePath = '/emailConfirmation';

  @override
  State<EmailConfirmationPageWidget> createState() =>
      _EmailConfirmationPageWidgetState();
}

class _EmailConfirmationPageWidgetState
    extends State<EmailConfirmationPageWidget> {
  late EmailConfirmationPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmailConfirmationPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
        appBar: AppBar(
          backgroundColor: const Color(0xFF37474F), // COLORES LANDGO TRAVEL - Header
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.safePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          title: Text(
            'Confirm Email',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo oficial de LandGo Travel
                Container(
                  width: 120,
                  height: 90,
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Image.network(
                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/land-go-travel-khmzio/assets/72g91s54bkzj/1.png',
                    fit: BoxFit.contain,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Título principal
                Text(
                  'Check Your Email',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Inter Tight',
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937), // COLORES LANDGO TRAVEL - Texto Principal
                        fontSize: 28,
                        letterSpacing: 0.0,
                      ),
                ),
                
                const SizedBox(height: 16),
                
                // Subtítulo
                Text(
                  'We\'ve sent a confirmation link to:',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: const Color(0xFF6B7280), // COLORES LANDGO TRAVEL - Texto Secundario
                        fontSize: 16,
                        letterSpacing: 0.0,
                        lineHeight: 1.5,
                      ),
                ),
                
                const SizedBox(height: 8),
                
                // Email destacado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    widget.email ?? 'your email address',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: 'Inter',
                          color: const Color(0xFF37474F), // COLORES LANDGO TRAVEL - Header
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Card de instrucciones
                _buildInstructionsCard(),
                
                const SizedBox(height: 32),
                
                // Botones de acción
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF37474F), // COLORES LANDGO TRAVEL - Header
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Next Steps',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily: 'Inter',
                      color: const Color(0xFF1F2937), // COLORES LANDGO TRAVEL - Texto Principal
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInstructionStep(
            number: '1',
            text: 'Check your email inbox',
            icon: Icons.inbox_outlined,
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            number: '2',
            text: 'Look for the LandGo Travel email',
            icon: Icons.search,
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            number: '3',
            text: 'Click the confirmation link',
            icon: Icons.link,
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            number: '4',
            text: 'Your account will be activated',
            icon: Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep({
    required String number,
    required String text,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF37474F), // COLORES LANDGO TRAVEL - Header
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          icon,
          size: 22,
          color: const Color(0xFF6B7280), // COLORES LANDGO TRAVEL - Texto Secundario
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Inter',
                  color: const Color(0xFF1F2937), // COLORES LANDGO TRAVEL - Texto Principal
                  fontSize: 15,
                  letterSpacing: 0.0,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        FFButtonWidget(
          onPressed: () async {
            if (widget.email == null || widget.email!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not resend email: email not available.'),
                  backgroundColor: Color(0xFFDC2626), // COLORES LANDGO TRAVEL - Error
                ),
              );
              return;
            }
            try {
              // Enviar email de confirmación personalizado con Resend
              await SupaFlow.client.functions.invoke(
                'send-verification-code',
                body: {
                  'email': widget.email!,
                  'type': 'email_confirmation',
                  'fullName': widget.fullName ?? 'User',
                },
              );
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Confirmation email resent to ${widget.email}.'),
                    backgroundColor: const Color(0xFF4CAF50), // COLORES LANDGO TRAVEL - Éxito
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                String errorMessage = 'Error resending email. Please try again later.';
                if (e.toString().contains('over_email_send_rate_limit')) {
                  errorMessage = 'Please wait a moment before requesting another email.';
                } else if (e.toString().contains('rate_limit')) {
                  errorMessage = 'Too many requests. Please wait before trying again.';
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: const Color(0xFFDC2626), // COLORES LANDGO TRAVEL - Error
                  ),
                );
              }
            }
          },
          text: 'Resend Email',
          icon: const Icon(Icons.refresh, size: 20),
          options: FFButtonOptions(
            width: double.infinity,
            height: 56,
            color: const Color(0xFF37474F), // COLORES LANDGO TRAVEL - Header
            textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 16),
        FFButtonWidget(
          onPressed: () => context.pushNamed('LoginPage'),
          text: 'Go to Login',
          icon: const Icon(Icons.login, size: 20),
          options: FFButtonOptions(
            width: double.infinity,
            height: 56,
            color: const Color(0xFFFF9800), // COLORES LANDGO TRAVEL - Botones Principales
            textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }
}
