import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'change_password_page_model.dart';
export 'change_password_page_model.dart';

/// Change Password Page - Allows logged-in users to change their password
///
/// Features:
/// - Current password input
/// - New password input with strength indicator
/// - Confirm new password
/// - Validation and error handling
/// - Success feedback
class ChangePasswordPageWidget extends StatefulWidget {
  const ChangePasswordPageWidget({super.key});

  static String routeName = 'ChangePasswordPage';
  static String routePath = '/changePasswordPage';

  @override
  State<ChangePasswordPageWidget> createState() => _ChangePasswordPageWidgetState();
}

class _ChangePasswordPageWidgetState extends State<ChangePasswordPageWidget> {
  late ChangePasswordPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isChangingPassword = false;
  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  String? _verificationCode;
  bool _codeSent = false;
  
  // Password strength variables
  String _newPasswordStrength = 'weak';
  double _newPasswordStrengthValue = 0.0;
  
  // Controllers para el código de verificación
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChangePasswordPageModel());

    _model.currentPasswordController ??= TextEditingController();
    _model.currentPasswordFocusNode ??= FocusNode();
    
    _model.newPasswordController ??= TextEditingController();
    _model.newPasswordFocusNode ??= FocusNode();
    
    _model.confirmPasswordController ??= TextEditingController();
    _model.confirmPasswordFocusNode ??= FocusNode();

    // Listener para verificar fortaleza de contraseña
    _model.newPasswordController?.addListener(() {
      _checkPasswordStrength(_model.newPasswordController?.text ?? '');
    });
  }

  @override
  void dispose() {
    _model.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _newPasswordStrength = 'weak';
        _newPasswordStrengthValue = 0.0;
      });
      return;
    }

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength++;

    setState(() {
      if (strength <= 2) {
        _newPasswordStrength = 'weak';
        _newPasswordStrengthValue = 0.3;
      } else if (strength == 3) {
        _newPasswordStrength = 'medium';
        _newPasswordStrengthValue = 0.6;
      } else {
        _newPasswordStrength = 'strong';
        _newPasswordStrengthValue = 1.0;
      }
    });
  }

  // Paso 1: Enviar código de verificación
  Future<void> _sendVerificationCode() async {
    // Validaciones
    final currentPassword = _model.currentPasswordController?.text ?? '';
    final newPassword = _model.newPasswordController?.text ?? '';
    final confirmPassword = _model.confirmPasswordController?.text ?? '';

    if (currentPassword.isEmpty) {
      _showError('Please enter your current password');
      return;
    }

    if (newPassword.isEmpty) {
      _showError('Please enter a new password');
      return;
    }

    if (newPassword.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    if (newPassword != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    if (currentPassword == newPassword) {
      _showError('New password must be different from current password');
      return;
    }

    setState(() {
      _isSendingCode = true;
    });

    try {
      print('📧 Sending verification code...');

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      print('🔍 User email: ${user.email}');

      // Verificar contraseña actual primero
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: user.email!,
          password: currentPassword,
        );
        print('✅ Current password verified');
      } catch (e) {
        print('❌ Current password incorrect: $e');
        throw Exception('Current password is incorrect');
      }

      // Generar código de 6 dígitos
      final code = (100000 + (999999 - 100000) * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000).floor().toString();
      print('🔢 Generated code: $code');

      // Guardar código en verification_codes table
      await Supabase.instance.client.from('verification_codes').insert({
        'email': user.email,
        'code': code,
        'type': 'password_change',
        'expires_at': DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      print('💾 Code saved to database');

      // Enviar código por email usando Edge Function
      try {
        final response = await Supabase.instance.client.functions.invoke(
          'send-verification-code',
          body: {
            'email': user.email,
            'code': code,
            'type': 'password_change',
          },
        );
        
        print('📧 Email send response: ${response.data}');
      } catch (e) {
        print('⚠️ Email send failed, but code saved: $e');
      }

      if (mounted) {
        setState(() {
          _isSendingCode = false;
          _codeSent = true;
          _verificationCode = code;
        });

        _showInfo('Verification code sent to ${user.email}');
      }
    } catch (e) {
      print('❌ Error sending verification code: $e');
      
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });

        String errorMessage = 'Failed to send verification code';
        if (e.toString().contains('incorrect')) {
          errorMessage = 'Current password is incorrect';
        }

        _showError(errorMessage);
      }
    }
  }

  // Paso 2: Verificar código y cambiar contraseña
  Future<void> _verifyCodeAndChangePassword() async {
    final enteredCode = _codeController.text.trim();

    if (enteredCode.isEmpty) {
      _showError('Please enter the verification code');
      return;
    }

    if (enteredCode.length != 6) {
      _showError('Code must be 6 digits');
      return;
    }

    setState(() {
      _isVerifyingCode = true;
    });

    try {
      print('🔍 Verifying code...');

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Verificar código en la base de datos
      final response = await Supabase.instance.client
          .from('verification_codes')
          .select()
          .eq('email', user.email!)
          .eq('code', enteredCode)
          .eq('type', 'password_change')
          .gte('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        throw Exception('Invalid or expired verification code');
      }

      print('✅ Code verified successfully');

      // Actualizar la contraseña
      final newPassword = _model.newPasswordController?.text ?? '';
      print('🔄 Updating password...');
      
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      print('✅ Password updated successfully');

      // Eliminar código usado
      await Supabase.instance.client
          .from('verification_codes')
          .delete()
          .eq('email', user.email!)
          .eq('code', enteredCode);

      print('🗑️ Code deleted');

      if (mounted) {
        setState(() {
          _isVerifyingCode = false;
        });

        // Mostrar modal de éxito
        _showSuccessModal();
      }
    } catch (e) {
      print('❌ Error verifying code or changing password: $e');
      
      if (mounted) {
        setState(() {
          _isVerifyingCode = false;
        });

        String errorMessage = 'Failed to verify code';
        if (e.toString().contains('Invalid') || e.toString().contains('expired')) {
          errorMessage = 'Invalid or expired verification code';
        }

        _showError(errorMessage);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4DD0E1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DD0E1).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4DD0E1),
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Password Changed!',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your password has been changed successfully.',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar modal
                      context.goNamed('SettingsPage'); // Regresar a Settings
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DD0E1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Back to Settings',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
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
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF000000), // NEGRO PURO LANDGO
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                const SizedBox(height: 10),
                
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Change Password',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Enter your current password and choose a new one',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Form
                _buildForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF000000), // NEGRO PURO
      ),
      child: Row(
        children: [
          StandardBackButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.goNamed('SettingsPage');
              }
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Password
          _buildPasswordField(
            label: 'Current Password',
            controller: _model.currentPasswordController!,
            focusNode: _model.currentPasswordFocusNode!,
            isVisible: _model.currentPasswordVisibility,
            onVisibilityToggle: () {
              setState(() {
                _model.currentPasswordVisibility = !_model.currentPasswordVisibility;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // New Password
          _buildPasswordField(
            label: 'New Password',
            controller: _model.newPasswordController!,
            focusNode: _model.newPasswordFocusNode!,
            isVisible: _model.newPasswordVisibility,
            onVisibilityToggle: () {
              setState(() {
                _model.newPasswordVisibility = !_model.newPasswordVisibility;
              });
            },
            showStrength: true,
          ),
          
          if (_model.newPasswordController!.text.isNotEmpty)
            _buildPasswordStrengthIndicator(),
          
          const SizedBox(height: 24),
          
          // Confirm Password
          _buildPasswordField(
            label: 'Confirm New Password',
            controller: _model.confirmPasswordController!,
            focusNode: _model.confirmPasswordFocusNode!,
            isVisible: _model.confirmPasswordVisibility,
            onVisibilityToggle: () {
              setState(() {
                _model.confirmPasswordVisibility = !_model.confirmPasswordVisibility;
              });
            },
          ),
          
          const SizedBox(height: 40),
          
          // Mostrar campo de código si el código fue enviado
          if (_codeSent) ...[
            Text(
              'Verification Code',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF37474F).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: GoogleFonts.outfit(
                    color: Colors.white24,
                    fontSize: 20,
                    letterSpacing: 8,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enter the 6-digit code sent to your email',
              style: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Botón: Send Code o Verify Code
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _codeSent 
                  ? (_isVerifyingCode ? null : _verifyCodeAndChangePassword)
                  : (_isSendingCode ? null : _sendVerificationCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DD0E1), // TURQUESA LANDGO
                disabledBackgroundColor: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: (_isSendingCode || _isVerifyingCode)
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      _codeSent ? 'Verify Code & Change Password' : 'Send Verification Code',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    bool showStrength = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF37474F).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: !isVisible,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF4DD0E1),
                  size: 22,
                ),
                onPressed: onVisibilityToggle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    Color strengthColor;
    String strengthText;
    
    if (_newPasswordStrength == 'weak') {
      strengthColor = const Color(0xFFDC2626);
      strengthText = 'Weak';
    } else if (_newPasswordStrength == 'medium') {
      strengthColor = const Color(0xFFFF9800);
      strengthText = 'Medium';
    } else {
      strengthColor = const Color(0xFF4CAF50);
      strengthText = 'Strong';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: (_newPasswordStrengthValue * 100).round(),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: strengthColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                flex: (100 - (_newPasswordStrengthValue * 100)).round(),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Password strength: $strengthText',
            style: GoogleFonts.outfit(
              color: strengthColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

