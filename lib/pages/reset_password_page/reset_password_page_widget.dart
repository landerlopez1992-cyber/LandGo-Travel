import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/supabase/supabase.dart';
import '/components/back_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _isUpdatingPassword = false;
  
  // Variables para el primer campo (New Password)
  String _passwordStrength1 = 'weak';
  double _passwordStrengthValue1 = 0.0;
  
  // Variables para el segundo campo (Confirm Password)
  String _passwordStrength2 = 'weak';
  double _passwordStrengthValue2 = 0.0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResetPasswordPageModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    // Agregar listener para verificar fortaleza de contraseña
    _model.textController1?.addListener(() {
      print('🔍 DEBUG: TextController1 changed: ${_model.textController1?.text}');
      _checkPasswordStrength1(_model.textController1?.text ?? '');
    });
    
    _model.textController2?.addListener(() {
      print('🔍 DEBUG: TextController2 changed: ${_model.textController2?.text}');
      _checkPasswordStrength2(_model.textController2?.text ?? '');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildPasswordStrengthIndicator1() {
    return _buildPasswordStrengthIndicator(_passwordStrength1, _passwordStrengthValue1);
  }

  Widget _buildPasswordStrengthIndicator2() {
    return _buildPasswordStrengthIndicator(_passwordStrength2, _passwordStrengthValue2);
  }

  Widget _buildPasswordStrengthIndicator(String strength, double value) {
    Color barColor;
    String strengthText;
    Color textColor;

    switch (strength) {
      case 'weak':
        barColor = const Color(0xFFDC2626); // Rojo - Pobre
        strengthText = 'Weak Password';
        textColor = const Color(0xFFDC2626);
        break;
      case 'medium':
        barColor = const Color(0xFFFFC107); // Amarillo - Mediana
        strengthText = 'Medium Password';
        textColor = const Color(0xFFFFC107);
        break;
      case 'good':
        barColor = const Color(0xFF2196F3); // Azul - Buena
        strengthText = 'Good Password';
        textColor = const Color(0xFF2196F3);
        break;
      case 'strong':
        barColor = const Color(0xFF4CAF50); // Verde - Excelente
        strengthText = 'Strong Password';
        textColor = const Color(0xFF4CAF50);
        break;
      default:
        barColor = const Color(0xFFE2E8F0); // Gris
        strengthText = 'Enter Password';
        textColor = const Color(0xFF6B7280);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de progreso
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              Expanded(
                flex: (value * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Expanded(
                flex: (100 - (value * 100)).round(),
                child: const SizedBox(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Texto de fortaleza
        Text(
          strengthText,
          style: GoogleFonts.outfit(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _checkPasswordStrength1(String password) {
    print('🔍 DEBUG: Checking password strength 1 for: "$password"');
    if (password.isEmpty) {
      print('🔍 DEBUG: Password 1 is empty, setting to weak');
      setState(() {
        _passwordStrength1 = 'weak';
        _passwordStrengthValue1 = 0.0;
      });
      return;
    }

    double strength = _calculatePasswordStrength(password);
    String strengthLevel = _getStrengthLevel(strength);

    print('🔍 DEBUG: Final strength 1: $strength, level: $strengthLevel');
    setState(() {
      _passwordStrength1 = strengthLevel;
      _passwordStrengthValue1 = strength;
    });
    print('🔍 DEBUG: State updated 1 - strength: $_passwordStrength1, value: $_passwordStrengthValue1');
  }

  void _checkPasswordStrength2(String password) {
    print('🔍 DEBUG: Checking password strength 2 for: "$password"');
    if (password.isEmpty) {
      print('🔍 DEBUG: Password 2 is empty, setting to weak');
      setState(() {
        _passwordStrength2 = 'weak';
        _passwordStrengthValue2 = 0.0;
      });
      return;
    }

    double strength = _calculatePasswordStrength(password);
    String strengthLevel = _getStrengthLevel(strength);

    print('🔍 DEBUG: Final strength 2: $strength, level: $strengthLevel');
    setState(() {
      _passwordStrength2 = strengthLevel;
      _passwordStrengthValue2 = strength;
    });
    print('🔍 DEBUG: State updated 2 - strength: $_passwordStrength2, value: $_passwordStrengthValue2');
  }

  double _calculatePasswordStrength(String password) {
    double strength = 0.0;

    // Verificar longitud (más peso a la longitud)
    if (password.length >= 4) strength += 0.1;
    if (password.length >= 6) strength += 0.15;
    if (password.length >= 8) strength += 0.15;
    if (password.length >= 10) strength += 0.1;
    if (password.length >= 12) strength += 0.1;

    // Verificar letras minúsculas
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;

    // Verificar letras mayúsculas
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;

    // Verificar números
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;

    // Verificar caracteres especiales básicos
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.15;

    // Verificar caracteres especiales adicionales
    if (password.contains(RegExp(r'[~`_+-=]'))) strength += 0.1;

    return strength;
  }

  String _getStrengthLevel(double strength) {
    if (strength <= 0.25) {
      return 'weak'; // Rojo - Pobre
    } else if (strength <= 0.5) {
      return 'medium'; // Amarillo - Mediana
    } else if (strength <= 0.75) {
      return 'good'; // Azul - Buena
    } else {
      return 'strong'; // Verde - Excelente
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
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono de éxito
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50), // COLORES LANDGO TRAVEL - Éxito
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Título
                Text(
                  'Password Updated!',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1F2937), // COLORES LANDGO TRAVEL - Texto Principal
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Mensaje
                Text(
                  'Your password has been successfully updated. You can now log in with your new password.',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF6B7280), // COLORES LANDGO TRAVEL - Texto Secundario
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Botón OK
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.goNamedAuth('LoginPage', context.mounted);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // COLORES LANDGO TRAVEL - Éxito
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Go to Login',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
        backgroundColor: const Color(0xFF1A1A1A), // COLORES LANDGO TRAVEL - Fondo Negro Oscuro
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              // Header con botón de regreso y título
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        StandardBackButton(
                          onPressed: () => context.safePop(),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Título centrado
                    Text(
                      'New Password',
                      style: GoogleFonts.outfit(
                        color: Colors.white, // COLORES LANDGO TRAVEL - Texto Principal en fondo oscuro
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a new password for your account',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF9CA3AF), // COLORES LANDGO TRAVEL - Texto Secundario en fondo oscuro
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icono de seguridad
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD), // Azul claro
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: const Color(0xFF4DD0E1), // COLORES LANDGO TRAVEL - Verde Secciones
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.security,
                          color: Color(0xFF4DD0E1), // COLORES LANDGO TRAVEL - Verde Secciones
                          size: 50,
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Formulario
                      Form(
                        key: _model.formKey,
                        child: Column(
                          children: [
                            // Campo de nueva contraseña
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _model.textController1,
                                focusNode: _model.textFieldFocusNode1,
                                autofocus: false,
                                obscureText: !_model.passwordVisibility1,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  labelStyle: GoogleFonts.outfit(
                                    color: const Color(0xFF37474F), // Más oscuro para mejor contraste
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600, // Más bold
                                  ),
                                  hintText: 'Enter your new password',
                                  hintStyle: GoogleFonts.outfit(
                                    color: const Color(0xFF6B7280), // Más oscuro para mejor legibilidad
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
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
                                      color: Color(0xFF4DD0E1), // COLORES LANDGO TRAVEL - Verde Secciones
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
                                  fillColor: Colors.white,
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
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF4DD0E1), // Azul turquesa para mejor visibilidad
                                  fontSize: 18, // Más grande para mejor legibilidad
                                  fontWeight: FontWeight.w700, // Más bold
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (val.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            
                            // Barra de fortaleza de contraseña (solo si hay texto)
                            if (_model.textController1?.text.isNotEmpty == true) ...[
                              const SizedBox(height: 12),
                              _buildPasswordStrengthIndicator1(),
                              const SizedBox(height: 4),
                            ],
                            
                            const SizedBox(height: 16),
                            
                            // Campo de confirmar contraseña
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white, // Fondo blanco para mejor contraste
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _model.textController2,
                                focusNode: _model.textFieldFocusNode2,
                                autofocus: false,
                                obscureText: !_model.passwordVisibility2,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  labelStyle: GoogleFonts.outfit(
                                    color: const Color(0xFF37474F), // Más oscuro para mejor contraste
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600, // Más bold
                                  ),
                                  hintText: 'Confirm your new password',
                                  hintStyle: GoogleFonts.outfit(
                                    color: const Color(0xFF6B7280), // Más oscuro para mejor legibilidad
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
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
                                      color: Color(0xFF4DD0E1), // COLORES LANDGO TRAVEL - Verde Secciones
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
                                  fillColor: Colors.white,
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
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF4DD0E1), // Azul turquesa para mejor visibilidad
                                  fontSize: 18, // Más grande para mejor legibilidad
                                  fontWeight: FontWeight.w700, // Más bold
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (val != _model.textController1?.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            
                            // Barra de fortaleza de contraseña para confirmar (solo si hay texto)
                            if (_model.textController2?.text.isNotEmpty == true) ...[
                              const SizedBox(height: 12),
                              _buildPasswordStrengthIndicator2(),
                              const SizedBox(height: 4),
                            ],
                            
                            const SizedBox(height: 24),
                            
                            // Botón actualizar contraseña
                            FFButtonWidget(
                              onPressed: _isUpdatingPassword ? null : () async {
                                if (_model.formKey.currentState == null ||
                                    !_model.formKey.currentState!.validate()) {
                                  return;
                                }

                                setState(() {
                                  _isUpdatingPassword = true;
                                });

                                try {
                                  // Obtener email del parámetro
                                  final email = GoRouterState.of(context).uri.queryParameters['email'] ?? '';
                                  
                                  if (email.isEmpty) {
                                    throw Exception('Email parameter is missing');
                                  }
                                  
                                  // Iniciar cronómetro para mínimo 2 segundos
                                  final stopwatch = Stopwatch()..start();
                                  
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
                                    
                                    // Asegurar mínimo 2 segundos de loading
                                    final elapsed = stopwatch.elapsedMilliseconds;
                                    if (elapsed < 2000) {
                                      await Future.delayed(Duration(milliseconds: 2000 - elapsed));
                                    }
                                    
                                    if (context.mounted) {
                                      setState(() {
                                        _isUpdatingPassword = false;
                                      });
                                      _showSuccessModal();
                                    }
                                  } else {
                                    throw Exception('Failed to update password');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    setState(() {
                                      _isUpdatingPassword = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error updating password: ${e.toString()}'),
                                        backgroundColor: const Color(0xFFDC2626), // COLORES LANDGO TRAVEL - Error
                                      ),
                                    );
                                  }
                                }
                              },
                              text: _isUpdatingPassword ? 'Updating...' : 'Update Password',
                              icon: _isUpdatingPassword 
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : null,
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 56,
                                padding: const EdgeInsets.all(8),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                color: _isUpdatingPassword 
                                    ? const Color(0xFF9CA3AF) // COLORES LANDGO TRAVEL - Deshabilitado
                                    : const Color(0xFF4DD0E1), // COLORES LANDGO TRAVEL - Verde Secciones
                                textStyle: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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
                      
                      const SizedBox(height: 40),
                      
                      // Enlace de regreso
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Remember your password? ',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF6B7280), // COLORES LANDGO TRAVEL - Texto Secundario
                              fontSize: 16,
                            ),
                          ),
                          InkWell(
                            onTap: () => context.goNamedAuth('LoginPage', context.mounted),
                            child: Text(
                              'Back to Login',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4DD0E1), // COLORES LANDGO TRAVEL - Verde Secciones
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}