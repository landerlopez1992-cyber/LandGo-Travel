import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'reset_password_page_model.dart';
export 'reset_password_page_model.dart';

class ResetPasswordPageWidget extends StatefulWidget {
  const ResetPasswordPageWidget({super.key});

  static String routeName = 'ResetPasswordPage';
  static String routePath = '/reset-password';

  @override
  State<ResetPasswordPageWidget> createState() =>
      _ResetPasswordPageWidgetState();
}

class _ResetPasswordPageWidgetState extends State<ResetPasswordPageWidget> {
  late ResetPasswordPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResetPasswordPageModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

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
            'Nueva Contraseña',
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
                  'Establecer nueva contraseña',
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
                  'Ingresa tu nueva contraseña y confírmala para completar el proceso.',
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
                      // Campo de nueva contraseña
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
                          controller: _model.textController1,
                          focusNode: _model.textFieldFocusNode1,
                          autofocus: false,
                          obscureText: !_model.passwordVisibility1,
                          decoration: InputDecoration(
                            labelText: 'Nueva contraseña',
                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: 'Inter',
                                  color: const Color(0xFF6B7280),
                                  letterSpacing: 0.0,
                                ),
                            hintText: 'Ingresa tu nueva contraseña',
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
                            suffixIcon: InkWell(
                              onTap: () => setState(
                                () => _model.passwordVisibility1 = !_model.passwordVisibility1,
                              ),
                              focusNode: FocusNode(skipTraversal: true),
                              child: Icon(
                                _model.passwordVisibility1
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF6B7280),
                                size: 20,
                              ),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Inter',
                                color: const Color(0xFF1F2937),
                                letterSpacing: 0.0,
                              ),
                          validator: (val) => _model.textController1Validator?.call(context, val),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Campo de confirmar contraseña
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
                          controller: _model.textController2,
                          focusNode: _model.textFieldFocusNode2,
                          autofocus: false,
                          obscureText: !_model.passwordVisibility2,
                          decoration: InputDecoration(
                            labelText: 'Confirmar contraseña',
                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: 'Inter',
                                  color: const Color(0xFF6B7280),
                                  letterSpacing: 0.0,
                                ),
                            hintText: 'Confirma tu nueva contraseña',
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
                            suffixIcon: InkWell(
                              onTap: () => setState(
                                () => _model.passwordVisibility2 = !_model.passwordVisibility2,
                              ),
                              focusNode: FocusNode(skipTraversal: true),
                              child: Icon(
                                _model.passwordVisibility2
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF6B7280),
                                size: 20,
                              ),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Inter',
                                color: const Color(0xFF1F2937),
                                letterSpacing: 0.0,
                              ),
                          validator: (val) => _model.textController2Validator?.call(context, val),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Botón actualizar contraseña
                      FFButtonWidget(
                        onPressed: () async {
                          if (_model.formKey.currentState == null ||
                              !_model.formKey.currentState!.validate()) {
                            return;
                          }

                          try {
                            // Obtener email del parámetro
                            final email = GoRouterState.of(context).uri.queryParameters['email'] ?? '';
                            
                            if (email.isEmpty) {
                              throw Exception('Email parameter is missing');
                            }
                            
                            // Actualizar contraseña usando Edge Function
                            final response = await SupaFlow.client.functions.invoke(
                              'update-password',
                              body: {
                                'email': email,
                                'newPassword': _model.textController1.text,
                              },
                            );
                            
                            if (response.status == 200) {
                              // Limpiar código usado de la tabla
                              await SupaFlow.client.from('password_reset_codes')
                                  .delete()
                                  .eq('email', email);
                              
                              // Enviar email de confirmación de cambio de contraseña
                              try {
                                await SupaFlow.client.functions.invoke(
                                  'send-verification-code',
                                  body: {
                                    'email': email,
                                    'type': 'password_changed',
                                    'fullName': 'User', // Se puede obtener del usuario si está logueado
                                  },
                                );
                              } catch (e) {
                                print('Error sending password change confirmation email: $e');
                              }
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Password updated successfully. You can now log in.',
                                    ),
                                    backgroundColor: const Color(0xFF4CAF50), // COLORES LANDGO TRAVEL - Éxito
                                  ),
                                );
                                context.goNamedAuth('LoginPage', context.mounted);
                              }
                            } else {
                              throw Exception('Failed to update password');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error updating password: ${e.toString()}'),
                                  backgroundColor: const Color(0xFFDC2626), // COLORES LANDGO TRAVEL - Error
                                ),
                              );
                            }
                          }
                        },
                        text: 'Actualizar contraseña',
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
                      '¿Recordaste tu contraseña? ',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: const Color(0xFF6B7280),
                            letterSpacing: 0.0,
                          ),
                    ),
                    InkWell(
                      onTap: () => context.goNamedAuth('LoginPage', context.mounted),
                      child: Text(
                        'Iniciar sesión',
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
