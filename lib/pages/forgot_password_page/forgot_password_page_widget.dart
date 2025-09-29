import '/flutter_flow/flutter_flow_util.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        backgroundColor: Color(0xFF1A1A1A), // Fondo negro con gradiente sutil
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.0, -1.0),
                end: AlignmentDirectional(0, 1.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 40.0, 24.0, 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con botón de regreso
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            context.safePop();
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFFFFFFFF),
                            size: 24.0,
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Text(
                          'Forgot Password',
                          style: GoogleFonts.inter(
                            color: Color(0xFFFFFFFF),
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 60.0),
                    
                    // Logo de LandGo Travel centrado
                    Center(
                      child: Container(
                        width: 200.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/land-go-travel-khmzio/assets/72g91s54bkzj/1.png',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40.0),
                    
                    // Título principal centrado
                    Center(
                      child: Text(
                        'Reset your password',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Color(0xFFFFFFFF),
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 8.0),
                    
                    // Descripción centrada
                    Center(
                      child: Text(
                        'Enter your email address and we\'ll send you a verification code to reset your password',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Color(0xFF888888),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40.0),
                  
                    // Formulario
                    Form(
                      key: _model.formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campo Email
                          Text(
                            'Email address',
                            style: GoogleFonts.inter(
                              color: Color(0xFFFFFFFF),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: Color(0xFF404040),
                                width: 1.0,
                              ),
                            ),
                            child: TextFormField(
                              controller: _model.textController,
                              focusNode: _model.textFieldFocusNode,
                              autofocus: false,
                              textInputAction: TextInputAction.done,
                              obscureText: false,
                              style: GoogleFonts.inter(
                                color: Color(0xFFFFFFFF),
                                fontSize: 16.0,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your email address',
                                hintStyle: GoogleFonts.inter(
                                  color: Color(0xFF888888),
                                  fontSize: 16.0,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: _model.textControllerValidator.asValidator(context),
                            ),
                          ),
                          
                          SizedBox(height: 30.0),
                          
                          // Botón Send Code
                          Container(
                            width: double.infinity,
                            height: 56.0,
                            decoration: BoxDecoration(
                              color: Color(0xFF4DD0E1), // Turquesa
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_model.formKey.currentState == null ||
                                    !_model.formKey.currentState!.validate()) {
                                  return;
                                }

                                // Generar código de verificación de 6 dígitos
                                final verificationCode = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
                                
                                // Guardar código en la base de datos
                                await SupaFlow.client.from('password_reset_codes').insert({
                                  'email': _model.textController.text,
                                  'code': verificationCode,
                                  'expires_at': DateTime.now().add(Duration(minutes: 10)).toIso8601String(),
                                });

                                // Enviar email con código de verificación
                                await SupaFlow.client.functions.invoke(
                                  'send-verification-code',
                                  body: {
                                    'email': _model.textController.text,
                                    'code': verificationCode,
                                    'type': 'verification',
                                    'fullName': 'User',
                                  },
                                );

                                // Mostrar mensaje de éxito
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Verification code sent to your email'),
                                    backgroundColor: Color(0xFF4CAF50),
                                  ),
                                );

                                // Navegar a la pantalla de verificación
                                context.pushNamed('VerificationCodePage');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Text(
                                'Send verification code',
                                style: GoogleFonts.inter(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                    SizedBox(height: 40.0),
                    
                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Remember your password?',
                            style: GoogleFonts.inter(
                              color: Color(0xFF888888),
                              fontSize: 14.0,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          InkWell(
                            onTap: () => context.pushNamed('LoginPage'),
                            child: Text(
                              'Back to Login',
                              style: GoogleFonts.inter(
                                color: Color(0xFF4DD0E1),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}