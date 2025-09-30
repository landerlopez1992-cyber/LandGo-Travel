import '/flutter_flow/flutter_flow_util.dart';
import '/backend/supabase/supabase.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'verification_code_page_model.dart';
export 'verification_code_page_model.dart';

class VerificationCodePageWidget extends StatefulWidget {
  const VerificationCodePageWidget({
    super.key,
    this.email,
    this.type,
    this.pendingChanges,
  });

  final String? email;
  final String? type;
  final String? pendingChanges;

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
  bool _isVerifying = false;
  bool _isResending = false;
  int _emailCount = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VerificationCodePageModel());

    // Inicializar 6 controladores para cada dígito
    for (int i = 0; i < 6; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }

    // DEBUG: Verificar parámetros recibidos
    print('🔍 DEBUG INIT: Email recibido: ${widget.email}');
    print('🔍 DEBUG INIT: Type recibido: ${widget.type}');
    print('🔍 DEBUG INIT: PendingChanges recibido: ${widget.pendingChanges}');

    // Cargar contador de emails
    _loadEmailCount();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  // Obtener parámetros del widget
  String get _email => widget.email ?? '';
  String get _type => widget.type ?? '';
  String get _pendingChanges => widget.pendingChanges ?? '';

  // Cargar contador de emails enviados hoy
  Future<void> _loadEmailCount() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final result = await SupaFlow.client
          .from('verification_codes')
          .select('created_at')
          .eq('email', _email)
          .eq('type', _type)
          .gte('created_at', startOfDay.toIso8601String())
          .order('created_at', ascending: false);

      setState(() {
        _emailCount = result.length;
      });

      print('🔍 DEBUG: Email count today: $_emailCount');
    } catch (e) {
      print('🔍 DEBUG: Error loading email count: $e');
    }
  }

  // Verificar si se puede enviar más emails
  bool _canSendEmail() {
    if (_emailCount >= 4) {
      return false; // Límite alcanzado
    }
    return true;
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

  Future<void> _processProfileUpdate() async {
    try {
      print('🔍 DEBUG: Processing profile update...');
      
      // Parsear los cambios pendientes
      final changes = _pendingChanges.isNotEmpty 
          ? Map<String, dynamic>.from(json.decode(_pendingChanges))
          : <String, dynamic>{};
      
      print('🔍 DEBUG: Pending changes: $changes');

      // Asegurar mínimo 2 segundos de loading
      final stopwatch = Stopwatch()..start();
      
      // Actualizar el perfil en Supabase
      final updateData = <String, dynamic>{};
      
      if (changes['full_name'] != null) {
        updateData['full_name'] = changes['full_name'];
      }
      if (changes['phone'] != null) {
        updateData['phone'] = changes['phone'];
      }
      if (changes['date_of_birth'] != null) {
        updateData['date_of_birth'] = changes['date_of_birth'];
      }
      
      if (updateData.isNotEmpty) {
        print('🔍 DEBUG: Updating profile with: $updateData');
        
        final response = await SupaFlow.client
            .from('profiles')
            .update(updateData)
            .eq('email', _email);
            
        print('🔍 DEBUG: Profile update response: $response');
      }

      // Asegurar mínimo 2 segundos
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 2000) {
        await Future.delayed(Duration(milliseconds: 2000 - elapsed));
      }

      // Eliminar el código de verificación usado
      await SupaFlow.client
          .from('verification_codes')
          .delete()
          .eq('email', _email)
          .eq('type', 'profile_update')
          .eq('code', _getVerificationCode());

      print('🔍 DEBUG: Profile update completed successfully');

      // Mostrar modal de éxito
      if (mounted) {
        _showSuccessModal();
      }

    } catch (e) {
      print('🔍 DEBUG: Error processing profile update: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile. Please try again.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFF4CAF50), width: 2),
            ),
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono de éxito
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Título
                Text(
                  'Profile Updated Successfully!',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 15),
                
                // Mensaje
                Text(
                  'Your profile information has been updated and verified successfully.',
                  style: GoogleFonts.inter(
                    color: Color(0xFF888888),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 25),
                
                // Botón OK
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar modal
                      Navigator.of(context).pop(true); // Volver a MyProfilePage con resultado exitoso
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                        onPressed: _isVerifying ? null : () async {
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

                          setState(() {
                            _isVerifying = true;
                          });

                          try {
                            print('🔍 DEBUG: Verifying code: $code');
                            print('🔍 DEBUG: Email: $_email');
                            print('🔍 DEBUG: Type: $_type');
                            print('🔍 DEBUG: Current time: ${DateTime.now().toIso8601String()}');

                            // Primero verificar si existe el código SOLO por código
                            print('🔍 DEBUG: Buscando código: $code');
                            print('🔍 DEBUG: Email del widget: $_email');
                            print('🔍 DEBUG: Tipo del widget: $_type');
                            
                            final codeCheck = await SupaFlow.client
                                .from('verification_codes')
                                .select('code, email, type, expires_at, created_at')
                                .eq('code', code)
                                .maybeSingle();

                            print('🔍 DEBUG: Code check result: $codeCheck');

                            if (codeCheck == null) {
                              print('🔍 DEBUG: ❌ Código no encontrado en DB');
                              
                              // Buscar cualquier código para este email para debugging
                              final allCodes = await SupaFlow.client
                                  .from('verification_codes')
                                  .select('code, email, type, expires_at')
                                  .order('created_at', ascending: false)
                                  .limit(5);
                              
                              print('🔍 DEBUG: Últimos 5 códigos en DB: $allCodes');
                              throw Exception('Código no encontrado');
                            }

                            // Verificar que coincida el email y tipo
                            final dbEmail = codeCheck['email'] as String;
                            final dbType = codeCheck['type'] as String;
                            
                            print('🔍 DEBUG: ✅ Código encontrado en DB');
                            print('🔍 DEBUG: Email en DB: $dbEmail');
                            print('🔍 DEBUG: Tipo en DB: $dbType');
                            
                            if (_email.isNotEmpty && dbEmail != _email) {
                              print('🔍 DEBUG: ❌ Email no coincide: $_email vs $dbEmail');
                              throw Exception('Código no válido para este email');
                            }
                            
                            if (_type.isNotEmpty && dbType != _type) {
                              print('🔍 DEBUG: ❌ Tipo no coincide: $_type vs $dbType');
                              throw Exception('Código no válido para este tipo');
                            }

                            // Verificar si el código ha expirado
                            final expiresAtString = codeCheck['expires_at'] as String;
                            final expiresAt = DateTime.parse(expiresAtString);
                            final now = DateTime.now().toUtc();
                            
                            print('🔍 DEBUG: Code expires at (string): $expiresAtString');
                            print('🔍 DEBUG: Code expires at (parsed): $expiresAt');
                            print('🔍 DEBUG: Current time (UTC): $now');
                            print('🔍 DEBUG: Difference in minutes: ${expiresAt.difference(now).inMinutes}');
                            print('🔍 DEBUG: Is expired: ${now.isAfter(expiresAt)}');

                            if (now.isAfter(expiresAt)) {
                              throw Exception('Código expirado');
                            }

                            // Código válido - procesar según el tipo
                            print('🔍 DEBUG: ✅ Código válido, procesando tipo: $_type');
                            if (_type == 'profile_update') {
                              print('🔍 DEBUG: Procesando actualización de perfil...');
                              await _processProfileUpdate();
                            } else {
                              print('🔍 DEBUG: Procesando otro tipo: $_type');
                              // Otros tipos de verificación (password reset, etc.)
                              context.pushNamed('ResetPasswordPage', queryParameters: {
                                'email': _email,
                              });
                            }
                          } catch (e) {
                            print('🔍 DEBUG: Verification error: $e');
                            String errorMessage = 'Invalid or expired verification code';
                            
                            if (e.toString().contains('Código expirado')) {
                              errorMessage = 'El código ha expirado. Solicita uno nuevo.';
                            } else if (e.toString().contains('Código no encontrado')) {
                              errorMessage = 'Código inválido. Verifica que lo hayas ingresado correctamente.';
                            }
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Color(0xFFDC2626),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isVerifying = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: _isVerifying
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Verifying...',
                                  style: GoogleFonts.inter(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Text(
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
                      child: _canSendEmail() 
                        ? InkWell(
                            onTap: _isResending ? null : () async {
                              if (!_canSendEmail()) return;
                              
                              setState(() {
                                _isResending = true;
                              });

                              try {
                                print('🔍 DEBUG: Resending verification code...');
                                
                                // Asegurar mínimo 2 segundos de loading
                                final stopwatch = Stopwatch()..start();

                                // WORKAROUND: Generar nuevo código y usar 'verification'
                                final newResetCode = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
                                
                                // Limpiar códigos anteriores para este email y tipo
                                await SupaFlow.client.from('verification_codes')
                                  .delete()
                                  .eq('email', _email)
                                  .eq('type', _type.isNotEmpty ? _type : 'password_reset');
                                
                                // Guardar nuevo código en verification_codes
                                await SupaFlow.client.from('verification_codes').insert({
                                  'email': _email,
                                  'code': newResetCode,
                                  'type': _type.isNotEmpty ? _type : 'password_reset',
                                  'expires_at': DateTime.now().toUtc().add(Duration(minutes: 10)).toIso8601String(),
                                });
                                
                                // Enviar usando 'verification' que funciona
                                await SupaFlow.client.functions.invoke(
                                  'send-verification-code',
                                  body: {
                                    'email': _email,
                                    'type': 'verification',
                                    'code': newResetCode,
                                    'fullName': 'User',
                                  },
                                );

                                // Asegurar mínimo 2 segundos
                                final elapsed = stopwatch.elapsedMilliseconds;
                                if (elapsed < 2000) {
                                  await Future.delayed(Duration(milliseconds: 2000 - elapsed));
                                }

                                // Actualizar contador
                                await _loadEmailCount();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Nuevo código de verificación enviado'),
                                    backgroundColor: Color(0xFF4CAF50),
                                  ),
                                );
                              } catch (e) {
                                print('🔍 DEBUG: Error resending code: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error enviando código. Intenta nuevamente.'),
                                    backgroundColor: Color(0xFFDC2626),
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isResending = false;
                                  });
                                }
                              }
                            },
                            child: _isResending
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Enviando...',
                                      style: GoogleFonts.inter(
                                        color: Color(0xFF4DD0E1),
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Resend code',
                                  style: GoogleFonts.inter(
                                    color: Color(0xFF4DD0E1),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                          )
                        : Column(
                            children: [
                              Text(
                                'Límite de emails alcanzado',
                                style: GoogleFonts.inter(
                                  color: Color(0xFFDC2626),
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Puedes solicitar más códigos mañana',
                                style: GoogleFonts.inter(
                                  color: Color(0xFF888888),
                                  fontSize: 12.0,
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