import '/flutter_flow/flutter_flow_util.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_up_page_model.dart';
export 'sign_up_page_model.dart';

class SignUpPageWidget extends StatefulWidget {
  const SignUpPageWidget({super.key});

  static String routeName = 'SignUpPage';
  static String routePath = '/signUpPage';

  @override
  State<SignUpPageWidget> createState() => _SignUpPageWidgetState();
}

class _SignUpPageWidgetState extends State<SignUpPageWidget> {
  late SignUpPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSigningUp = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignUpPageModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();

    _model.textController6 ??= TextEditingController();
    _model.textFieldFocusNode6 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _showLoadingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                // Icono de loading moderno con gradiente
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4DD0E1), // Turquesa
                        const Color(0xFF26C6DA), // Turquesa más oscuro
                        const Color(0xFF00BCD4), // Cyan
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4DD0E1).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Círculo exterior animado
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF4DD0E1).withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF4DD0E1).withOpacity(0.7),
                          ),
                        ),
                      ),
                      // Círculo interior con gradiente
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4DD0E1),
                              const Color(0xFF26C6DA),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flight_takeoff_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Texto de loading
                Text(
                  'Creating your account...',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF2C2C2C),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Please wait while we set up your LandGo Travel profile',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF666666),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
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
                    // Header con Skip button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Botón Skip
                        TextButton(
                          onPressed: () {
                            context.goNamed('MainPage');
                          },
                          child: Text(
                            'Skip',
                            style: GoogleFonts.inter(
                              color: Color(0xFFFFFFFF),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 40.0),
                    
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
                    
                    SizedBox(height: 32.0),
                    
                    // Título Sign up centrado
                    Center(
                      child: Text(
                        'Sign up',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Color(0xFFFFFFFF),
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 8.0),
                    
                    // Tagline centrado
                    Center(
                      child: Text(
                        'Sign up for new adventures or log back into your trip',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Color(0xFFFFFFFF),
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
                          // Campo First Name
                          Text(
                            'First name',
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
                              controller: _model.textController1,
                              focusNode: _model.textFieldFocusNode1,
                              autofocus: false,
                              textInputAction: TextInputAction.next,
                              obscureText: false,
                              style: GoogleFonts.inter(
                                color: Color(0xFFFFFFFF),
                                fontSize: 16.0,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Dev',
                                hintStyle: GoogleFonts.inter(
                                  color: Color(0xFF888888),
                                  fontSize: 16.0,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                              ),
                              validator: _model.textController1Validator.asValidator(context),
                            ),
                          ),
                          
                          SizedBox(height: 20.0),
                          
                          // Campo Last Name
                          Text(
                            'Last name',
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
                              controller: _model.textController2,
                              focusNode: _model.textFieldFocusNode2,
                              autofocus: false,
                              textInputAction: TextInputAction.next,
                              obscureText: false,
                              style: GoogleFonts.inter(
                                color: Color(0xFFFFFFFF),
                                fontSize: 16.0,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Cooper',
                                hintStyle: GoogleFonts.inter(
                                  color: Color(0xFF888888),
                                  fontSize: 16.0,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                              ),
                              validator: _model.textController2Validator.asValidator(context),
                            ),
                          ),
                          
                          SizedBox(height: 20.0),
                          
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
                              controller: _model.textController3,
                              focusNode: _model.textFieldFocusNode3,
                              autofocus: false,
                              textInputAction: TextInputAction.next,
                              obscureText: false,
                              style: GoogleFonts.inter(
                                color: Color(0xFFFFFFFF),
                                fontSize: 16.0,
                              ),
                              decoration: InputDecoration(
                                hintText: 'devcooper@gmail.com',
                                hintStyle: GoogleFonts.inter(
                                  color: Color(0xFF888888),
                                  fontSize: 16.0,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: _model.textController3Validator.asValidator(context),
                            ),
                          ),
                          
                          SizedBox(height: 20.0),
                          
                          // Campo Password
                          Text(
                            'Password',
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
                              controller: _model.textController4,
                              focusNode: _model.textFieldFocusNode4,
                              autofocus: false,
                              textInputAction: TextInputAction.done,
                              obscureText: !_model.passwordVisibility,
                              style: GoogleFonts.inter(
                                color: Color(0xFFFFFFFF),
                                fontSize: 16.0,
                              ),
                              decoration: InputDecoration(
                                hintText: '••••••',
                                hintStyle: GoogleFonts.inter(
                                  color: Color(0xFF888888),
                                  fontSize: 16.0,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                                suffixIcon: InkWell(
                                  onTap: () => safeSetState(
                                    () => _model.passwordVisibility = !_model.passwordVisibility,
                                  ),
                                  focusNode: FocusNode(skipTraversal: true),
                                  child: Icon(
                                    _model.passwordVisibility
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Color(0xFF888888),
                                    size: 20.0,
                                  ),
                                ),
                              ),
                              validator: _model.textController4Validator.asValidator(context),
                            ),
                          ),
                          
                          SizedBox(height: 20.0),
                          
                          // Campo Phone Number (Opcional)
                          Text(
                            'Phone number (Optional)',
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
                              controller: _model.textController5,
                              focusNode: _model.textFieldFocusNode5,
                              autofocus: false,
                              textInputAction: TextInputAction.done,
                              obscureText: false,
                              style: GoogleFonts.inter(
                                color: Color(0xFFFFFFFF),
                                fontSize: 16.0,
                              ),
                              decoration: InputDecoration(
                                hintText: '+1 (555) 123-4567',
                                hintStyle: GoogleFonts.inter(
                                  color: Color(0xFF888888),
                                  fontSize: 16.0,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: _model.textController5Validator.asValidator(context),
                            ),
                          ),
                          
                          SizedBox(height: 20.0),
                          
                          // Campo Date of Birth (Opcional)
                          Text(
                            'Date of birth (Optional)',
                            style: GoogleFonts.inter(
                              color: Color(0xFFFFFFFF),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          InkWell(
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().subtract(Duration(days: 365 * 25)), // 25 años atrás por defecto
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: Color(0xFF4DD0E1),
                                        onPrimary: Color(0xFFFFFFFF),
                                        surface: Color(0xFF2C2C2C),
                                        onSurface: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                _model.textController6?.text = pickedDate.toIso8601String().split('T')[0];
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF2C2C2C),
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: Color(0xFF404040),
                                  width: 1.0,
                                ),
                              ),
                              child: TextFormField(
                                controller: _model.textController6,
                                focusNode: _model.textFieldFocusNode6,
                                autofocus: false,
                                textInputAction: TextInputAction.done,
                                obscureText: false,
                                enabled: false,
                                style: GoogleFonts.inter(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 16.0,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'YYYY-MM-DD',
                                  hintStyle: GoogleFonts.inter(
                                    color: Color(0xFF888888),
                                    fontSize: 16.0,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFF888888),
                                    size: 20.0,
                                  ),
                                ),
                                validator: _model.textController6Validator.asValidator(context),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 30.0),
                          
                          // Botón Sign up
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

                                // Activar loading
                                setState(() {
                                  _isSigningUp = true;
                                });

                                // Mostrar modal de loading
                                _showLoadingModal();

                                // Iniciar cronómetro para mínimo 4 segundos
                                final stopwatch = Stopwatch()..start();

                                try {
                                  // Crear cuenta
                                  final user = await authManager.createAccountWithEmail(
                                    context,
                                    _model.textController3.text,
                                    _model.textController4.text,
                                  );

                                  // Asegurar mínimo 4 segundos de loading
                                  final elapsed = stopwatch.elapsedMilliseconds;
                                  if (elapsed < 4000) {
                                    await Future.delayed(Duration(milliseconds: 4000 - elapsed));
                                  }

                                  if (context.mounted) {
                                    // Cerrar modal de loading
                                    Navigator.of(context).pop();
                                    
                                    if (user != null) {
                                      // NO llamar Edge Function - Usar sistema automático de Supabase
                                      // El email de confirmación se enviará automáticamente
                                      
                                      context.pushNamed(
                                        'EmailNotificationPage',
                                        queryParameters: {
                                          'email': _model.textController3.text,
                                          'fullName': '${_model.textController1.text} ${_model.textController2.text}',
                                        },
                                      );
                                    } else {
                                      setState(() {
                                        _isSigningUp = false;
                                      });
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    // Cerrar modal de loading
                                    Navigator.of(context).pop();
                                    
                                    setState(() {
                                      _isSigningUp = false;
                                    });
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Sign up failed: ${e.toString()}'),
                                        backgroundColor: Color(0xFFDC2626),
                                      ),
                                    );
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
                              child: _isSigningUp
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Sign up',
                                    style: GoogleFonts.inter(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            ),
                          ),
                          
                          SizedBox(height: 30.0),
                          
                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Color(0xFF404040),
                                  thickness: 1.0,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                child: Text(
                                  'Or',
                                  style: GoogleFonts.inter(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Color(0xFF404040),
                                  thickness: 1.0,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 30.0),
                          
                          // Botones sociales
                          Column(
                            children: [
                              // Google
                              Container(
                                width: double.infinity,
                                height: 56.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFF2C2C2C),
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: Color(0xFF404040),
                                    width: 1.0,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Google authentication coming soon'),
                                        backgroundColor: Color(0xFF37474F),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.google,
                                        color: Color(0xFF4285F4),
                                        size: 20.0,
                                      ),
                                      SizedBox(width: 12.0),
                                      Text(
                                        'Google',
                                        style: GoogleFonts.inter(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: 16.0),
                              
                              // Apple
                              Container(
                                width: double.infinity,
                                height: 56.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFF2C2C2C),
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: Color(0xFF404040),
                                    width: 1.0,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Apple authentication coming soon'),
                                        backgroundColor: Color(0xFF37474F),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.apple,
                                        color: Color(0xFFFFFFFF),
                                        size: 20.0,
                                      ),
                                      SizedBox(width: 12.0),
                                      Text(
                                        'Apple',
                                        style: GoogleFonts.inter(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  
                    SizedBox(height: 40.0),
                    
                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.inter(
                            color: Color(0xFFFFFFFF),
                            fontSize: 14.0,
                          ),
                        ),
                        InkWell(
                          onTap: () => context.pushNamed('LoginPage'),
                          child: Text(
                            'Sign in',
                            style: GoogleFonts.inter(
                              color: Color(0xFF4DD0E1),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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