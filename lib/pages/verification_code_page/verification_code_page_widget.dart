import '/flutter_flow/flutter_flow_util.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VerificationCodePageModel());

    // Inicializar 6 controladores para cada dígito
    for (int i = 0; i < 6; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _getVerificationCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
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
                          'Verification',
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
                        'Enter verification code',
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
                        'We\'ve sent a 6-digit verification code to your email address',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Color(0xFF888888),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40.0),
                  
                    // Código de verificación - 6 campos individuales
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 50.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Color(0xFF404040),
                              width: 1.0,
                            ),
                          ),
                          child: TextFormField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(1),
                            ],
                            style: GoogleFonts.inter(
                              color: Color(0xFFFFFFFF),
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) => _onDigitChanged(index, value),
                          ),
                        );
                      }),
                    ),
                    
                    SizedBox(height: 40.0),
                    
                    // Botón Verify
                    Container(
                      width: double.infinity,
                      height: 56.0,
                      decoration: BoxDecoration(
                        color: Color(0xFF4DD0E1), // Turquesa
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          final code = _getVerificationCode();
                          
                          if (code.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter the complete 6-digit code'),
                                backgroundColor: Color(0xFFDC2626),
                              ),
                            );
                            return;
                          }

                          // Verificar el código en la base de datos
                          final result = await SupaFlow.client
                              .from('password_reset_codes')
                              .select()
                              .eq('code', code)
                              .gte('expires_at', DateTime.now().toIso8601String())
                              .single();

                          if (result != null) {
                            // Código válido, navegar a reset password
                            context.pushNamed('ResetPasswordPage', queryParameters: {
                              'email': widget.email ?? '',
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Invalid or expired verification code'),
                                backgroundColor: Color(0xFFDC2626),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          'Verify code',
                          style: GoogleFonts.inter(
                            color: Color(0xFFFFFFFF),
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 30.0),
                    
                    // Botón Resend
                    Center(
                      child: InkWell(
                        onTap: () async {
                          // Reenviar código de verificación
                          final verificationCode = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
                          
                          await SupaFlow.client.from('password_reset_codes').insert({
                            'email': widget.email ?? '',
                            'code': verificationCode,
                            'expires_at': DateTime.now().add(Duration(minutes: 10)).toIso8601String(),
                          });

                          await SupaFlow.client.functions.invoke(
                            'send-verification-code',
                            body: {
                              'email': widget.email ?? '',
                              'code': verificationCode,
                              'type': 'verification',
                              'fullName': 'User',
                            },
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('New verification code sent'),
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        },
                        child: Text(
                          'Resend code',
                          style: GoogleFonts.inter(
                            color: Color(0xFF4DD0E1),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  
                    SizedBox(height: 40.0),
                    
                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Didn\'t receive the code?',
                            style: GoogleFonts.inter(
                              color: Color(0xFF888888),
                              fontSize: 14.0,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          InkWell(
                            onTap: () => context.pushNamed('ForgotPasswordPage'),
                            child: Text(
                              'Try different email',
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