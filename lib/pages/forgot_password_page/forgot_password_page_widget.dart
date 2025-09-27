import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'forgot_password_page_model.dart';
export 'forgot_password_page_model.dart';

class ForgotPasswordPageWidget extends StatefulWidget {
  const ForgotPasswordPageWidget({super.key});

  static String routeName = 'ForgotPasswordPage';
  static String routePath = '/forgotPassword';

  @override
  State<ForgotPasswordPageWidget> createState() =>
      _ForgotPasswordPageWidgetState();
}

class _ForgotPasswordPageWidgetState extends State<ForgotPasswordPageWidget> {
  late ForgotPasswordPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ForgotPasswordPageModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

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
        backgroundColor: const Color(0xFFF1F5F9), // COLORES LANDGO TRAVEL - Fondo General
        appBar: AppBar(
          backgroundColor: const Color(0xFF37474F), // COLORES LANDGO TRAVEL - Header
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'Recover Password',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 90,
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Image.network(
                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/land-go-travel-khmzio/assets/72g91s54bkzj/1.png',
                    fit: BoxFit.contain,
                  ),
                ),
                
                // Título
                Text(
                  'Forgot your password?',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Inter Tight',
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937), // COLORES LANDGO TRAVEL - Texto Principal
                        fontSize: 24,
                        letterSpacing: 0.0,
                      ),
                ),
                
                const SizedBox(height: 16),
                
                // Subtítulo
                Text(
                  'Enter your email and we will send you a verification code to reset your password.',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: const Color(0xFF6B7280), // COLORES LANDGO TRAVEL - Texto Secundario
                        fontSize: 16,
                        letterSpacing: 0.0,
                        lineHeight: 1.5,
                      ),
                ),
                
                const SizedBox(height: 32),
                
                // Formulario
                Form(
                  key: _model.formKey,
                  child: Column(
                    children: [
                      // Campo de email
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC), // COLORES LANDGO TRAVEL - Cards/Fondos
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: TextFormField(
                          controller: _model.textController,
                          focusNode: _model.textFieldFocusNode,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: 'Inter',
                                  color: const Color(0xFF6B7280),
                                  letterSpacing: 0.0,
                                ),
                            hintText: 'Ingresa tu email',
                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: 'Inter',
                                  color: const Color(0xFF9CA3AF),
                                  letterSpacing: 0.0,
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF4CAF50), // COLORES LANDGO TRAVEL - Verde vibrante
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFDC2626), // COLORES LANDGO TRAVEL - Error
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFDC2626),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Inter',
                                color: const Color(0xFF1F2937),
                                letterSpacing: 0.0,
                              ),
                          validator: (val) => _model.textControllerValidator?.call(context, val),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Botón enviar
                      FFButtonWidget(
                        onPressed: () async {
                          if (_model.formKey.currentState == null ||
                              !_model.formKey.currentState!.validate()) {
                            return;
                          }

                          try {
                            // Generar código de 6 dígitos
                            final verificationCode = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
                            
                            // Guardar código en Supabase (tabla temporal)
                            await SupaFlow.client.from('password_reset_codes').insert({
                              'email': _model.textController.text,
                              'code': verificationCode,
                              'expires_at': DateTime.now().add(Duration(minutes: 10)).toIso8601String(),
                            });
                            
                            // Enviar email con código usando Supabase Edge Function
                            final response = await SupaFlow.client.functions.invoke(
                              'send-verification-code',
                              body: {
                                'email': _model.textController.text,
                                'code': verificationCode,
                              },
                            );
                            
                            if (response.status == 200) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Verification code sent. Check your inbox.',
                                    ),
                                    backgroundColor: const Color(0xFF4CAF50), // COLORES LANDGO TRAVEL - Éxito
                                  ),
                                );
                                context.pushNamed(
                                  'VerificationCodePage',
                                  queryParameters: {
                                    'email': _model.textController.text,
                                  },
                                );
                              }
                            } else {
                              throw Exception('Failed to send email');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              String errorMessage = 'Error sending verification code. Please try again later.';
                              if (e.toString().contains('over_email_send_rate_limit')) {
                                errorMessage = 'Please wait a moment before requesting another code.';
                              } else if (e.toString().contains('rate_limit')) {
                                errorMessage = 'Too many requests. Please wait before trying again.';
                              } else if (e.toString().contains('email_not_confirmed')) {
                                errorMessage = 'Please confirm your email address first.';
                              } else if (e.toString().contains('user_not_found')) {
                                errorMessage = 'Email address not found. Please check and try again.';
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
                        text: 'Send verification code',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 56,
                          padding: const EdgeInsets.all(8),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: const Color(0xFFFF9800), // COLORES LANDGO TRAVEL - Botones Principales
                          textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                                fontFamily: 'Inter Tight',
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 0.0,
                              ),
                          elevation: 2,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Enlace de regreso
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remember your password? ',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: const Color(0xFF6B7280),
                            letterSpacing: 0.0,
                          ),
                    ),
                    InkWell(
                      onTap: () => context.safePop(),
                      child: Text(
                        'Sign in',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF37474F), // COLORES LANDGO TRAVEL - Header
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
