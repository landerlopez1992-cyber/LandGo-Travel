import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'verification_code_page_model.dart';
export 'verification_code_page_model.dart';

class VerificationCodePageWidget extends StatefulWidget {
  const VerificationCodePageWidget({
    super.key,
    this.email,
  });

  final String? email;

  static String routeName = 'VerificationCodePage';
  static String routePath = '/verificationCode';

  @override
  State<VerificationCodePageWidget> createState() =>
      _VerificationCodePageWidgetState();
}

class _VerificationCodePageWidgetState extends State<VerificationCodePageWidget> {
  late VerificationCodePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VerificationCodePageModel());

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
            'Verify Code',
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
                
                // Título
                Text(
                  'Verify your code',
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
                  'We have sent a 6-digit code to:',
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
                
                // Email
                Text(
                  widget.email ?? '',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: const Color(0xFF37474F), // COLORES LANDGO TRAVEL - Header
                        fontSize: 16,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                
                const SizedBox(height: 32),
                
                // Formulario
                Form(
                  key: _model.formKey,
                  child: Column(
                    children: [
                      // 6 casillas modernas para el código
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 50,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC), // COLORES LANDGO TRAVEL - Cards/Fondos
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _model.digitFocusNodes[index].hasFocus 
                                    ? const Color(0xFF4CAF50) // Verde cuando está enfocado
                                    : const Color(0xFFE2E8F0),
                                width: _model.digitFocusNodes[index].hasFocus ? 2 : 1,
                              ),
                              boxShadow: _model.digitFocusNodes[index].hasFocus
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF4CAF50).withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: TextFormField(
                              controller: _model.digitControllers[index],
                              focusNode: _model.digitFocusNodes[index],
                              autofocus: index == 0,
                              obscureText: false,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context).headlineMedium.override(
                                    fontFamily: 'Inter',
                                    color: const Color(0xFF1F2937),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  // Move to next field
                                  if (index < 5) {
                                    _model.digitFocusNodes[index + 1].requestFocus();
                                  } else {
                                    // Last field, unfocus
                                    _model.digitFocusNodes[index].unfocus();
                                  }
                                } else if (value.isEmpty && index > 0) {
                                  // Move to previous field when deleting
                                  _model.digitFocusNodes[index - 1].requestFocus();
                                }
                              },
                              onTap: () {
                                // Select all text when tapping
                                _model.digitControllers[index].selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: _model.digitControllers[index].text.length,
                                );
                              },
                            ),
                          );
                        }),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Botón verificar
                      FFButtonWidget(
                        onPressed: () async {
                          if (_model.formKey.currentState == null ||
                              !_model.formKey.currentState!.validate()) {
                            return;
                          }

                          try {
                            // Verificar que todos los campos estén llenos
                            if (_model.verificationCode.length != 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter all 6 digits.'),
                                  backgroundColor: const Color(0xFFDC2626), // COLORES LANDGO TRAVEL - Error
                                ),
                              );
                              return;
                            }

                            // Verificar código con Supabase
                            final response = await SupaFlow.client.from('password_reset_codes')
                                .select()
                                .eq('email', widget.email!)
                                .eq('code', _model.verificationCode)
                                .gte('expires_at', DateTime.now().toIso8601String())
                                .single();
                            
                            if (response == null) {
                              throw Exception('Invalid or expired code');
                            }
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Code verified successfully. Proceeding to reset password.',
                                  ),
                                  backgroundColor: const Color(0xFF4CAF50), // COLORES LANDGO TRAVEL - Éxito
                                ),
                              );
                              context.pushNamed(
                                'ResetPasswordPage',
                                queryParameters: {
                                  'email': widget.email,
                                },
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Invalid code. Please try again.'),
                                  backgroundColor: const Color(0xFFDC2626), // COLORES LANDGO TRAVEL - Error
                                ),
                              );
                            }
                          }
                        },
                        text: 'Verify code',
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
                      
                      const SizedBox(height: 16),
                      
                      // Botón reenviar código
                      FFButtonWidget(
                        onPressed: () async {
                          try {
                            // Generar nuevo código de 6 dígitos
                            final verificationCode = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
                            
                            // Eliminar código anterior
                            await SupaFlow.client.from('password_reset_codes')
                                .delete()
                                .eq('email', widget.email!);
                            
                            // Guardar nuevo código
                            await SupaFlow.client.from('password_reset_codes').insert({
                              'email': widget.email!,
                              'code': verificationCode,
                              'expires_at': DateTime.now().add(Duration(minutes: 10)).toIso8601String(),
                            });
                            
                            // Enviar email con nuevo código
                            final response = await SupaFlow.client.functions.invoke(
                              'send-verification-code',
                              body: {
                                'email': widget.email!,
                                'code': verificationCode,
                              },
                            );
                            
                            if (response.status != 200) {
                              throw Exception('Failed to send email');
                            }
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Code resent successfully.'),
                                  backgroundColor: const Color(0xFF4CAF50), // COLORES LANDGO TRAVEL - Éxito
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              String errorMessage = 'Error resending code. Please try again.';
                              if (e.toString().contains('over_email_send_rate_limit')) {
                                errorMessage = 'Please wait a moment before requesting another code.';
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
                        text: 'Resend code',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 48,
                          padding: const EdgeInsets.all(8),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: Colors.transparent,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF37474F), // COLORES LANDGO TRAVEL - Header
                                fontSize: 14,
                                letterSpacing: 0.0,
                              ),
                          elevation: 0,
                          borderSide: const BorderSide(
                            color: Color(0xFF37474F),
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
                      'Didn\'t receive the code? ',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: const Color(0xFF6B7280),
                            letterSpacing: 0.0,
                          ),
                    ),
                    InkWell(
                      onTap: () => context.safePop(),
                      child: Text(
                        'Go back',
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
